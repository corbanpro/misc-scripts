#!/bin/bash

# Check if a folder argument is provided
if [ -z "$1" ]; then
	argerr gentest
	echo "USAGE: gentest <folder_path>"
	exit 1
fi

# Use current working directory if "." is provided
if [ "$1" == "." ]; then
	FOLDER_PATH=$(pwd)
else
	FOLDER_PATH="$1"
fi

# if the folder doesn't exist, exit 1
if [ ! -d "$FOLDER_PATH" ]; then
	echo "Folder $FOLDER_PATH does not exist"
	exit 1
fi

# Get the folder's base name
BASENAME=$(basename "$FOLDER_PATH")
LOWER_BASENAME="$(echo "$BASENAME" | tr '[:upper:]' '[:lower:]')"
PACKAGE_NAME="${LOWER_BASENAME}_test"
TEST_NAME="$(tr '[:lower:]' '[:upper:]' <<<${BASENAME:0:1})${BASENAME:1}"

TEST_FILE="${FOLDER_PATH}/${BASENAME}_test.go"

# if the test file already exists, exit 1
if [ -f "$TEST_FILE" ]; then
	echo "Test file $TEST_FILE already exists"
	exit 1
fi

# Create the test file with content
cat >"$TEST_FILE" <<EOF
package ${PACKAGE_NAME}

import (
	"context"
	"testing"

	"github.com/jmoiron/sqlx"
	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
	"github.com/signalscode/go-shared/pkg/auth"
	"github.com/signalscode/go-shared/pkg/sctx"
	"github.com/signalscode/go-shared/pkg/testkit"
)

var (
	db          *sqlx.DB
	dm          daom.DAOManager
	allPermsCtx context.Context
	noPermsCtx  context.Context
)

func Test${TEST_NAME}(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "${TEST_NAME} Suite")
}

var _ = BeforeSuite(func() {
	var err error
	db, err = test.DbConnect(context.Background())
	Expect(err).To(BeNil())

	dm = daom.NewDAOManager()

	user := auth.NewUser()
	user.ID = 1
	user.TenantID = 1
	user.AdminResourcePerms = auth.DebugAllPerms()
	allPermsCtx = testkit.NewContext(testkit.NewContextOptions{
		User: user,
		DBs:  []sctx.Queryable{db},
	})

	noPermsUser := auth.NewUser()
	noPermsUser.ID = 1
	noPermsUser.TenantID = 1
	noPermsCtx = testkit.NewContext(testkit.NewContextOptions{
		User: noPermsUser,
		DBs:  []sctx.Queryable{db},
	})
})

var _ = BeforeEach(func() {
	_, tx, err := sctx.BeginTx(allPermsCtx)
	Expect(err).To(BeNil())
	allPermsCtx = sctx.WithDBs(allPermsCtx, []sctx.Queryable{tx})
	noPermsCtx = sctx.WithDBs(noPermsCtx, []sctx.Queryable{tx})

	DeferCleanup(func() {
		Expect(tx.Rollback()).To(BeNil())
	})
})

var _ = Describe("${TEST_NAME}", func() {
	BeforeEach(func() {
	})
	AfterEach(func() {
	})
	Expect(1).To(Equal(1))
})
EOF

goimports -w "$TEST_FILE"

echo "Generated test file: $TEST_FILE"
