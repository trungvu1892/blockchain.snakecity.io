'use strict';

require('dotenv').config();

const db = require('./db');

class Server {

    /**
     * Starts server and services
     */
    async start () {
        // 1. Connects to database
        // 2. Creates tables
        // 3. Runs SQL functions
        await db.sync();
    }

}

module.exports = new Server();