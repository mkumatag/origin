#!/bin/bash

# This script builds the base and release images for use by the release build and image builds.

STARTTIME=$(date +%s)
source "$(dirname "${BASH_SOURCE}")/lib/init.sh"

PLATFORM=$(os::build::host_platform)

oc="$(os::build::find-binary oc ${OS_ROOT})"
if [[ -z "${oc}" ]]; then
  "${OS_ROOT}/hack/build-go.sh" cmd/oc
  oc="$(os::build::find-binary oc ${OS_ROOT})"
fi

function build() {
  DOCKERFILE=${3:-}
  eval "'${oc}' ex dockerbuild $2 $1 ${DOCKERFILE} ${OS_BUILD_IMAGE_ARGS:-}"
}

# Build the images
if [[ $PLATFORM == "linux/ppc64le" ]]; then
  build openshift/origin-base                   "${OS_ROOT}/images/base"       --dockerfile="${OS_ROOT}/images/base/Dockerfile.ppc64le"
  build openshift/origin-release               "${OS_ROOT}/images/release"   --dockerfile="${OS_ROOT}/images/release/Dockerfile.ppc64le"
else
  build openshift/origin-base                   "${OS_ROOT}/images/base"
  build openshift/origin-release               "${OS_ROOT}/images/release"
fi

build openshift/origin-haproxy-router-base    "${OS_ROOT}/images/router/haproxy-base"

ret=$?; ENDTIME=$(date +%s); echo "$0 took $(($ENDTIME - $STARTTIME)) seconds"; exit "$ret"
