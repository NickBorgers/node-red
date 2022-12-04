all: build run watch-logs

build:
	docker build -t node-red-local -f .automated-rendering/node-red/Dockerfile .
	docker build -t node-red-haproxy .automated-rendering/haproxy/
	docker build -t screenshot-capture .automated-rendering/screenshot-capture/

run: cleanup
	docker network create node-red-backend --internal
	docker network create node-red-frontend
	docker run --rm -d --network node-red-frontend -p 8080:80 --name node-red-proxy node-red-haproxy
	docker network connect node-red-backend node-red-proxy
	docker run -d --user 0:0 -e PORT=80 --network=node-red-backend --name node-red node-red-local

run-to-generate-screenshots: run
	docker run --rm --network=node-red-frontend \
	  --mount type=bind,source=${CURDIR}/.automated-rendering/screenshot-capture/,destination=/app/ \
	  --name screenshot-capture screenshot-capture npm test

watch-logs:
	docker logs -f node-red

interactive-node-red:
	docker exec -it node-red bash

interactive-screenshot-capture:
	docker run -it --rm --network=node-red-backend \
	  --mount type=bind,source=${CURDIR}/.automated-rendering/screenshot-capture/,destination=/app/ \
	  --name screenshot-capture screenshot-capture

restart:
	docker stop node-red
	docker start node-red

cleanup:
	docker stop node-red-proxy || true
	docker stop node-red || true
	docker rm node-red || true
	docker network rm node-red-backend || true
	docker network rm node-red-frontend || true
