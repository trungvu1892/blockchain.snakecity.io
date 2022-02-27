// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract TokenVesting is Ownable {

    using SafeERC20 for IERC20;

    uint256 constant public ONE_HUNDRED_PERCENT = 10000; // 100%

    event PoolAdded(uint256 poolId, uint256 startTime, uint256 cliff, uint256 vestingCliff, uint256 vestingDuration, uint256 tgePercent);
    event PoolRemoved(uint256 poolId);
    event TokenLocked(uint256 poolId, address account, uint256 amount);
    event TokenReleased(uint256 poolId, address account, uint256 amount);

    IERC20 public token;

    struct Pool {
        uint256 startTime;              // second
        uint256 cliff;                  // second
        uint256 vestingCliff;           // second
        uint256 vestingDuration;        // second
        uint256 tgePercent;
        uint256 balance;
    }

    mapping(uint256 => Pool) public pools;

    struct Beneficiary {
        uint256 balance;
        uint256 released;
    }

    mapping(uint256 => mapping(address => Beneficiary)) public beneficiaries;

    modifier poolExist(uint256 _poolId) {
        require(pools[_poolId].startTime > 0, "TokenVesting: pool does not exist");
        _;
    }

    constructor(IERC20 _token)
    {
        token = _token;
    }

    function addPool(uint256 _poolId, uint256 _startTime, uint256 _cliff, uint256 _vestingCliff, uint256 _vestingDuration, uint256 _tgePercent)
        external
        onlyOwner
    {
        require(pools[_poolId].startTime == 0, "TokenVesting: pool existed");

        require(_startTime > 0 && _startTime + _cliff + _vestingDuration > block.timestamp, "TokenVesting: final time is before current time");

        require(_cliff > 0, "TokenVesting: cliff time is invalid");

        require(_vestingCliff > 0 && _vestingCliff <= _vestingDuration, "TokenVesting: vesting cliff duration is longer than vesting duration");

        require(_tgePercent <= ONE_HUNDRED_PERCENT, "TokenVesting: TGE percent is invalid");

        pools[_poolId] = Pool(_startTime, _cliff, _vestingCliff, _vestingDuration, _tgePercent, 0);

        emit PoolAdded(_poolId, _startTime, _cliff, _vestingCliff, _vestingDuration, _tgePercent);
    }

    function removePool(uint256 _poolId)
        external
        onlyOwner
        poolExist(_poolId)
    {
        require(pools[_poolId].balance == 0, "TokenVesting: pool is containing token");

        delete pools[_poolId];

        emit PoolRemoved(_poolId);
    }

    function lockToken(uint256 _poolId, address[] memory _accounts, uint256[] memory _amounts)
        external
        onlyOwner
        poolExist(_poolId)
    {
        uint256 length = _accounts.length;

        require(length > 0 && length == _amounts.length, "TokenVesting: array length is invalid");

        uint256 total = 0;

        for (uint256 i = 0; i < length; i++) {
            address account = _accounts[i];

            require(account != address(0), "TokenVesting: address is invalid");

            uint256 amount = _amounts[i];

            require(amount > 0, "TokenVesting: amount is invalid");

            total += amount;

            beneficiaries[_poolId][account].balance += amount;

            emit TokenLocked(_poolId, account, amount);
        }

        pools[_poolId].balance += total;

        token.safeTransferFrom(_msgSender(), address(this), total);
    }

    function releaseToken(uint256[] memory _poolIds)
        external
    {
        uint256 length = _poolIds.length;

        require(length > 0, "TokenVesting: array length is invalid");

        uint256 total = 0;

        address msgSender = _msgSender();

        for (uint256 i = 0; i < length; i++) {
            uint256 poolId = _poolIds[i];

            require(pools[poolId].startTime > 0, "TokenVesting: pool does not exist");

            uint256 amount = getClaimableAmount(poolId, msgSender);

            if (amount == 0) {
                continue;
            }

            total += amount;

            Beneficiary storage beneficiary = beneficiaries[poolId][msgSender];

            beneficiary.balance -= amount;
            beneficiary.released += amount;

            pools[poolId].balance -= amount;

            emit TokenReleased(poolId, msgSender, amount);
        }

        if (total > 0) {
            token.safeTransfer(msgSender, total);
        }
    }

    function getClaimableAmount(uint256 _poolId, address _account)
        public
        view
        returns (uint256)
    {
        Pool memory pool = pools[_poolId];

        Beneficiary memory beneficiary = beneficiaries[_poolId][_account];

        if (block.timestamp < pool.startTime) {
            return 0;

        } else if (block.timestamp >= pool.startTime + pool.cliff + pool.vestingDuration) {
            return beneficiary.balance;

        } else {
            uint256 total = beneficiary.balance + beneficiary.released;

            uint256 amount = total * pool.tgePercent / ONE_HUNDRED_PERCENT;

            if (block.timestamp >= pool.startTime + pool.cliff) {
                total -= amount;

                uint256 numCliff = (block.timestamp - pool.startTime - pool.cliff) / pool.vestingCliff + 1;

                amount += (numCliff * pool.vestingCliff * total / pool.vestingDuration);
            }

            return amount > beneficiary.released ? amount - beneficiary.released : 0;
        }
    }

}