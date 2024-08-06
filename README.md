# go-vendor-generator

## 사용 목적

- 폐쇄망 환경에서 go 패키지 라이브러리 업데이트를 하기 위한 도구
- 원래 방식이라면 아래와 같은 순서로 진행해야 하므로, 보안상 위반사례가 발생할 수 있음
    1. 소스 전체를 외부로 반출
    2. go mod tidy를 통한 업데이트
    3. go mod vendor를 통한 vendor 디렉토리 생성
    4. 내부로 반입 및 적용

- 본 파일을 이용하면 go.mod 파일만 가지고도 동일한 적용이 가능
    1. go.mod 파일 반출
    2. main-generator 실행
    3. go mod vendor를 통한 vendor 디렉토리 생성
    4. 내부로 반입 및 적용


## 이슈 

### 1. does not contain package

- 간혹 패키지 중 go mod tidy 실행시 아래와 같은 오류와 함께 패키지 다운로드가 불가능한 경우가 발생

```sh
# go.mod 파일 내부에 golang.org/x/crypto 라이브러리 존재
$ go mod tidy

> module golang.org/x/crypto@latest found (v0.25.0), but does not contain package golang.org/x/crypto
```

- 해결 방안
    - 생성된 main.go에서 실제로 사용하는 단위 레벨까지 import 대상을 지정해야 한다 (소스 레벨에서 직접 확인해야 함)
    - 실제로 go get -u golang.org/x/crypto@latest 실행 시 정상적으로 패키지를 다운로드 하는 것을 확인할 수 있음 -> 패키지의 문제는 아님
    - 실제로 사용하는 라이브러리 단위에 비해 다운로드 받아야 하는 단위가 너무 커서 발생하는 오류라고 예상


```sh
# 기존 go.mod 파일
require (
	github.com/IBM/sarama v1.42.1
	github.com/arsmn/fiber-swagger/v2 v2.31.1
	github.com/cenkalti/backoff/v4 v4.2.1
	github.com/ethereum/go-ethereum v1.12.0
	github.com/go-redsync/redsync/v4 v4.11.0
	github.com/goccy/go-json v0.10.2
	github.com/gofiber/fiber/v2 v2.50.0
	github.com/miguelmota/go-ethereum-hdwallet v0.1.1
	github.com/patrickmn/go-cache v2.1.0+incompatible
	github.com/pkg/errors v0.9.1
	github.com/redis/go-redis/v9 v9.3.0
	github.com/spf13/viper v1.17.0
	github.com/stretchr/testify v1.8.4
	github.com/swaggo/swag v1.16.2
	github.com/tyler-smith/go-bip39 v1.1.0
	golang.org/x/crypto v0.14.0
	gopkg.in/natefinch/lumberjack.v2 v2.0.0
	gorm.io/driver/postgres v1.5.3
	gorm.io/gorm v1.25.5
)
```

```go
package main

import (
	_ "github.com/IBM/sarama"
	_ "github.com/arsmn/fiber-swagger/v2"
	_ "github.com/cenkalti/backoff/v4"
	_ "github.com/ethereum/go-ethereum"
	_ "github.com/go-redsync/redsync/v4"
	_ "github.com/goccy/go-json"
	_ "github.com/gofiber/fiber/v2"
	_ "github.com/miguelmota/go-ethereum-hdwallet"
	_ "github.com/patrickmn/go-cache"
	_ "github.com/pkg/errors"
	_ "github.com/redis/go-redis/v9"
	_ "github.com/rs/zerolog"
	_ "github.com/spf13/viper"
	_ "github.com/stretchr/testify"
	_ "github.com/swaggo/swag"
	_ "github.com/tyler-smith/go-bip39"
    _ "golang.org/x/crypto"         // 기존에 생성되는 내용 -> 삭제 필요
	_ "golang.org/x/crypto/pbkdf2"  // 실제로 코드 상에서 사용하는 레벨까지 적용
	_ "golang.org/x/crypto/scrypt"  // 실제로 코드 상에서 사용하는 레벨까지 적용
	_ "golang.org/x/crypto/sha3"    // 실제로 코드 상에서 사용하는 레벨까지 적용
	_ "gopkg.in/natefinch/lumberjack.v2"
	_ "gorm.io/driver/postgres"
	_ "gorm.io/gorm"
)
```
