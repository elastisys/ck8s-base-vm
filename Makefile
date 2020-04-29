ROOT_PATH := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

all: build test

build:
	PACKER_LOG=1 CHECKPOINT_DISABLE=1 $(ROOT_PATH)main.sh build

test:
	PACKER_LOG=1 CHECKPOINT_DISABLE=1 $(ROOT_PATH)main.sh test

clean:
	rm -rf $(ROOT_PATH)output-baseos*
	rm -f $(ROOT_PATH)baseos*.log
	rm -rf $(ROOT_PATH)packer_cache
	rm -rf /tmp/ck8s-base-vm-checksums

.PHONY: build test clean
