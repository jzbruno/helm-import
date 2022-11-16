#!/usr/bin/env bash

set -euo pipefail

if [[ "${HELM_DEBUG}" == true ]]; then
    set -x
fi

msg="Usage: helm import RELEASE_NAME CHART [args...]"

if [[ " ${@} " =~ " -h " ]] || [[ "${#}" -eq 0 ]]; then
    echo "${msg}"
    exit 0
fi

release_name="${1:-""}"
if [[ -z "${release_name}" ]]; then
    echo "${msg}"
    echo "Error: no release name provided"
    exit 1
fi
chart="${2:-""}"
if [[ -z "${chart}" ]]; then
    echo "${msg}"
    echo "Error: no chart provided"
    exit 1
fi
shift 2

echo "Adding annotations to all resources found by running template command ..."
echo ${HELM_BIN} template "${release_name}" "${chart}" ${@}
echo " "
${HELM_BIN} template "${release_name}" "${chart}" ${@} | kubectl annotate -f- "meta.helm.sh/release-name=${release_name}" "meta.helm.sh/release-namespace=${HELM_NAMESPACE}" --overwrite || true
echo " "

echo "Adding labels to all resources found by running template command ..."
echo ${HELM_BIN} template "${release_name}" "${chart}" ${@}
echo " "
${HELM_BIN} template "${release_name}" "${chart}" ${@} | kubectl label -f- "app.kubernetes.io/managed-by=Helm" --overwrite || true
echo " "
