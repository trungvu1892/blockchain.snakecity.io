'use strict';

const Web3 = require('web3');

class W3 {

    /**
     * Initializes default settings
     */
    constructor () {
        this._web3 = new Web3(process.env.NODE_RPC);
    }

    /**
     * Gets instance
     */
    getInstance () {
        return this._web3;
    }

}

module.exports = (new W3()).getInstance();
