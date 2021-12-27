'use strict';

const fs = require('fs');

const database = require('./../lib/postgres');

const log = require('./../lib/logger').getAppLog();

/**
 * Runs SQL scripts
 */
async function runScripts (_path) {
    const files = fs.readdirSync(_path);

    for (const file of files) {
        let sql = fs.readFileSync(`${_path}/${file}`, 'utf8');

        await database.query(sql);

        log.info(`Executed ${file}`);
    }
}

module.exports = {

    sync: async () => {
        // Connects to database
        await database.connect();

        // Runs SQL scripts
        await runScripts('./src/model/scripts/functions');
    }

};
