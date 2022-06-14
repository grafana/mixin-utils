#!/usr/bin/env bash

source /common.sh

if [[ ! -d "${root_path}" ]]; then
  echo "Nothing found at ${root_path}. Did you add -v \$(pwd):/var/lib/mixin to your docker command?"
  exit
fi

case "${1}" in
  mixin)
    case "${2}" in
      show)
        prep_mixin "${@:3}"
        show_mixin;;
      *)
        echo "Mixin Usage";;
    esac;;
  integrations)
    case "${2}" in
      list)
        list_cloud_integrations;;
      download)
        download_cloud_integration "${@:3}";;
      show)
        download_cloud_integration "${@:3}" &&
        relpath=$(integ_relative_path "${@:3}")
        prep_mixin "${relpath}"
        show_mixin;;
      *)
        echo "Integrations Usage";;
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
    echo "Usage";;
esac