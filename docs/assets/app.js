const state = {
  catalog: [],
  query: "",
  category: "all",
  activeShader: null,
  codeTab: "shader",
};

const elements = {
  grid: document.querySelector("#shader-grid"),
  template: document.querySelector("#shader-card-template"),
  search: document.querySelector("#search"),
  filters: document.querySelector("#category-filters"),
  resultCount: document.querySelector("#result-count"),
  emptyState: document.querySelector("#empty-state"),
  shaderCount: document.querySelector("#shader-count"),
  repositoryLink: document.querySelector("#repository-link"),
  repositoryDocsLinks: [...document.querySelectorAll(".repository-docs-link")],
  dialog: document.querySelector("#shader-dialog"),
  dialogClose: document.querySelector("#dialog-close"),
  dialogPreview: document.querySelector("#dialog-preview"),
  dialogCategory: document.querySelector("#dialog-category"),
  dialogTitle: document.querySelector("#dialog-title"),
  dialogDescription: document.querySelector("#dialog-description"),
  dialogTags: document.querySelector("#dialog-tags"),
  uniformTable: document.querySelector("#uniform-table"),
  notesSection: document.querySelector("#notes-section"),
  notesList: document.querySelector("#notes-list"),
  codeView: document.querySelector("#code-view"),
  copyCode: document.querySelector("#copy-code"),
  codeTabs: [...document.querySelectorAll("[data-code-tab]")],
};

function escapeText(value) {
  return String(value ?? "");
}

function formatDefault(value) {
  if (Array.isArray(value)) {
    return `{ ${value.map((item) => Number(item).toFixed(4).replace(/0+$/, "").replace(/\.$/, "")).join(", ")} }`;
  }
  return typeof value === "number" ? String(value) : escapeText(value);
}

function inferRepositoryLink() {
  if (!location.hostname.endsWith(".github.io")) return;
  const owner = location.hostname.split(".")[0];
  const repo = location.pathname.split("/").filter(Boolean)[0];
  if (!owner || !repo) return;
  const repositoryUrl = `https://github.com/${owner}/${repo}`;
  elements.repositoryLink.href = repositoryUrl;
  elements.repositoryLink.hidden = false;
  for (const link of elements.repositoryDocsLinks) {
    link.href = `${repositoryUrl}#quick-start`;
  }
}

function createTag(text) {
  const tag = document.createElement("span");
  tag.className = "tag";
  tag.textContent = text;
  return tag;
}

function categories() {
  const preferredOrder = ["sprite", "screen", "color", "transition"];
  const available = new Set(state.catalog.map((shader) => shader.category));
  return preferredOrder.filter((category) => available.has(category));
}

function renderFilters() {
  elements.filters.replaceChildren();
  const items = ["all", ...categories()];
  for (const category of items) {
    const button = document.createElement("button");
    button.type = "button";
    button.className = `filter-button${state.category === category ? " active" : ""}`;
    button.textContent = category === "all" ? "All" : category[0].toUpperCase() + category.slice(1);
    button.setAttribute("aria-pressed", String(state.category === category));
    button.addEventListener("click", () => {
      state.category = category;
      renderFilters();
      renderCatalog();
    });
    elements.filters.append(button);
  }
}

function matches(shader) {
  if (state.category !== "all" && shader.category !== state.category) return false;
  if (!state.query) return true;
  const haystack = [shader.name, shader.summary, shader.description, shader.category, ...shader.tags].join(" ").toLowerCase();
  return haystack.includes(state.query);
}

function openShader(shader, updateHash = true) {
  state.activeShader = shader;
  state.codeTab = "shader";

  elements.dialogPreview.src = shader.preview;
  elements.dialogPreview.alt = `${shader.name} shader preview`;
  elements.dialogCategory.textContent = `${shader.category} · ${shader.passes} pass`;
  elements.dialogTitle.textContent = shader.name;
  elements.dialogDescription.textContent = shader.description;

  elements.dialogTags.replaceChildren(...shader.tags.map(createTag));
  elements.uniformTable.replaceChildren();
  for (const uniform of shader.uniforms) {
    const row = document.createElement("tr");
    for (const value of [uniform.name, uniform.type, formatDefault(uniform.default), uniform.description]) {
      const cell = document.createElement("td");
      cell.textContent = value;
      row.append(cell);
    }
    elements.uniformTable.append(row);
  }

  elements.notesList.replaceChildren();
  elements.notesSection.hidden = shader.notes.length === 0;
  for (const note of shader.notes) {
    const item = document.createElement("li");
    item.textContent = note;
    elements.notesList.append(item);
  }

  updateCodeView();
  if (!elements.dialog.open) elements.dialog.showModal();
  document.body.classList.add("modal-open");
  if (updateHash) history.replaceState(null, "", `#${shader.id}`);
}

