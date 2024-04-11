package main

import (
	"crypto/sha512"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
)

func main() {
	http.HandleFunc("/health", handleHealthRequest)
	http.HandleFunc("/hash", handleRequest)
	fmt.Println("Go hasher listening on port 3000...")
	http.ListenAndServe(":3000", nil)
}

type Data struct {
	Message string `json:"message"`
}

func handleHealthRequest(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/plain")
	w.WriteHeader(http.StatusOK)
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
