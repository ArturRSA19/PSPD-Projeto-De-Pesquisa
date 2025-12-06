PROTO_DIR=../proto
PROTO_FILE=$(PROTO_DIR)/users.proto
OUT_DIR=pspd

all: proto build

proto:
	protoc -I $(PROTO_DIR) --go_out=$(OUT_DIR) --go-grpc_out=$(OUT_DIR) $(PROTO_FILE)

build:
	mkdir -p bin
	go build -o bin/service-b .

run: all
	./bin/service-b

clean:
	rm -rf $(OUT_DIR) bin
