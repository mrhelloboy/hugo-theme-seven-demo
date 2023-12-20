.PHONY: start
start:
	HUGO_MODULE_WORKSPACE=hugo.work hugo server --disableLiveReload --minify --gc -D

.PHONY: publish
publish:
	HUGO_MODULE_WORKSPACE=hugo.work hugo

.PHONY: pack
pack:
	HUGO_MODULE_WORKSPACE=hugo.work hugo mod npm pack

.PHONY: search
search:
	algolia objects import hugo_theme_seven_demo -F ./public/algolia.ndjson

.PHONY: install
install:
	npm install
	