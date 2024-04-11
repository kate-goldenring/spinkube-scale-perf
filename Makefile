TAG ?= v1
setup-cluster:
	./setup-cluster.sh

build: build-and-push-spin-apps build-and-push-containers

wvc-run:
	echo "" > scale.log && \
	./scale.sh gohash-wasm && \
	sleep 5 && \
	./scale.sh gohash-wasm 1 && \
	sleep 5 && \
	./scale.sh gohash-containerized && \
	sleep 5 && \
	./scale.sh gohash-containerized 1 && \
	sleep 5 && \
	cat scale.log

spl-run:
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

build-and-push-spin-apps:
	spin build --from wasm-vs-container/gohash-spin && \
	spin registry push --from wasm-vs-container/gohash-spin ghcr.io/kate-goldenring/gohash:$(TAG) && \
	spin build --from spin-process-location && \
	spin registry push --from spin-process-location ghcr.io/kate-goldenring/hello-spin:$(TAG) 

build-and-push-containers:
	docker build --platform linux/amd64 -t ghcr.io/kate-goldenring/spin-in-container:$(TAG) spin-process-location && \
	docker push ghcr.io/kate-goldenring/spin-in-container:$(TAG) && \
	docker build --platform linux/amd64 -t ghcr.io/kate-goldenring/gohash-container:$(TAG) wasm-vs-container/gohash-containerized && \
	docker push ghcr.io/kate-goldenring/gohash-container:$(TAG)

deploy-pods:
	kubectl apply -f deployments.yaml

spin-process-location-test: build deploy-pods spl-run

wasm-vs-container-test: build deploy-pods