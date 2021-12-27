'use strict';

const config = {};

// Environment variables
const envs = [
    'PORT_HTTP',
    'PG_HOST',
    'PG_PORT',
    'PG_USER',
    'PG_PASS',
    'PG_DB_NAME',
    'ENABLE_LOG_FILE',
    'NODE_RPC',
    'CONTRACT_TOKEN_DISTRIBUTION',
    'OPERATOR',
    'OPERATOR_KEY'
];

// Checks enviroment variables to ensure that all of them are declared
envs.forEach((env) => {
    if (process.env[env] === undefined) {
        console.log(`Enviroment variable \x1b[33m"${env}"\x1b[0m is required in file \x1b[33m".env"\x1b[0m \n`);
        process.exit(0);
    }

    config[env.toLowerCase()] = process.env[env];
});

module.exports = config;
