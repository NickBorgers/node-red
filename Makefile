all: build run watch-logs

build:
	# Build all three custom images
	docker build -t node-red-local -f .automated-rendering/node-red/Dockerfile .
	docker build -t node-red-haproxy .automated-rendering/haproxy/
	docker build -t screenshot-capture .automated-rendering/screenshot-capture/

run: cleanup
	# Create an internal backend network with no gateway
	docker network create node-red-backend --internal
	# Create a network with a gateway
	docker network create node-red-frontend
	# Create the proxy on the frontend network
	docker run --rm -d --network node-red-frontend -p 8080:80 --name node-red-proxy node-red-haproxy
	# Add the backend to the proxy so it can reach the node-red container
	docker network connect node-red-backend node-red-proxy
	# Create the node-red container on the backend network
	docker run -d --user 0:0 -e PORT=80 --network=node-red-backend --name node-red node-red-local

run-to-generate-screenshots: run
	# Hacky sleep to avoid hitting TCP connection refused against node-red container
	sleep 1
	# Start our "test" which pulls the screenshots out of the node-red container
	docker run --rm --network=node-red-backend \
	  --mount type=bind,source=${CURDIR}/.automated-rendering/screenshot-capture/screenshots/,destination=/app/screenshots/ \
	  --name screenshot-capture screenshot-capture npm test
	# Trim our captured screenshots with ImageMagick
	docker run --rm --network=none \
	  --mount type=bind,source=${CURDIR}/.automated-rendering/screenshot-capture/screenshots/,destination=/screenshots/ \
	  --name image-magick-auto-crop --entrypoint=mogrify dpokidov/imagemagick -fuzz 27% -trim +repage /screenshots/*.png

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

run-config-tests: run-yamllint-hue run-yamllint-music run-yamllint-schedule run-spotify-validation-music

run-yamllint-hue: build-config-tester
	docker run --rm --mount type=bind,source=${CURDIR}/configs/hue_config.yaml,destination=/app/hue_config.yaml node-red-config-tester yamllint hue_config.yaml

run-yamllint-music: build-config-tester
	docker run --rm --mount type=bind,source=${CURDIR}/configs/music_config.yaml,destination=/app/music_config.yaml node-red-config-tester yamllint music_config.yaml

run-yamllint-schedule: build-config-tester
	docker run --rm --mount type=bind,source=${CURDIR}/configs/schedule_config.yaml,destination=/app/schedule_config.yaml node-red-config-tester yamllint schedule_config.yaml

run-spotify-validation-music: build-config-tester
	docker run --rm --mount type=bind,source=${CURDIR}/configs/music_config.yaml,destination=/app/music_config.yaml node-red-config-tester python3 -u validate_spotify_uris.py

build-config-tester:
	docker build -t node-red-config-tester ./config-test/
