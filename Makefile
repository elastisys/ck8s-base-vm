test: baseos
	PACKER_LOG=1 CHECKPOINT_DISABLE=1 packer build -only=baseos-test baseos.json > baseos-build-tests.log

baseos: baseos.json
	PACKER_LOG=1 CHECKPOINT_DISABLE=1 packer build -only=baseos baseos.json > baseos-build.log; \
		case "$$?" in \
			0) \
			echo "Base image created." \
			;; \
			1) \
			echo "Image already present. Run make clean to remove all artefacts." \
			;; \
			*) \
			echo "Unhandled error" \
			;; \
		  esac;

clean:
	rm -rf output-baseos*
	rm baseos-build*.log
