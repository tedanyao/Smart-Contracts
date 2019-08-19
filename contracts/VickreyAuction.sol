pragma solidity ^0.4.18;
import "./Auction.sol";

contract VickreyAuction is Auction {

    uint public minimumPrice;
    uint public biddingDeadline;
    uint public revealDeadline;
    uint public bidDepositAmount;

    // TODO: place your code here
    uint secondHighestPrice;
    uint firstHighestPrice;
    address firstWinner;
    address secondWinner;

    // constructor
    constructor(address _sellerAddress,
                            address _judgeAddress,
                            address _timerAddress,
                            uint _minimumPrice,
                            uint _biddingPeriod,
                            uint _revealPeriod,
                            uint _bidDepositAmount) public
             Auction (_sellerAddress, _judgeAddress, _timerAddress) {

        minimumPrice = _minimumPrice;
        bidDepositAmount = _bidDepositAmount;
        biddingDeadline = time() + _biddingPeriod;
        revealDeadline = time() + _biddingPeriod + _revealPeriod;

        // TODO: place your code here
        firstHighestPrice = minimumPrice;
        secondHighestPrice = minimumPrice;

        // bidDeposit = bidDepositAmount;
    }

    // Record the player's bid commitment
    // Make sure exactly bidDepositAmount is provided (for new bids)
    // Bidders can update their previous bid for free if desired.
    // Only allow commitments before biddingDeadline
    function commitBid(bytes32 bidCommitment) public payable {
        // TODO: place your code here
        require(time() < biddingDeadline);
        if (biddersComm[msg.sender] != 0) {
            require(msg.value == 0);
        }
        else {
            require(msg.value == bidDepositAmount);
        }
        biddersComm[msg.sender] = bidCommitment;
        // biddersDepositNotBack[msg.sender] = true;
    }

    // Check that the bid (msg.value) matches the commitment.
    // If the bid is correctly opened, the bidder can withdraw their deposit.
    function revealBid(bytes32 nonce) public payable returns(bool isHighestBidder) {
        // TODO: place your code here
        require(time() >= biddingDeadline && time() < revealDeadline);
        require(keccak256(msg.value, nonce) == biddersComm[msg.sender]);
        // refund the deposit
        // withdraw();
        // store price in biddersComm, instead of bidCommitment
        // update winner
        if (msg.value == firstHighestPrice && msg.value == minimumPrice) {
            firstWinner = msg.sender;
        }
        if (msg.value > firstHighestPrice) {
            // release old secondWinner
            if (secondWinner != 0) {
                previousBidders[secondWinner] = bidDepositAmount + secondHighestPrice;
            }
            // add new
            secondHighestPrice = firstHighestPrice;
            secondWinner = firstWinner;
            firstHighestPrice = msg.value;
            firstWinner = msg.sender;
            return true;
        }
        else if (msg.value > secondHighestPrice) {
            // release old secondWinner
            if (secondWinner != 0) {
                previousBidders[secondWinner] = bidDepositAmount + secondHighestPrice;
            }
            // add new
            secondHighestPrice = msg.value;
            secondWinner = msg.sender;
        }
        else {
            // refund it
            previousBidders[msg.sender] = msg.value;
        }
        return false;
    }

    // Need to override the default implementation
    function getWinner() public view returns (address winner){
        // TODO: place your code here
        return (time() >= revealDeadline)? firstWinner: 0;
    }

    // finalize() must be extended here to provide a refund to the winner
    // based on the final sale price (the second highest bid, or reserve price).
    function finalize() public {
        // TODO: place your code here
        // call the general finalize() logic
        require(getWinner() != 0);
        previousBidders[firstWinner] = bidDepositAmount + firstHighestPrice - secondHighestPrice;
        if (secondWinner != 0) {
            previousBidders[secondWinner] = bidDepositAmount + secondHighestPrice;
        }

        secondPrice = secondHighestPrice;
        super.finalize();

    }
}
