test: 
	PACKER_LOG=1 CHECKPOINT_DISABLE=1 packer build -only=baseos-test centos-7.json > baseos-build-tests.log

baseos:
	PACKER_LOG=1 CHECKPOINT_DISABLE=1 packer build -only=baseos centos-7.json > baseos-build.log; \
		case "$$?" in \
			0) \
			echo "BaseOS CentOS 7 image created." \
			;; \
			1) \
			echo "Image build directory is already present. Run make clean to remove all previous artefacts." \
			;; \
			*) \
			echo "Error while building BaseOS image, check baseos-build.log" \
			;; \
		  esac;

clean:
	rm -rf output-baseos*
	rm baseos-*.log
