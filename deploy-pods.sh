#! /bin/bash

kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spin-in-container
  labels:
    app: spin-in-container
spec:
  replicas: 1
  strategy:
    rollingUpdate:
      maxUnavailable: 0
  selector:
    matchLabels:
      app: spin-in-container
  template:
    metadata:
      labels:
        app: spin-in-container
    spec:
      containers:
      - name: spin-in-container
        image: ghcr.io/kate-goldenring/spin-in-container:v1
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 3000
EOF

kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: spin-in-container
spec:
  selector:
    app: spin-in-container
  ports:
    - protocol: TCP
      port: 3000
      targetPort: 3000
EOF


kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spin-wasm-shim
spec:
  replicas: 1
  strategy:
    rollingUpdate:
      maxUnavailable: 0
  selector:
    matchLabels:
      app: spin-wasm-shim
  template:
    metadata:
      labels:
        app: spin-wasm-shim
    spec:
      runtimeClassName: wasmtime-spin-v2
      containers:
      - name: spin-wasm-shim
        image: ghcr.io/kate-goldenring/hello-spin:v1
        imagePullPolicy: IfNotPresent
        command: ["/"]
        ports:
        - containerPort: 80
EOF

kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: spin-wasm-shim
spec:
  selector:
    app: spin-wasm-shim
  ports:
    - protocol: TCP
      port: 80
EOF