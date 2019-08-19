pragma solidity ^0.4.18;
import "./Timer.sol";

contract Auction {

    address internal judgeAddress;
    address internal timerAddress;
    address internal sellerAddress;
    address internal winnerAddress;
    uint winningPrice;

    // TODO: place your code here
    bool callFromRefund = false;
    bool callFromFinalize = false;
    // for DutchAuction
    // for EnglishAuction
    mapping (address => uint) previousBidders;
    // for VickreyAuction
    mapping (address => bytes32) biddersComm;
    uint secondPrice;

    // constructor
    constructor(address _sellerAddress,
                     address _judgeAddress,
                     address _timerAddress) public {

        judgeAddress = _judgeAddress;
        timerAddress = _timerAddress;
        sellerAddress = _sellerAddress;
        if (sellerAddress == 0)
          sellerAddress = msg.sender;
    }

    // This is provided for testing
    // You should use this instead of block.number directly
    // You should not modify this function.
    function time() public view returns (uint) {
        if (timerAddress != 0)
          return Timer(timerAddress).getTime();

        return block.number;
    }

    function getWinner() public view returns (address winner) {
        return winnerAddress;
    }

    function getWinningPrice() public view returns (uint price) {
        return winningPrice;
    }

    // If no judge is specified, anybody can call this.
    // If a judge is specified, then only the judge or winning bidder may call.
    function finalize() public {
        // TODO: place your code here
        require(getWinner() != 0);
        if (judgeAddress != 0) {
            require(msg.sender == judgeAddress || msg.sender == getWinner());
        }
        // transfer money to the seller
        callFromFinalize = true;
        withdraw();
    }

    // This can ONLY be called by seller or the judge (if a judge exists).
    // Money should only be refunded to the winner.
    function refund() public {
        // TODO: place your code here
        require(getWinner() != 0);
        if (judgeAddress != 0) {
            require(msg.sender == sellerAddress || msg.sender == judgeAddress);
        }
        else {
            require(msg.sender == sellerAddress);
        }
        // send money to winner
        callFromRefund = true;
        withdraw();
    }

    // Withdraw funds from the contract.
    // If called, all funds available to the caller should be refunded.
    // This should be the *only* place the contract ever transfers funds out.
    // Ensure that your withdrawal functionality is not vulnerable to
    // re-entrancy or unchecked-spend vulnerabilities.
    function withdraw() public {
        //TODO: place your code here
        if (callFromRefund || callFromFinalize) {
            address sendTo = callFromFinalize? sellerAddress: callFromRefund? getWinner(): 0;
            uint money = (secondPrice != 0)? secondPrice: address(this).balance;
            sendTo.transfer(money);
            callFromRefund = false;
            callFromFinalize = false;
        }
        // for bidders to refund themselves
        else if (previousBidders[msg.sender] != 0) {
            msg.sender.transfer(previousBidders[msg.sender]);
            previousBidders[msg.sender] = 0;
        }
    }

}
