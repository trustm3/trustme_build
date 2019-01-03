#!/bin/bash
#
# This file is part of trust|me
# Copyright(c) 2013 - 2017 Fraunhofer AISEC
# Fraunhofer-Gesellschaft zur Förderung der angewandten Forschung e.V.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms and conditions of the GNU General Public License,
# version 2 (GPL 2), as published by the Free Software Foundation.
#
# This program is distributed in the hope it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GPL 2 license for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, see <http://www.gnu.org/licenses/>
#
# The full GNU General Public License is included in this distribution in
# the file called "COPYING".
#
# Contact Information:
# Fraunhofer AISEC <trustme@aisec.fraunhofer.de>
#

SRC_DIR=$(pwd)
BUILD_DIR=${SRC_DIR}/$1
DEVICE=$2

METAS="\
	meta-intel \
	meta-openembedded/meta-oe \
	meta-openembedded/meta-python \
	meta-openembedded/meta-networking \
	meta-openembedded/meta-perl \
	meta-virtualization \
	meta-selinux \
	meta-trustx"

if [ -z ${DEVICE} ]; then
	echo "\${DEVICE} not set, falling back to \"x86\""
	DEVICE=x86
fi

SKIP_CONFIG=0
if [ -d ${BUILD_DIR} ]; then
	SKIP_CONFIG=1
fi

source ${SRC_DIR}/poky/oe-init-build-env ${BUILD_DIR}
# will change to build dir

if [ ${SKIP_CONFIG} != 1 ]; then

	for layer in ${METAS}; do
		echo adding layer ${SRC_DIR}/${layer}
		if [ ${layer} == "meta-virtualization" ]; then
			echo "DISTRO_FEATURES_append = \" virtualization\"" >> ${BUILD_DIR}/conf/local.conf
		fi
		bitbake-layers add-layer ${SRC_DIR}/${layer}
	done

	echo appending local.conf for DEVICE="${DEVICE}"
	cat ${SRC_DIR}/trustme/build/yocto/${DEVICE}/local.conf >> ${BUILD_DIR}/conf/local.conf
	mkdir -p ${BUILD_DIR}/conf/multiconfig
	cp -rv ${SRC_DIR}/trustme/build/yocto/${DEVICE}/multiconfig ${BUILD_DIR}/conf/
# uncomment this an replay user/path to your local fork for development
fi

echo "SRC_URI = \"git:///${SRC_DIR}/trustme/cml/;protocol=file;branch=\${BRANCH}\"" >  ${BUILD_DIR}/cmld_git.bbappend
ln -s ${BUILD_DIR}/cmld_git.bbappend ${SRC_DIR}/meta-trustx/recipes-trustx/cmld/
ln -s ${BUILD_DIR}/cmld_git.bbappend ${SRC_DIR}/meta-trustx/recipes-trustx/service/service_git.bbappend
ln -s ${BUILD_DIR}/cmld_git.bbappend ${SRC_DIR}/meta-trustx/recipes-trustx/service/service-static_git.bbappend
