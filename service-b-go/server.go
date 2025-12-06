package main

import (
	"context"
	"log"
	"math/rand"
	"net"
	"time"
	"os"
	"fmt"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
	"service-b-go/pspd" // gerado por protoc (users.pb.go / users_grpc.pb.go)
)

type statsServiceServer struct {
	pspd.UnimplementedStatsServiceServer
}

// Unary
func (s *statsServiceServer) GetScore(ctx context.Context, req *pspd.ScoreRequest) (*pspd.ScoreResponse, error) {
	base := req.GetBase()
	if base == 0 { // default
		base = 10
	}
	score := float64(base) * (0.5 + rand.Float64())
	return &pspd.ScoreResponse{UserId: req.GetUserId(), Score: score}, nil
}

// Bidirectional streaming
func (s *statsServiceServer) StreamScores(stream pspd.StatsService_StreamScoresServer) error {
	for {
		req, err := stream.Recv()
		if err != nil {
			return err
		}
		base := req.GetBase()
		if base == 0 {
			base = 10
		}
		score := float64(base) * (0.5 + rand.Float64())
		if err := stream.Send(&pspd.ScoreResponse{UserId: req.GetUserId(), Score: score}); err != nil {
			return err
		}
		time.Sleep(150 * time.Millisecond)
	}
}

func main() {
	rand.Seed(time.Now().UnixNano())
	port := os.Getenv("STATS_PORT")
	if port == "" { port = "50052" }
	addr := fmt.Sprintf(":%s", port)
	lis, err := net.Listen("tcp", addr)
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	grpcServer := grpc.NewServer()
	pspd.RegisterStatsServiceServer(grpcServer, &statsServiceServer{})
	// Habilita reflection para facilitar debug (grpcurl list)
	reflection.Register(grpcServer)
	log.Printf("StatsService running on %s", addr)
	if err := grpcServer.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
