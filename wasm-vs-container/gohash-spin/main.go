package main

import (
	"crypto/sha512"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"

	spinhttp "github.com/fermyon/spin/sdk/go/v2/http"
)

func init() {
	spinhttp.Handle(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/health" {
			w.Header().Set("Content-Type", "text/plain")
			w.WriteHeader(http.StatusOK)
			return
		}
		if r.URL.Path == "/hash" {
			if r.Method != "POST" {
				http.Error(w, "Only POST requests are supported", http.StatusMethodNotAllowed)
				return
			}
			handleRequest(w, r)
			return
		}
		w.Header().Set("Content-Type", "text/plain")
		w.WriteHeader(http.StatusForbidden)
	})
}

func main() {}

type Data struct {
	Message string `json:"message"`
}

func handleRequest(w http.ResponseWriter, r *http.Request) {
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "Failed to read request body", http.StatusInternalServerError)
		return
	}

	var data Data
	if err := json.Unmarshal(body, &data); err != nil {
		http.Error(w, "Failed to unmarshal JSON", http.StatusBadRequest)
		return
	}

	// Compute hash of the message
	hash := calculateHash(data.Message)

	// Prepare response
	responseData := map[string]interface{}{
		"message": data.Message,
		"hash":    hash,
	}

	jsonResponse, err := json.Marshal(responseData)
	if err != nil {
		http.Error(w, "Failed to marshal JSON response", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write(jsonResponse)
}

func calculateHash(message string) string {
	hasher := sha512.New()
	hasher.Write([]byte(message))
	hash := hasher.Sum(nil)
	return fmt.Sprintf("%x", hash)
}
