pragma solidity ^0.4.17;

contract EthereumAccumulator {
    // total ETH amount accumulated at this contract
    uint256 public totalBalance = 0;

    // ETH amount sent by specific accounts
    mapping (address => uint256) public addressBalance;

    // owner of this contract
    address public owner;

    // constructor
    function EthereumAccumulator() {
        owner = msg.sender;
    }

    // function without name is the default function that is called
    // whenever anyone sends funds to a contract
    function () payable {
        // we don't add contract owner's funds to accumulated balance
        // since these funds will be used for refunding to other users
        // in case if there are not enough funds after withdrawal
        if (msg.sender != owner) {
            addressBalance[msg.sender] += msg.value;
            totalBalance += msg.value;
        }
    }

    // functions with this modifier can only be executed by the owner
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // function to refund Ether to one of senders
    function refund(address _sender, uint256 _amount) onlyOwner {
        require(_amount > 0);
        require(addressBalance[_sender] >= _amount);
        require(address(this).balance >= _amount);
        // reduce balances
        addressBalance[_sender] -= _amount;
        totalBalance -= _amount;
        // send Ether to sender
        _sender.transfer(_amount);
    }

    // function to withdraw Ether to owner's account
    function withdraw(uint256 _amount) onlyOwner {
        require(_amount > 0);
        require(address(this).balance >= _amount);
        msg.sender.transfer(_amount);
    }
}
