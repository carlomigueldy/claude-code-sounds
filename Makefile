.PHONY: test lint validate check

test:
	bash tests/run-all.sh

lint:
	shellcheck dispatcher.sh claude-sounds install.sh uninstall.sh

validate:
	jq empty sounds-config.default.json
	@find packs -name pack.json -exec jq empty {} +

check: validate lint test
