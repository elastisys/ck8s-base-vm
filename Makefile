test: baseos
	PACKER_LOG=1 CHECKPOINT_DISABLE=1 packer build -only=baseos-test baseos.json > baseos-build-tests.log; \
		case "$$?" in \
			0) \
			echo "Test finished successfully." \
			;; \
			*) \
			echo "Error while testing baseOS image, check baseos-build-test.log" \
			;; \
		  esac;


baseos: baseos.json
	PACKER_LOG=1 CHECKPOINT_DISABLE=1 packer build -only=baseos baseos.json > baseos-build.log; \
		case "$$?" in \
			0) \
			echo "BaseOS image created." \
			;; \
			*) \
			echo "Error while building baseOS image, check baseos-build.log" \
			;; \
		  esac;

clean:
	rm -rf output-baseos*
	rm -f baseos-build*.log
	rm -rf packer_cache
