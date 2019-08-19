pragma solidity ^0.4.18;
import "./Auction.sol";

contract DutchAuction is Auction {

    uint public initialPrice;
    uint public biddingPeriod;
    uint public offerPriceDecrement;

    // TODO: place your code here
    uint beginTime;
    uint endTime;
    uint currentPrice;
    
    // constructor
    constructor(address _sellerAddress,
                          address _judgeAddress,
                          address _timerAddress,
                          uint _initialPrice,
                          uint _biddingPeriod,
                          uint _offerPriceDecrement) public
             Auction (_sellerAddress, _judgeAddress, _timerAddress) {

        initialPrice = _initialPrice;
        biddingPeriod = _biddingPeriod;
        offerPriceDecrement = _offerPriceDecrement;

        // TODO: place your code here
        beginTime = time();
        endTime = beginTime + biddingPeriod;
    }


    function bid() public payable{
        // TODO: place your code here
        require(time() < endTime && winnerAddress == 0);

        currentPrice = initialPrice - offerPriceDecrement * (time() - beginTime);
        require(msg.value >= currentPrice);
        winnerAddress = msg.sender;
        // return to the winner
        uint excessMoney = address(this).balance - currentPrice;
        if (excessMoney > 0) {
            previousBidders[msg.sender] = excessMoney;
            withdraw();
        }
    }

}
