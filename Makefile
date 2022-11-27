all: run

build:
	docker build -t node-red-local .automated-rendering/node-red/
	docker build -t node-red-haproxy .automated-rendering/haproxy/

run: build cleanup
	docker network create node-red-backend --internal
	docker network create node-red-frontend
	docker run --rm -d --network node-red-frontend -p 8080:80 --name node-red-proxy node-red-haproxy
	docker network connect node-red-backend node-red-proxy
	docker run --rm --user 0:0 --mount type=bind,source=${CURDIR},destination=/data/projects/node-red,readonly \
	  --mount type=bind,source=${CURDIR}/.automated-rendering/node-red/package.json,destination=/data/package.json,readonly \
	  -e PORT=80 -e NODE_RED_ENABLE_PROJECTS=true --network=node-red-backend --name node-red node-red-local

cleanup:
	docker stop node-red-proxy || true
	docker stop node-red || true
	docker network rm node-red-backend || true
	docker network rm node-red-frontend || true

