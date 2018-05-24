#!/bin/bash -e

KERNELIMAGE=$HOME/example_build.bzImage
IRFSIMAGE=$HOME/example_build.rootfs.cpio.gz
DISKIMAGE=$HOME/example_build.hddimg

dockerimage=kvmtest

docker run -ti --rm --privileged \
	-v $KERNELIMAGE:/mnt/kernel/bzImage \
	-v $IRFSIMAGE:/mnt/initrd/initrd \
	-v $DISKIMAGE:/image/image \
	\
	-e BYO_MEMORY=2048 \
	-e BYO_KERNEL=/mnt/kernel/bzImage \
	-e BYO_INITRD=/mnt/initrd/initrd \
	\
	-e AUTO_ATTACH=yes \
	--entrypoint /usr/local/bin/startvm \
	$dockerimage
