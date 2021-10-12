SHELL := /bin/bash
.DEFAULT_GOAL := help

help: # Shows information about all the make commands
	@grep -E '^([a-zA-Z_-]|\s)+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

clean: ## Deletes all swift files
	@rm -f ./*.swift

setup: ## Installs the protoc compiler with the swift plugin
	@brew install swift-protobuf

convert: clean ## Converting .proto files into Swift 
	@protoc --swift_out=. pretix_sig1.proto