#!/bin/bash

# Check if a folder argument is provided
if [ -z "$1" ]; then
	echo "Usage: $0 <folder_path>"
	exit 1
fi

# Use current working directory if "." is provided
if [ "$1" == "." ]; then
	FOLDER_PATH=$(pwd)
else
	FOLDER_PATH="$1"
fi

# Get the folder's base name
BASENAME=$(basename "$FOLDER_PATH")
PACKAGE_NAME="${BASENAME}_test"
TEST_NAME="$(tr '[:lower:]' '[:upper:]' <<<${BASENAME:0:1})${BASENAME:1}"

TEST_FILE="${FOLDER_PATH}/${BASENAME}_test.go"

# Create the test file with content
cat >"$TEST_FILE" <<EOF
package ${PACKAGE_NAME}

import (
	"testing"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

func Test${TEST_NAME}(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "${TEST_NAME} Suite")
}

var _ = Describe("${TEST_NAME}", func() {
	BeforeEach(func() {
	})
	AfterEach(func() {
	})
	Expect(1).To(Equal(1))
})
EOF

echo "Generated test file: $TEST_FILE"
