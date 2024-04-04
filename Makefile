build: build-and-push-spin-app build-and-push-spin-container

build-and-push-spin-app:
	pushd spin-hello-world && \
	spin build && \
	spin registry push ghcr.io/kate-goldenring/hello-spin:v1 && \
	popd

build-and-push-spin-container:
	pushd spin-hello-world && \
	spin build && \
	docker build -t ghcr.io/kate-goldenring/spin-in-container:v1 . && \
	docker push ghcr.io/kate-goldenring/spin-in-container:v1 && \
	popd

setup-cluster:
	./setup-cluster.sh

deploy-pods:
	./deploy-pods.sh

run:
	echo "" > scale.log && \
	./scale.sh spin-wasm-shim && \
	sleep 5 && \
	./scale.sh spin-wasm-shim 1 && \
	sleep 5 && \
	./scale.sh spin-in-container && \
	sleep 5 && \
	./scale.sh spin-in-container 1 && \
	sleep 5 && \
	cat scale.log

all: build setup-cluster deploy-pods run