pragma solidity ^0.4.18;
import "./Auction.sol";

contract EnglishAuction is Auction {

    uint public initialPrice;
    uint public biddingPeriod;
    uint public minimumPriceIncrement;

    // TODO: place your code here
    //uint startTime;
    uint endTime;
    uint currentPrice;
    address currentWinner;

    // constructor
    constructor(address _sellerAddress,
                          address _judgeAddress,
                          address _timerAddress,
                          uint _initialPrice,
                          uint _biddingPeriod,
                          uint _minimumPriceIncrement) public
             Auction (_sellerAddress, _judgeAddress, _timerAddress) {

        initialPrice = _initialPrice;
        biddingPeriod = _biddingPeriod;
        minimumPriceIncrement = _minimumPriceIncrement;

        // TODO: place your code here
        currentPrice = initialPrice - minimumPriceIncrement;
        endTime = time() + biddingPeriod;
    }

    function bid() public payable{
        // TODO: place your code here
        require(time() < endTime);
        require(msg.value >= currentPrice + minimumPriceIncrement);
        if (currentWinner != 0) {
            previousBidders[currentWinner] += currentPrice;
        }
        currentWinner = msg.sender;
        currentPrice = msg.value;
        endTime = time() + biddingPeriod;
    }

    // Need to override the default implementation
    function getWinner() public view returns (address winner){
        // TODO: place your code here
        return (time() >= endTime)? currentWinner: 0;
    }
}
