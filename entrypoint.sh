#!/usr/bin/env bash

source /common.sh

OPTIND=1
while getopts ":f:n:" opt;
do
  case "${opt}" in
    f)
      # TODO: This is a global that gets set, and evaluated in several places. There's probably a more elegant way to do this.
      DASHBOARD_FOLDER="${OPTARG}";;
    n)
      RULE_NAMESPACE="${OPTARG}";;
  esac
done
shift "$((OPTIND-1))"

case "${1}" in
  mixin)
    # Mixins are always mapped as a volume to ${root_path}
    if [[ ! -d "${root_path}" ]]; then
      echo "Nothing found at ${root_path}. Did you add -v \$(pwd):/var/lib/mixin to your docker command?"
      exit
    fi
    case "${2}" in
      show)
        prep_mixin "${@:3}"
        show_mixin;;
      install)      
        prep_mixin "${@:3}"
        install_mixin;;        
      *)
        mixin_usage;;
    esac;;
  integrations)
    # Since we're often performing atomic actions like show, or install, it's fine if there is no volume mapped to ${root_path}
    if [[ ! -d "${root_path}" ]]; then
      mkdir -p "${root_path}"
    fi
    case "${2}" in
      list)
        list_cloud_integrations;;
      download)
        download_cloud_integration "${@:3}";;
      show)
        download_cloud_integration "${@:3}"
        relpath=$(integ_relative_path "${@:3}")
        if [[ -z "${DASHBOARD_FOLDER}" ]]
        then
          DASHBOARD_FOLDER=$(integration_metadata "${root_path}/${relpath}" dashboard_folder)
        fi
        if [[ -z "${RULE_NAMESPACE}" ]]
        then
          RULE_NAMESPACE=$(integration_metadata "${root_path}/${relpath}" rule_namespace)
        fi
        prep_mixin "${relpath}"
        show_mixin;;
      install)
        download_cloud_integration "${@:3}"
        relpath=$(integ_relative_path "${@:3}")
        if [[ -z "${DASHBOARD_FOLDER}" ]]
        then
          DASHBOARD_FOLDER=$(integration_metadata "${root_path}/${relpath}" dashboard_folder)
        fi
        if [[ -z "${RULE_NAMESPACE}" ]]
        then
          RULE_NAMESPACE=$(integration_metadata "${root_path}/${relpath}" rule_namespace)
        fi
        prep_mixin "${relpath}"
        install_mixin;;
      *)
        integrations_usage;;
    esac;;
  mixtool)
    mixtool "${@:2}";;
  grr)
    grr "${@:2}";;
  jsonnet)
    jsonnet "${@:2}";;
  jb)
    jb "${@:2}";;
  *)
    usage;;
esac