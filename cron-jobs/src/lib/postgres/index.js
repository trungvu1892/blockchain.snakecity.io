'use strict';

const { Sequelize, QueryTypes } = require('sequelize');

const log = require('./../logger').getAppLog();

class Postgres {

    /**
     * Initializes default settings
     */
    constructor () {
        this._db = new Sequelize(process.env.PG_DB_NAME, process.env.PG_USER, process.env.PG_PASS, {
            host: process.env.PG_HOST,
            port: process.env.PG_PORT,
            dialect: 'postgres',
            logging: false
        });
    }

    /**
     * Connects to database
     */
    async connect () {
        try {
            await this._db.authenticate();

            log.info('Connected to database');

        } catch (e) {
            log.error('Occured error when connecting to database. Error:', e.message);
        }
    }

    /**
     * Query data in database
     */
    async query (_sql, _options) {
        const result = await this._db.query(_sql, {
            ..._options,
            type: QueryTypes.SELECT
        });

        return result;
    }

    /**
     * Gets sequelize instance
     */
    sequelize () {
        return this._db;
    }

}

module.exports = new Postgres();
