.PHONY: start
start:
	HUGO_MODULE_WORKSPACE=hugo.work hugo server --disableLiveReload --minify --gc -D

.PHONY: public
public:
	HUGO_MODULE_WORKSPACE=hugo.work hugo

.PHONY: update
update:
	env HUGO_MODULE_PROXY=https://goproxy.cn hugo mod get

.PHONY: tidy
tidy:
	hugo mod tidy

.PHONY: pack
pack:
	HUGO_MODULE_WORKSPACE=hugo.work hugo mod npm pack

.PHONY: search
search:
	HUGO_MODULE_WORKSPACE=hugo.work hugo
	algolia objects import hugo_theme_seven_demo -F ./public/algolia.ndjson -p 'seven demo'

.PHONY: install
install:
	npm install
	