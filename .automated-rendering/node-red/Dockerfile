FROM nodered/node-red

# Copy package.json to the WORKDIR so npm builds all
# of your added nodes modules for Node-RED
COPY .automated-rendering/node-red/package.json .
RUN npm install --unsafe-perm --no-update-notifier --no-fund --only=production

COPY flows.json /data/
