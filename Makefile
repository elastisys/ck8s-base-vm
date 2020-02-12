test: baseos
	PACKER_LOG=1 CHECKPOINT_DISABLE=1 packer build -only=baseos-test baseos.json > baseos-build-tests.log

baseos: baseos.json
	PACKER_LOG=1 CHECKPOINT_DISABLE=1 packer build -only=baseos baseos.json > baseos-build.log; \
		case "$$?" in \
			0) \
			echo "BaseOS image created." \
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
	rm baseos-build*.log
