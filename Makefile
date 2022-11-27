all: run

build:
	docker build -t node-red-local -f .automated-rendering/node-red/Dockerfile .
	docker build -t node-red-haproxy .automated-rendering/haproxy/

run: build cleanup
	docker network create node-red-backend --internal
	docker network create node-red-frontend
	docker run --rm -d --network node-red-frontend -p 8080:80 --name node-red-proxy node-red-haproxy
	docker network connect node-red-backend node-red-proxy
	docker run --user 0:0 -e PORT=80 --network=node-red-backend --name node-red node-red-local

cleanup:
	docker stop node-red-proxy || true
	docker stop node-red || true
	docker network rm node-red-backend || true
	docker network rm node-red-frontend || true

