// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract TimeLockedWallet {
    address public owner;
    uint256 public creationTime;
    uint256 public startWaitTime;
    uint256 public totalBalance;
    uint256 public numberOfVestingPeriods;
    uint256 public vestingPeriodDuration;
    uint256 public percentPerClaim;

    uint256 public claimedBalance;
    uint256 public periodsClaimed;

    bool public lockExpired;

    constructor(
        address _owner,
        uint256 _startWaitTime,
        uint256 _vestingPeriodDuration,
        uint256 _percentPerClaim
    ) {
        require(_percentPerClaim > 1, "Need to be at least 1%");
        owner = _owner;
        creationTime = block.timestamp;
        startWaitTime = _startWaitTime; // * 1 days;
        numberOfVestingPeriods = 100 / _percentPerClaim;
        vestingPeriodDuration = _vestingPeriodDuration; // * 1 days;
        percentPerClaim = _percentPerClaim; // 1 ~ 1%
    }

    receive() external payable {
        require(msg.sender == owner, "Only owner can deposit");
    }

    function deposit() external payable {
        require(msg.sender == owner, "Only owner can deposit");
        require(!lockExpired, "This contract has expired");
        totalBalance += msg.value;
    }

    function claim() external {
        require(msg.sender == owner, "Only owner can claim funds");
        require(block.timestamp >= creationTime + startWaitTime + periodsClaimed * vestingPeriodDuration, "Not time yet");
        require(!lockExpired, "This contract has expired");

        if (claimedBalance == totalBalance) {
            lockExpired = true;
            revert("Already claimed");
        }

        uint256 claimableAmount;

        if (periodsClaimed == numberOfVestingPeriods - 1) {
            claimableAmount =
                (totalBalance * (100 - (periodsClaimed * percentPerClaim))) /
                100;
            lockExpired = true;
        } else {
            claimableAmount = (totalBalance * percentPerClaim) / 100;
        }

        claimedBalance += claimableAmount;
        periodsClaimed++;

        require(address(this).balance >= claimableAmount, "Not enough balance");
        payable(owner).transfer(claimableAmount);
    }

    function getInfo()
        external
        view
        returns (
            address,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            owner,
            startWaitTime,
            numberOfVestingPeriods,
            vestingPeriodDuration,
            percentPerClaim,
            totalBalance
        );
    }
}

contract TimeLockedWalletFactory {
    uint256 public currentWalletId;

    mapping(address => address[]) public userWallets;

    mapping(uint256 => address) public timeLockedWallets;

    event WalletCreated(
        address owner,
        address newWallet,
        uint256 startWaitTime,
        uint256 vestingDuration,
        uint256 percentPerClaim
    );

    function getWallets(address _user) public view returns (address[] memory) {
        return userWallets[_user];
    }

    function createTimeLockedWallet(
        uint256 _startWaitTime,
        uint256 _vestingPeriodDuration,
        uint256 _percentPerClaim
    ) public {
        TimeLockedWallet newWallet = new TimeLockedWallet(
            msg.sender,
            _startWaitTime,
            _vestingPeriodDuration,
            _percentPerClaim
        );
        userWallets[msg.sender].push(address(newWallet));
        currentWalletId++;
        timeLockedWallets[currentWalletId] = address(newWallet);

        emit WalletCreated(
            msg.sender,
            address(newWallet),
            _startWaitTime,
            _vestingPeriodDuration,
            _percentPerClaim
        );
    }
}