function closeDialog(updateHash = true) {
  if (elements.dialog.open) elements.dialog.close();
  state.activeShader = null;
  document.body.classList.remove("modal-open");
  if (updateHash) history.replaceState(null, "", `${location.pathname}${location.search}#catalog`);
}

function updateCodeView() {
  if (!state.activeShader) return;
  const code = state.codeTab === "shader" ? state.activeShader.shaderSource : state.activeShader.usageSource;
  elements.codeView.textContent = code;
  for (const tab of elements.codeTabs) {
    const active = tab.dataset.codeTab === state.codeTab;
    tab.classList.toggle("active", active);
    tab.setAttribute("aria-selected", String(active));
  }
}

function renderCatalog() {
  const filtered = state.catalog.filter(matches);
  elements.grid.replaceChildren();
  elements.emptyState.hidden = filtered.length !== 0;
  elements.resultCount.textContent = `${filtered.length} of ${state.catalog.length} shaders`;

  for (const shader of filtered) {
    const fragment = elements.template.content.cloneNode(true);
    const card = fragment.querySelector(".shader-card");
    const button = fragment.querySelector(".card-open");
    const preview = fragment.querySelector(".card-preview");
    preview.src = shader.preview;
    preview.alt = `${shader.name} shader preview`;
    fragment.querySelector(".card-category").textContent = shader.category;
    fragment.querySelector(".card-title").textContent = shader.name;
    fragment.querySelector(".card-summary").textContent = shader.summary;
    const tagContainer = fragment.querySelector(".card-tags");
    shader.tags.slice(0, 3).forEach((tag) => tagContainer.append(createTag(tag)));
    button.setAttribute("aria-label", `View ${shader.name} shader`);
    button.addEventListener("click", () => openShader(shader));
    card.dataset.shaderId = shader.id;
    elements.grid.append(fragment);
  }
}

async function copyActiveCode() {
  if (!state.activeShader) return;
  const code = state.codeTab === "shader" ? state.activeShader.shaderSource : state.activeShader.usageSource;
  try {
    await navigator.clipboard.writeText(code);
    const previous = elements.copyCode.textContent;
    elements.copyCode.textContent = "Copied";
    window.setTimeout(() => { elements.copyCode.textContent = previous; }, 1400);
  } catch {
    const range = document.createRange();
    range.selectNodeContents(elements.codeView);
    const selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
  }
}

function handleHash() {
  const id = location.hash.slice(1);
  if (!id || id === "catalog" || id === "top") return;
  const shader = state.catalog.find((item) => item.id === id);
  if (shader) openShader(shader, false);
}

async function init() {
  inferRepositoryLink();
  const response = await fetch("data/catalog.json");
  if (!response.ok) throw new Error(`Catalog request failed: ${response.status}`);
  state.catalog = await response.json();
  elements.shaderCount.textContent = state.catalog.length;
  renderFilters();
  renderCatalog();
  handleHash();
}

elements.search.addEventListener("input", (event) => {
  state.query = event.currentTarget.value.trim().toLowerCase();
  renderCatalog();
});

elements.dialogClose.addEventListener("click", () => closeDialog());
elements.dialog.addEventListener("click", (event) => {
  if (event.target === elements.dialog) closeDialog();
});
elements.dialog.addEventListener("cancel", (event) => {
  event.preventDefault();
  closeDialog();
});
elements.copyCode.addEventListener("click", copyActiveCode);
elements.codeTabs.forEach((tab) => {
  tab.addEventListener("click", () => {
    state.codeTab = tab.dataset.codeTab;
    updateCodeView();
  });
});
window.addEventListener("hashchange", handleHash);

init().catch((error) => {
  console.error(error);
  elements.resultCount.textContent = "Catalog failed to load";
  elements.emptyState.hidden = false;
  elements.emptyState.querySelector("h3").textContent = "The shader catalog could not be loaded.";
  elements.emptyState.querySelector("p").textContent = "Serve the docs directory over HTTP rather than opening index.html directly.";
});
