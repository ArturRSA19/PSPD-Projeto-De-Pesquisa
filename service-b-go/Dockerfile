FROM golang:1.22-alpine AS builder
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o /bin/service-b .

FROM alpine:3.19
RUN addgroup -S app && adduser -S app -G app
COPY --from=builder /bin/service-b /bin/service-b
USER app
EXPOSE 50052
ENTRYPOINT ["/bin/service-b"]
