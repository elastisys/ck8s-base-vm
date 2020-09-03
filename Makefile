ROOT_PATH := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

all: build test

build:
	rm -rf $(ROOT_PATH)output-baseos*
	PACKER_LOG=1 CHECKPOINT_DISABLE=1 $(ROOT_PATH)main.sh build

test:
	PACKER_LOG=1 CHECKPOINT_DISABLE=1 $(ROOT_PATH)main.sh test

clean:
	rm -rf $(ROOT_PATH)output-baseos*
	rm -f $(ROOT_PATH)baseos*.log
	rm -rf $(ROOT_PATH)packer_cache

.PHONY: build test clean
