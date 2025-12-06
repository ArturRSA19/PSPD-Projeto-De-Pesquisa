package main

import (
	"encoding/json"
	"log"
	"math/rand"
	"net/http"
	"os"
	"strconv"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

func main() {
	r := chi.NewRouter()
	r.Use(middleware.Logger)
	r.Get("/scores/{userId}", handleGetScore)
	r.Get("/healthz", handleHealth)

	port := os.Getenv("REST_STATS_PORT")
	if port == "" { port = "9002" }
	log.Printf("[REST-Stats] listening on :%s", port)
	if err := http.ListenAndServe(":"+port, r); err != nil {
		log.Fatalf("server error: %v", err)
	}
}

func handleGetScore(w http.ResponseWriter, r *http.Request) {
	userId := chi.URLParam(r, "userId")
	baseParam := r.URL.Query().Get("base")
	base := 10
	if baseParam != "" {
		if v, err := strconv.Atoi(baseParam); err == nil { base = v }
	}
	rand.Seed(time.Now().UnixNano())
	score := float64(base) * (0.5 + rand.Float64())
	resp := map[string]any{
		"user_id": userId,
		"score": score,
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func handleHealth(w http.ResponseWriter, _ *http.Request) {
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("ok"))
}
