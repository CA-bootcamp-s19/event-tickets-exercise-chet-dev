pragma solidity ^0.5.0;

    /*
        The EventTickets contract keeps track of the details and ticket sales of one event.
     */

contract EventTickets {

    /*
        Create a public state variable called owner.
        Use the appropriate keyword to create an associated getter function.
        Use the appropriate keyword to allow ether transfers.
    */
    address payable public owner;

    uint   TICKET_PRICE = 100 wei;

    /*
        Create a struct called "Event".
        The struct has 6 fields: description, website (URL), totalTickets, sales, buyers, and isOpen.
        Choose the appropriate variable type for each field.
        The "buyers" field should keep track of addresses and how many tickets each buyer purchases.
    */

    struct Event{
        string description;
        string website;
        uint totalTickets;
        uint sales;
        mapping(address=>uint) buyers;
        bool isOpen;
    }

    Event myEvent;

    /*
        Define 3 logging events.
        LogBuyTickets should provide information about the purchaser and the number of tickets purchased.
        LogGetRefund should provide information about the refund requester and the number of tickets refunded.
        LogEndSale should provide infromation about the contract owner and the balance transferred to them.
    */
    event LogBuyTickets(address indexed buyer, uint ticketsBought);
    event LogGetRefund(address indexed requester, uint refundedTickets);
    event LogEndSale(address indexed owner, uint balanceTransferred);

    /*
        Create a modifier that throws an error if the msg.sender is not the owner.
    */
    modifier OwnerOnly{
        require(msg.sender == owner,"Must be the owner");
        _;
    }

    modifier EventIsOpen{
        require(myEvent.isOpen,"Event not open!");
        _;
    }

    modifier SufficientPayment(uint payment, uint numOfTickets){
        uint amountToPay = TICKET_PRICE * numOfTickets;
        require(payment >= amountToPay,"Insufficient amount to pay!");
        _;
    }

    modifier SufficientTickets(uint numOfTickets){
        require(myEvent.totalTickets >= numOfTickets,"Insufficient tickets!");
        _;
    }

    modifier CheckRefund(uint payment, uint numOfTickets){
        _;
        uint amountToRefund = payment - (TICKET_PRICE * numOfTickets);
        if(amountToRefund > 0) msg.sender.transfer(amountToRefund);
    }

    /*
        Define a constructor.
        The constructor takes 3 arguments, the description, the URL and the number of tickets for sale.
        Set the owner to the creator of the contract.
        Set the appropriate myEvent details.
    */
    constructor(string memory _description, string memory _url, uint _totalTickets) public {
        owner = msg.sender;
        myEvent.description = _description;
        myEvent.website = _url;
        myEvent.totalTickets = _totalTickets;
        myEvent.sales = 0;
        myEvent.isOpen = true;
    }

    /*
        Define a funciton called readEvent() that returns the event details.
        This function does not modify state, add the appropriate keyword.
        The returned details should be called description, website, uint totalTickets, uint sales, bool isOpen in that order.
    */
    function readEvent() public view
       returns(string memory description, string memory website, uint totalTickets, uint sales, bool isOpen) {
           return (myEvent.description, myEvent.website, myEvent.totalTickets, myEvent.sales, myEvent.isOpen);
    }

    /*
        Define a function called getBuyerTicketCount().
        This function takes 1 argument, an address and
        returns the number of tickets that address has purchased.
    */
    function getBuyerTicketCount(address buyerAddress) public view returns(uint _numTickets){
        return myEvent.buyers[buyerAddress];
    }

    /*
        Define a function called buyTickets().
        This function allows someone to purchase tickets for the event.
        This function takes one argument, the number of tickets to be purchased.
        This function can accept Ether.
        Be sure to check:
            - That the event isOpen
            - That the transaction value is sufficient for the number of tickets purchased
            - That there are enough tickets in stock
        Then:
            - add the appropriate number of tickets to the purchasers count
            - account for the purchase in the remaining number of available tickets
            - refund any surplus value sent with the transaction
            - emit the appropriate event
    */
    function buyTickets(uint numTickets) public payable
    EventIsOpen SufficientPayment(msg.value,numTickets)
    SufficientTickets(numTickets)
    CheckRefund(msg.value,numTickets)
    {
        myEvent.buyers[msg.sender] += numTickets;
        myEvent.totalTickets -= numTickets;
        myEvent.sales += numTickets;
        emit LogBuyTickets(msg.sender, numTickets);
    }

    /*
        Define a function called getRefund().
        This function allows someone to get a refund for tickets for the account they purchased from.
        TODO:
            - Check that the requester has purchased tickets.
            - Make sure the refunded tickets go back into the pool of avialable tickets.
            - Transfer the appropriate amount to the refund requester.
            - Emit the appropriate event.
    */
    function getRefund() public payable {
        require(myEvent.buyers[msg.sender]>0, "Requester did not purchase any ticket!");
        uint ticketsToRefund = myEvent.buyers[msg.sender];
        myEvent.buyers[msg.sender] = 0;
        myEvent.totalTickets += ticketsToRefund;
        myEvent.sales -= ticketsToRefund;
        msg.sender.transfer(ticketsToRefund * TICKET_PRICE);
        delete myEvent.buyers[msg.sender];
        emit LogGetRefund(msg.sender, ticketsToRefund);
    }

    /*
        Define a function called endSale().
        This function will close the ticket sales.
        This function can only be called by the contract owner.
        TODO:
            - close the event
            - transfer the contract balance to the owner
            - emit the appropriate event
    */
    function endSale() public payable OwnerOnly{
        myEvent.isOpen = false;
        uint contractBalance = address(this).balance;
        owner.transfer(contractBalance);
        emit LogEndSale(owner, contractBalance);
    }

    // Fallback function - Called if other functions don't match call or
    // sent ether without data
    // Typically, called when invalid data is sent
    // Added so ether sent to this contract is reverted if the contract fails
    // otherwise, the sender's money is transferred to contract
    function() external {
        revert('');
    }
}
