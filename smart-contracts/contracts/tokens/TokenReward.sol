// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./../lib/Signature.sol";

interface IToken {

    function mint(address to, uint256 amount) external;
    function transfer(address to, uint256 amount) external returns (bool);

}

contract TokenReward is Ownable, Pausable, ReentrancyGuard {

    using Signature for bytes32;

    event SignerUpdated(address addr);
    event TreasuryWalletUpdated(address addr);
    event MintingQuotaUpdated(uint256 amount, uint256 time);
    event TokenWithdrawed(address receiver, uint256 amount);
    event TokenClaimed(address receiver, uint256 amount, uint256 nonce);

    IToken public token;

    address public signer;

    address public treasuryWallet;

    uint256 public chainId;

    uint256 public mintingAmount = 1000 ether;
    uint256 public mintingTime = 24 hours;

    uint256 public lastMintingAt;

    mapping(address => uint256) public nonces;

    constructor(IToken _token, address _signer, address _treasuryWallet, uint256 _chainId)
    {
        token = _token;
        signer = _signer;
        treasuryWallet = _treasuryWallet;
        chainId = _chainId;
    }

    function pause()
        public
        onlyOwner
    {
        _pause();
    }

    function unpause()
        public
        onlyOwner
    {
        _unpause();
    }

    function setSigner(address addr)
        public
        onlyOwner
    {
        require(addr != address(0), "TokenReward: address is invalid");

        signer = addr;

        emit SignerUpdated(addr);
    }

    function setTreasuryWallet(address addr)
        public
        onlyOwner
    {
        require(addr != address(0), "TokenReward: address is invalid");

        treasuryWallet = addr;

        emit TreasuryWalletUpdated(addr);
    }

    function setMintingQuota(uint256 amount, uint256 time)
        public
        onlyOwner
    {
        require(amount > 0, "TokenReward: amount is invalid");

        require(time > 0, "TokenReward: time is invalid");

        if (mintingAmount != amount) {
            mintingAmount = amount;
        }

        if (mintingTime != time) {
            mintingTime = time;
        }

        emit MintingQuotaUpdated(amount, time);
    }

    function withdrawFund(uint256 amount)
        public
        onlyOwner
        nonReentrant
    {
        require(amount > 0, "TokenReward: amount is invalid");

        token.transfer(treasuryWallet, amount);

        emit TokenWithdrawed(treasuryWallet, amount);
    }

    function _mint()
        internal
    {
        uint256 multiplier;

        if (lastMintingAt == 0) {
            multiplier = 1;

        } else {
            multiplier = (block.timestamp - lastMintingAt) / mintingTime;
        }

        if (multiplier > 0) {
            token.mint(address(this), multiplier * mintingAmount);

            lastMintingAt = block.timestamp;
        }
    }

    function claim(uint256 amount, bytes memory signature)
        public
        whenNotPaused
        nonReentrant
    {
        address msgSender = _msgSender();

        uint256 nonce = nonces[msgSender];

        bytes32 message = keccak256(abi.encodePacked(msgSender, amount, nonce, chainId, this)).prefixed();

        require(message.recoverSigner(signature) == signer, "TokenReward: signature is invalid");

        nonces[msgSender]++;

        _mint();

        token.transfer(msgSender, amount);

        emit TokenClaimed(msgSender, amount, nonce);
    }

}