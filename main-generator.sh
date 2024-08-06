#!/bin/bash

MODULE_NAME=$1

if [ -z "$MODULE_NAME" ]; then
    echo "Usage: $0 <module-name is required>"
    exit 1
fi

# go.mod 파일에서 패키지 목록 추출
# packages=$(grep -E '^\s*require\s+[^ ]+\s+' go.mod | awk '{print $2}')
# packages=$(go list -m -json all | jq -r 'select(.Path != "stplatform" and .Indirect != true) | .Path')
packages=$(go list -m -f '{{if not .Indirect}}{{.Path}}{{end}}' all | grep -v "^$MODULE_NAME\$")

# dummy.go 파일 생성
cat <<EOL > dummy.go
package main

import (
EOL

for pkg in $packages; do
    echo "    _ \"$pkg\"" >> main.go
done

cat <<EOL >> main.go
)

func main() {}
EOL

echo "dummy.go 파일이 생성되었습니다."
