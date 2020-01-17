# Copyright 2017 Google Inc.
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


PKG=github.com/slamdev/k8s-multicluster-ingress
COVERPROFILE=combined.coverprofile

# So that make test is not confused with the test directory.
.PHONY: test

fmt:
	@echo "+ $@"
	@./scripts/check-gofmt.sh

lint:
	@echo "+ $@"
	@./scripts/check-golint.sh

vet:
	@echo "+ $@"
	@go vet $(shell go list ${PKG}/... | grep -v vendor)

test:
	@echo "+ $@"
	@go test -race -tags "cgo" $(shell go list ${PKG}/... | grep -v vendor)

test-all: fmt lint vet test

cover:
	@echo "+ $@"
	@go test \
		-coverprofile=${COVERPROFILE} \
		-coverpkg=$(shell go list ${PKG}/... | xargs | sed -e 's/ /,/g') \
		${PKG}/...

coveralls:
	@echo "+ $@"
	@make cover
# Make sure goveralls is installed.
	@go get github.com/mattn/goveralls
# Send coverage report to Goveralls
	@CI_NAME="prow" CI_BUILD_NUMBER=${BUILD_ID} CI_BRANCH=${PULL_BASE_REF} CI_PULL_REQUEST=${PULL_NUMBER} goveralls \
		-repotoken $(shell cat /etc/coveralls-token/coveralls.txt) \
		-service="prow" \
		-coverprofile=${COVERPROFILE}

build:
	go build -mod vendor -a -installsuffix cgo ./cmd/kubemci/kubemci.go
