#!/usr/bin/env bash
set -euo pipefail

PYTHON_BIN=${PYTHON_BIN:-$(command -v python3 || true)}
if [ -z "${PYTHON_BIN}" ]; then
	PYTHON_BIN=$(command -v python || true)
fi
if [ -z "${PYTHON_BIN}" ]; then
	echo "[ERRO] Python não encontrado. Instale com: brew install python@3 (macOS)" >&2
	exit 1
fi

if ! command -v protoc >/dev/null 2>&1; then
	echo "[ERRO] protoc não encontrado. Instale (Homebrew): brew install protobuf" >&2
	exit 1
fi

echo "Usando Python: $(${PYTHON_BIN} --version 2>&1)"
echo "Gerando stubs Python..."
${PYTHON_BIN} -m grpc_tools.protoc -I proto --python_out=service-a-python --grpc_python_out=service-a-python proto/users.proto

if ! command -v go >/dev/null 2>&1; then
	echo "[AVISO] Go não encontrado. Pulando geração dos stubs Go (service B)."
	echo "         Instale Go (https://go.dev/dl/) e re-execute para gerar o service-b-go."
else
	# Garante que GOPATH/bin está no PATH
	GOBIN_DIR=$(go env GOPATH)/bin
	export PATH="$GOBIN_DIR:$PATH"

	if ! command -v protoc-gen-go >/dev/null 2>&1; then
		echo "Instalando protoc-gen-go..."
		go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	fi
	if ! command -v protoc-gen-go-grpc >/dev/null 2>&1; then
		echo "Instalando protoc-gen-go-grpc..."
		go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
	fi

	echo "Gerando stubs Go..."
	pushd service-b-go >/dev/null
	mkdir -p pspd
	protoc -I ../proto --go_out=pspd --go-grpc_out=pspd ../proto/users.proto
	popd >/dev/null
fi

echo "Geração concluída."