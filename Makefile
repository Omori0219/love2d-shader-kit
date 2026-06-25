.PHONY: validate build previews demo package

validate:
	python3 scripts/validate.py
	python3 scripts/build_catalog.py --check

build:
	python3 scripts/build_catalog.py

previews:
	python3 scripts/generate_previews.py
	python3 scripts/build_catalog.py

demo:
	love .

package:
	python3 scripts/package_demo.py
