ROOT_PATH := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

test: baseos
	PACKER_LOG=1 CHECKPOINT_DISABLE=1 \
	packer build -var-file $(ROOT_PATH)variables.json \
		$(ROOT_PATH)baseos-test.json > $(ROOT_PATH)baseos-build-tests.log; \
		case "$$?" in \
			0) \
				echo "Test finished successfully." \
			;; \
			*) \
				echo "Error while testing baseOS image."; \
				echo "Check: $(ROOT_PATH)baseos-build-test.log"; \
				exit 1 \
			;; \
		  esac

baseos: baseos.json
	PACKER_LOG=1 CHECKPOINT_DISABLE=1 \
	packer build  -var-file $(ROOT_PATH)variables.json \
		$(ROOT_PATH)baseos.json > $(ROOT_PATH)baseos-build.log; \
		case "$$?" in \
			0) \
				echo "BaseOS image created." \
			;; \
			*) \
				echo "Error building baseOS image."; \
				echo "Check: $(ROOT_PATH)baseos-build.log"; \
				exit 1 \
			;; \
		  esac

clean:
	rm -rf $(ROOT_PATH)output-baseos*
	rm -f $(ROOT_PATH)baseos-build*.log
	rm -rf $(ROOT_PATH)packer_cache

.PHONY: test baseos clean
