# SpinKube Scale Performance Test

This suite demonstrates how Spin apps (on SpinKube) scale faster than containerized applications.
There are two main scenarios it tests:

1. Why not just put Spin in a container with the SpinApp instead of using SpinKube and the `containerd-shim-spin`?
2. How do Spin Wasm microservices scale compared to containerized ones?

## 1: Spin on Shim vs Spin in Container

```sh
make spin-process-location-test
```

## 2: Spin (Wasm) vs Containerized Microservice

```sh
make wasm-vs-container-test
```

## Results

Results can be found in `scale.log`