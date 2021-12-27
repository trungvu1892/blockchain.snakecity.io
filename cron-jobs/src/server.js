'use strict';

require('dotenv').config();

const express = require('express');
const app = express();
const http = require('http').createServer(app);

const config = require('./config');

const model = require('./model');

const logger = require('./lib/logger');

const log = logger.getAppLog();

const rewardService = require('./service/reward-distribution');

class Server {

    /**
     * Starts server and services
     */
    async start () {
        // 1. Connects to database
        // 2. Runs SQL functions
        await model.sync();

        // Starts server
        await http.listen(config.port_http);

        log.info('Listening on port', config.port_http);

        // Starts services
        rewardService.start();
    }

}

module.exports = new Server();
