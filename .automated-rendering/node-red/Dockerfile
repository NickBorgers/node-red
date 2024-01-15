FROM nodered/node-red

# Copy package.json to the WORKDIR so npm builds all
# of your added nodes modules for Node-RED
COPY .automated-rendering/node-red/package.json .
RUN npm install --unsafe-perm --no-update-notifier --no-fund --omit=dev --only=production
# Bring our flows over raw
COPY flows.json /data/
# Disable that annoying tour thingy
RUN sed -i 's|//tours|tours|g' /usr/src/node-red/node_modules/node-red/settings.js
