const abi = require('ethereumjs-abi');
const Web3 = require('web3');

const web3 = new Web3('https://api.avax-test.network/ext/bc/C/rpc');

const signer = '61aa353a961eeeff7002421059cdb490797bcf6ddcca2b4cef6925fa6d4c4722';
const user = '0x95298790beB442F204E3864c5BD4073905185108';
const chainId = 43113; // testnet
const contract = '0x90DAFb8D266109208B97962Bb15588b268902F7c';
const amount = '1000000000000000000';

const ctr = new web3.eth.Contract(
    [{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"nonces","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}],
    contract
);

ctr.methods.nonces(user).call().then((nonce) => {
    // Generates hash for signing
    const hash = '0x' + abi.soliditySHA3(
        ['address', 'uint256', 'uint256', 'uint256', 'address'],
        [
            user,
            amount,
            nonce,
            chainId,
            contract
        ]
    ).toString('hex');

    // Signs data
    const message = web3.eth.accounts.sign(hash, signer);

    console.log(message);
});