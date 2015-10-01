default: plc49.bin

env:
	./prepare_nodemcu_env.sh

rootfs: env
	./build-fs-dir.sh

plc49.bin: env rootfs
	./build-plc49.sh

flash: plc49.bin
	./flash.sh

upload: rootfs
	./upload.sh 0

upload-update: rootfs
	./upload.sh 1
