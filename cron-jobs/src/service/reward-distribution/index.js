'use strict';

const cron = require('node-cron');

const config = require('./../../config');

const database = require('./../../lib/postgres');
const utils = require('./../../lib/utils');
const logger = require('./../../lib/logger');
const web3 = require('./../../lib/web3');

const log = logger.getAppLog();

const BN = web3.utils.BN;

// Gets contract instance
const contract = new web3.eth.Contract(require('./../../contract/abi/TokenDistribution.json'), config.contract_token_distribution);

let isRunning = false;

class Service {

    /**
     * Distributes token
     */
    async _distributeToken (_ids, _accounts, _amounts, _total) {
        // Gets operator balance
        let balance = await utils.promisify(cb => web3.eth.getBalance(config.operator, cb));

        log.info(`Operator balance: ${web3.utils.fromWei(balance)} AVAX`);

        // Gets token balance
        balance = await utils.promisify(cb => contract.methods.getTokenBalance(config.contract_token_distribution).call(cb));

        log.info(`Contract balance: ${web3.utils.fromWei(balance)} Token`);

        // Checks token balance
        if (_total.gt(new BN(balance))) {
            log.error(`Token balance is not enough to distribute: ${web3.utils.fromWei(_total.toString())}`);
            return;
        }

        // Estimates gas
        const gas = await utils.promisify(cb => contract.methods.distributeToken(_accounts, _amounts, 0).estimateGas({ from: config.operator }, cb));

        // Get gas price
        const gasPrice = await utils.promisify(cb => web3.eth.getGasPrice(cb));

        // Generates contract data
        const data = contract.methods.distributeToken(_accounts, _amounts, 0).encodeABI();

        // Signs transaction
        const tx = await utils.promisify(cb => web3.eth.accounts.signTransaction({ to: config.contract_token_distribution, data, gas: gas + 50000, gasPrice }, config.operator_key, cb));

        log.info(`Total accounts: ${_accounts.length}`);

        log.info(`Total amount: ${web3.utils.fromWei(_total.toString())}`);

        log.info(`Gas estimation: ${gas}`);

        log.info(`Gas price: ${gasPrice}`);

        let hash;

        try {
            // Send signed transaction
            hash = await utils.promisify(cb => web3.eth.sendSignedTransaction(tx.rawTransaction, cb));

            log.info(`Transaction: ${hash}`);

            // Updates status
            await database.query("update public.claims set \"transactionID\" = $1, \"claimStatus\" = 'Confirmed' where id = ANY($2)", {
                bind: [hash, _ids]
            });

            log.info('Completed!');

        } catch (e) {
            log.error(hash, e.message);
        }
    }

    /**
     * Processes distribution
     */
    async _processDistribution () {
        if (isRunning) {
            return;
        }

        isRunning = true;

        // Gets pending requests
        const result = await database.query("select * from public.claims where \"claimStatus\" = 'Pending' order by id desc", {
            bind: []
        });

        log.info('Total requests: ' + result.length);

        if (result.length === 0) {
            isRunning = false;
            return;
        }

        let total = new BN(0);

        let ids = [];
        let accounts = [];
        let amounts = [];

        for (let i = 1; i <= result.length; i++) {
            const request = result[i - 1];

            const amount = new BN(web3.utils.toWei(request.claimRewardAmount.toString()));

            total = total.add(amount);

            ids.push(request.id);
            accounts.push(request.walletID);
            amounts.push(amount.toString());

            if (i % 50 === 0) {
                await this._distributeToken(ids, accounts, amounts, total);

                total = new BN(0);
                ids = [];
                accounts = [];
                amounts = [];
            }
        }

        if (accounts.length > 0) {
            await this._distributeToken(ids, accounts, amounts, total);
        }

        isRunning = false;
    }

    /**
     * Starts service
     */
    async start () {
        log.info('Started "Reward Distribution Service"');

        await this._processDistribution();

        cron.schedule('* * * * *', async () => {
            await this._processDistribution();
        });
    }

}

module.exports = new Service();
