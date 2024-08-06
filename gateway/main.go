package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strings"
	"sync"
)

func main() {
    http.HandleFunc("/", handleRequest)
    http.ListenAndServe(":8080", nil)
}

func handleRequest(w http.ResponseWriter, r *http.Request) {
    partyNodes := strings.Split(os.Getenv("PARTY_NODES"), ",")
    var wg sync.WaitGroup
    responses := make([]string, len(partyNodes))

    for i, node := range partyNodes {
        wg.Add(1)
        go func(i int, url string) {
            defer wg.Done()
            resp, err := http.Post(url, "application/json", bytes.NewBuffer([]byte(`{"message":"hello"}`)))
            if err != nil {
                responses[i] = fmt.Sprintf("Error: %v", err)
                return
            }
            defer resp.Body.Close()
            body, _ := ioutil.ReadAll(resp.Body)
            responses[i] = string(body)
        }(i, node)
    }

    wg.Wait()

    json.NewEncoder(w).Encode(responses)
}
