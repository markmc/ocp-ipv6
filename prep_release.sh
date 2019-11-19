#!/usr/bin/env bash
set -xe

#
# Prepare a new release payload based on a supplied payload pullspec
#
# See config.sh for required configuration steps
#
source common.sh

RELEASE_NAME="$1"; shift || true
RELEASE_PULLSPEC="$1"; shift || true
if [ -z "${RELEASE_NAME}" -o -z "${RELEASE_PULLSPEC}" ]; then
    echo "usage: $0 <release name> <release pullspec> [<tag>=<pullspec> <tag>=<pullspec>]" >&2
    echo "example: $0 4.3.0-0.ci-2019-11-01-112322-ipv6.1 registry.svc.ci.openshift.org/ocp/release:4.3.0-0.ci-2019-11-01-112322 machine-config-operator=..." >&2
    exit 1
fi

EXTRA_IMAGES=("$@")
for extra in "${EXTRA_IMAGES[@]}"; do
  if [ -z "${extra%=*}" -o -z "${extra#*=}" ]; then
      echo "Extra image parameters take the form <name>=<pullspec>" >&2
  fi
done

# Fetch the release version from payload metadata
RELEASE_VERSION=$(oc adm release info --registry-config "${IPV6_PULLSECRET}" "${RELEASE_PULLSPEC}" -o json | jq -r .metadata.version)
if [ -z "${RELEASE_VERSION}" -o "${RELEASE_VERSION}" = "null" ]; then
    echo "Could find version metadata in ${RELEASE_PULLSPEC}" >&2
    exit 1
fi

echo "Preparing a ${RELEASE_NAME} release based on version ${RELEASE_VERSION}"

# Check prerequisites
if [ $(oc --config "${IPV6_KUBECONFIG}" project -q) != "${IPV6_NAMESPACE}" ]; then
    echo "Wrong namespace configured, run 'oc --config ${IPV6_KUBECONFIG} project ${IPV6_NAMESPACE}'" >&2
    exit 1
fi

if ! oc --config "${IPV6_KUBECONFIG}" get imagestream "${IPV6_RELEASE_STREAM}" 2>/dev/null; then
    echo "No '${IPV6_RELEASE_STREAM}' imagestream in '${IPV6_NAMESPACE}' namespace" >&2
    exit 1
fi

RELEASE_REPO=$(oc --config "${IPV6_KUBECONFIG}" get imagestream "${IPV6_RELEASE_STREAM}" -o json | jq -r .status.publicDockerImageRepository)
if [ -z "${RELEASE_REPO}" -o "${RELEASE_REPO}" = "null" ]; then
    echo "No public repository URL found for ${IPV6_NAMESPACE}/${IPV6_RELEASE_STREAM}" >&2
    exit 1
fi

RELEASE_TMPDIR=$(mktemp --tmpdir -d "release-${RELEASE_VERSION}-XXXXXXXXXX")
trap "rm -rf ${RELEASE_TMPDIR}" EXIT

# extract image-references
oc adm release extract --registry-config "${IPV6_PULLSECRET}" --from "${RELEASE_PULLSPEC}" --file image-references > "${RELEASE_TMPDIR}/image-references"

# create new image stream from image-references
oc --config "${IPV6_KUBECONFIG}" apply -f "${RELEASE_TMPDIR}/image-references"
if ! oc --config "${IPV6_KUBECONFIG}" get imagestream "${RELEASE_VERSION}" 2>/dev/null; then
    echo "Expected '${RELEASE_VERSION}' imagestream?" >&2
    exit 1
fi
rm -f "${RELEASE_TMPDIR}/image-references"

function wait_for_tag() {
    local is
    local tag

    is="$1"
    tag="$2"

    while true; do
        got=$(oc --config "${IPV6_KUBECONFIG}" get imagestream "${is}" -o json | jq -r '.status.tags[]? | select(.tag == "'"${tag}"'") | .items[0].image')
        [ -n "${got}" ] && break
        sleep 2
    done
}

# Tag the extra images into the image stream
for extra in "${EXTRA_IMAGES[@]}"; do
  extra_name="${extra%=*}"
  extra_pullspec="${extra#*=}"

  oc --config "${IPV6_KUBECONFIG}" tag "${extra_pullspec}" "${RELEASE_VERSION}:${extra_name}"
  wait_for_tag "${RELEASE_VERSION}" "${extra_name}"
done

# create the new release payload
oc --config "${IPV6_KUBECONFIG}" adm release new \
    --name "${RELEASE_NAME}" \
    --registry-config "${IPV6_PULLSECRET}" \
    --from-image-stream "${RELEASE_VERSION}" \
    --reference-mode source \
    --to-image "${RELEASE_REPO}:${RELEASE_NAME}"

echo "New ${RELEASE_NAME} release payload available to ${RELEASE_REPO}:${RELEASE_NAME}"
