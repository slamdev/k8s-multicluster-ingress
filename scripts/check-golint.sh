#!/bin/bash

# Copyright 2018 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e
set -u
set -o pipefail

# Set a GOBIN to install golint.
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE}")/.." && pwd -P)"
export GOBIN="${ROOT_DIR}/_output/local/bin"
PATH="${GOBIN}:${PATH}"

# Install golint from vendor/...
go get -u golang.org/x/lint/golint

diff=$(find . -name "*.go"| grep -v "/vendor/" | xargs -L 1 golint)
if [ -n "${diff}" ]; then
  echo -e "golint failed:\n${diff}"
  exit 1
fi
