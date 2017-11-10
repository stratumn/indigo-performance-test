// This file creates an Express server and mounts the agent on it.

var crypto = require('crypto');
var express = require('express');
var Agent = require('stratumn-agent');
var plugins = Agent.plugins;

// Load actions.
// Assumes your actions are in ./lib/actions.
var actions_process_gatling = require('./lib/actions-process-gatling');
var actions_process_other = require('./lib/actions-process-other');

// Create an HTTP store client to save segments.
// Assumes an HTTP store server is available on env.STRATUMN_STORE_URL or http://store:5000.
var storeHttpClient = Agent.storeHttpClient(process.env.STRATUMN_STORE_URL || 'http://store:5000');
// Do not use a fossilizer.
var fossilizerHttpClient = null;


// Create an agent.
var agentUrl = process.env.STRATUMN_AGENT_URL || 'http://localhost:3000';
var agent = Agent.create({
  agentUrl: agentUrl,
});

// Adds all processes from a name, its actions, the store client, and the fossilizer client.
// As many processes as one needs can be added. A different storeHttpClient and fossilizerHttpClient may be used.
agent.addProcess('ProcessGatling', actions_process_gatling, storeHttpClient, fossilizerHttpClient, {
  // plugins you want to use
  plugins: [plugins.agentUrl(agentUrl), plugins.actionArgs, plugins.stateHash]
});
agent.addProcess('ProcessOther', actions_process_other, storeHttpClient, fossilizerHttpClient, {
  // plugins you want to use
  plugins: [plugins.agentUrl(agentUrl), plugins.actionArgs, plugins.stateHash]
});

// Creates an HTTP server for the agent with CORS enabled.
var agentHttpServer = Agent.httpServer(agent, { cors: {} });

// Create the Express server.
var app = express();

app.disable('x-powered-by');

// Mount agent on the root path of the server.
app.use('/', agentHttpServer);

// Start the server.
app.listen(3000, function() {
  console.log('Listening on :' + this.address().port);
});
