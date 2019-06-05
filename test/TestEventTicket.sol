pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/EventTickets.sol";
import "../contracts/EventTicketsV2.sol";

contract TestEventTicket {

    uint public initialBalance = 1 ether;

    EventTicketsV2 etv2 = new EventTicketsV2();
    uint ticketPrice = 100 wei;

    function test_Add_Event_And_Read_Event() public {

        etv2.addEvent("Event1","Url1",100);

        (string memory description, string memory website, uint totalTickets, uint sales, bool isOpen) = etv2.readEvent(0);
        Assert.equal("Event1", description, "Event description is incorrect!");
        Assert.equal("Url1", website, "Event website address is incorrect!");
        Assert.equal(100,totalTickets,"Event total tickets is incorrect!");
        Assert.equal(0,sales,"Event initial sales should be 0");
        Assert.equal(true,isOpen,"Event initial isOpen should be true");
    }

    function test_Initial_Balance_Of_1_Ether() public {
        Assert.equal(address(this).balance, 1 ether, 'Initial Balance not equal to 1 ether!');
    }

    function test_BuyTickets() public {
        etv2.buyTickets.value(1 ether)(0,2);
        uint buyerShouldHaveBalance = 1 ether - 200 wei;
        Assert.equal(address(etv2).balance, 200 wei,"Contract Balance should be 200 wei");
        Assert.equal(address(this).balance, buyerShouldHaveBalance, "Buyer should have 1 ether - 200 wei");
    }

    function() external payable {
    }


}
