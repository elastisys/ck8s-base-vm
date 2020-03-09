test: 
	PACKER_LOG=1 CHECKPOINT_DISABLE=1 packer build -only=baseos-test ubuntu1804.json > baseos-ubuntu1804-build-tests.log

baseos:
	PACKER_LOG=1 CHECKPOINT_DISABLE=1 packer build -only=baseos ubuntu1804.json > baseos-ubuntu1804-build.log; \
		case "$$?" in \
			0) \
			echo "BaseOS Ubuntu 1804 image created." \
			;; \
			1) \
			echo "Image build directory is already present. Run make clean to remove all previous artefacts." \
			;; \
			*) \
			echo "Error while building baseOS image, check baseos-build.log" \
			;; \
		  esac;

clean:
	rm -rf output-baseos*
	rm baseos-*.log
