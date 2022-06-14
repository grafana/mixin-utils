#!/usr/bin/env bash

root_path="/var/lib/mixin"

fix_fs_perms() {
  local abs_path
  local hostuid
  local hostgid
  abs_path="${1}"
  hostuid=$(ls -nd "${root_path}" | awk '{ print $3 }')  
  hostgid=$(ls -nd "${root_path}" | awk '{ print $4 }')

  chown "${hostuid}:${hostgid}" "${abs_path}"
}

# Cloud integrations stuff
fetch_cloud_integration_list() {
  curl -Ls https://storage.googleapis.com/storage/v1/b/cloud-integration-releases/o  
}

list_cloud_integrations() {
  fetch_cloud_integration_list | jq -r '.items[].name'
}

integ_relative_path() {
  local integ_file
  local relative_path
  integ_file="${1}"
  relative_path="${2}"
  if [[ -z "${relative_path}" ]]
  then
    basename "${integ_file}" .zip
  else
    echo "${relative_path}"
  fi
}

download_cloud_integration() {
  local ilist
  local dluri
  local integ_file
  local relative_path

  integ_file="${1}"
  relative_path=$(integ_relative_path "${@}")
  abs_path="${root_path}/${relative_path}"

  echo "Downloading cloud integration file '${integ_file}' to (${relative_path})..."

  ilist=$(fetch_cloud_integration_list)  
  dluri=$(echo "${ilist}" | jq -r ".items[] | select(.name == \"${integ_file}\") | .mediaLink")
  if [[ -z "${dluri}" ]]
  then
    echo "No cloud integration named ${integ_file} found. Available cloud integrations are.."
    echo "${ilist}" | jq -r '.items[].name'
  else
    if [[ -d "${abs_path}" ]]
    then
      echo "The integration '${integ_file}' has already been downloaded to (${relative_path}). Cowardly refusing to overwrite it."
      exit
    else
      curl -Ls -o "/tmp/${integ_file}" "${dluri}"
      unzip -q -d "${abs_path}" "/tmp/${integ_file}"
      fix_fs_perms "${abs_path}"
    fi
  fi
}

# Mixin stuff
prep_mixin() {
  local relative_path
  relative_path="${1}"
  rm -rf /tmp/mixin
  mkdir -p /tmp/mixin
  cp -R "${root_path}/${relative_path}/"* "/tmp/mixin/"
  # TODO: Total, awful, hideous hack for cloud integrations that have this one weird dependency. See comment in included file.
  cp /util.libsonnet /tmp/
  cd /tmp/mixin || exit
  jb install
}

show_mixin() {
  grr show /tmp/mixin/mixin.libsonnet
}