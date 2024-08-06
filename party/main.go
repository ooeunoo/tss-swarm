package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
)

func main() {
    http.HandleFunc("/", handleRequest)
    http.ListenAndServe(":8081", nil)
}

func handleRequest(w http.ResponseWriter, r *http.Request) {
    nodeNumber := os.Getenv("NODE_NUMBER")
    response := map[string]string{"message": fmt.Sprintf("bye(%s)", nodeNumber)}
    json.NewEncoder(w).Encode(response)
}
