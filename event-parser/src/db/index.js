'use strict';

const fs = require('fs');

const database = require('./../lib/postgres');

const config = require('./../config');

const log = require('./../lib/logger').getAppLog();

/**
 * Runs SQL scripts
 */
async function runScripts (_path) {
    const keywords = {
        SG_NFT: config.sg_nft,
        SG_MARKETPLACE: config.sg_marketplace
    };

    const files = fs.readdirSync(_path);

    for (const file of files) {
        let sql = fs.readFileSync(`${_path}/${file}`, 'utf8');

        for (const key in keywords) {
            sql = sql.replace(new RegExp('{' + key + '}', 'gi'), keywords[key].toLowerCase());
        }

        await database.query(sql);

        log.info(`Executed ${file}`);
    }
}

/**
 * Creates trigger for subgraph
 */
async function createTrigger (_subgraphSchema, _subgraphTable, _triggerName, _triggerFunction) {
    await database.query(`
        DO $$
        BEGIN
            IF EXISTS (SELECT 1 FROM PG_TRIGGER WHERE TGNAME = '${_subgraphSchema}_${_triggerName}') THEN
                RETURN;
            END IF;

            CREATE TRIGGER ${_subgraphSchema}_${_triggerName}
            BEFORE INSERT
            ON ${_subgraphSchema}.${_subgraphTable}
            FOR EACH ROW
            EXECUTE PROCEDURE BACKEND.${_triggerFunction}();

            IF NOT EXISTS (SELECT 1 FROM ${_subgraphSchema}.${_subgraphTable}) THEN
                RETURN;
            END IF;

            CREATE TABLE ${_subgraphSchema}.TBL_TMP AS (SELECT * FROM ${_subgraphSchema}.${_subgraphTable}) WITH NO DATA;

            CREATE TRIGGER TRG_TMP
            BEFORE INSERT
            ON ${_subgraphSchema}.TBL_TMP
            FOR EACH ROW
            EXECUTE PROCEDURE BACKEND.${_triggerFunction}();

            INSERT INTO ${_subgraphSchema}.TBL_TMP
            SELECT  *
            FROM    ${_subgraphSchema}.${_subgraphTable}
            ORDER BY VID;

            DROP TABLE ${_subgraphSchema}.TBL_TMP;
        END
        $$;
    `);
}

module.exports = {
    sync: async () => {
        // Connects to database
        await database.connect();

        // Creates schema
        await database.query('CREATE SCHEMA IF NOT EXISTS BACKEND');

        // Runs SQL scripts
        await runScripts('./src/db/scripts/tables');
        await runScripts('./src/db/scripts/functions');

        // Creates trigger for subgraphs

        if (config.sg_nft) {
            await createTrigger(config.sg_nft, 'snake_ownership', 'trg_snake_ownership_create', 'fnc_snake_ownership_create');
        }

        if (config.sg_marketplace) {
            await createTrigger(config.sg_marketplace, 'sell_order', 'trg_sell_order_create', 'fnc_sell_order_create');
            await createTrigger(config.sg_marketplace, 'matched_order', 'trg_matched_order_create', 'fnc_matched_order_create');
        }
    }
};
