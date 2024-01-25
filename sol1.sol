// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


/* 
Data Types : string, int, uint, bool, address
*/

contract Parent{

    // There are two types of functions : Write and Read function

    /* Visibility in smart contracts
        --- for variables
        ->public : it can be used anywhere 
        ->private : only accessible inside the particular smart contract
        ->internal: it is same as private but can also be used in inherited contracts

        --- for function
        ->public: It can be called from anywhere
        ->private: It can't be called outside the contract
        ->internal: it can be called from same contracts as well as inherited contracts
        ->external: It can be only called from outside the contract (can't be called from same contract)

    */   
    string public name = "Kaushal"; 
    // function modifiers
        // view : does not modify the state of blockchain, it only reads the blockchain
        function getName() public view returns(string memory) {
            return name;
        }   

        // pure : neither modify the state of blockchain nor reads the state, it only calcuates 
        function add(uint a, uint b)  public pure returns(uint) {
            return a + b;
        }
        
        // payable function are allowed to receive ether/cryptocurrency whenever the transaction is submitted
        uint balance;
        function pay() public payable {
            balance = msg.value;
        }

        // custom modifiers
        address owner;
        modifier onlyOwner {
            require(msg.sender == owner, 'caller must be owner');
            _;
        }

    function setName_(string memory _name) onlyOwner public {
        name = _name;
    }

        // constructor: It only run once whenever contract is initialized or put on
        //              the blockchain
        constructor(string memory _name) {
            name = _name;
        }

    /* Two types of variable : storage and memory
    Storage:  This is global memory available to all functions within the contract. 
              This storage is a permanent storage that Ethereum 
                stores on every node within its environment
    Memory:   This is local memory available to every function within a contract.
    */



    /* Here is the example of write funciton 
    in this function variable _name has _ in prefix which indicates that
    it is not global variable (it's naming conventin only)
    here memory : keyword in parameter indicates that variable called by
    copying the variable, it used its replica in memory to call the function
    */
    function setName(string memory _name) public{
        name = _name;
    }

    /* Array*/
    uint[] public array;
    function get(uint i) public view returns (uint){
        return array[i];
    }
    uint n = array.length;
    array.push(n);
    array.pop();
    delete array[0];

    // mappings : is very similar to map of STL in c++
    mapping(uint => string) public names;
    mapping(uint => address) public addresses;
    mapping(address => bool) public hasVoted;
    mapping(address => mapping(uint=> bool)) public mp;
    names[1] = "Kaushal";
    delete name[1];

    // struct
    struct Book{
        string title;
        string author;
        bool completed;
    }

    Book[] public books;
    Book public firstBook = Book("Trading in the zone", "Mark Douglas", false);

    function addBook(string memory _title, string memory _author) public{
        books.push(Book(_title, _author, false));
    }

    function get(uint _index) public view
    returns (string memory title, string memory author, bool completed){
        Book storage book = books[_index];
        book.complted = true;
        return (book.title, book.author, book.completed);
    }

    /* Events in Solidity are a way for smart contracts to communicate with 
    each other and with external applications. They are a mechanism for 
    emitting and recording data onto the blockchain, making it transparent 
    and easily accessible. 
    Events are like notifications that give you alerts when something 
    of interest happens or an important event takes place. They allow 
    developers to track all significant actions and transactions in a 
    contract, providing crucial information about the state and 
    interaction of the contract.
    */
    string public message = "Hello World";

    /* 
    below event can contain  upto 17 parameters and index upto 3
    In Solidity, when you create events to record things happening in 
    your smart contract, you can make some details easier to find later.
    It's like adding labels or tags to those details. You can label up
    to three things in each event, and these labeled things can be
    quickly searched or filtered on the blockchain.
    */
    event MessageUpdated(address indexed _user, string _message);

    // It also triggers notification everytime, anyone calls this function
    // we get history on which time and who trigged this event
    function updateMessage(string memory _message) public {
        message = _message;
        emit MessageUpdated(msg.sender, _message);
    }

    // 1 ether = 10^18 wei
    // 1 ether = 10^9 gwei
    // 1 gwei = 10^9 wei

    receive() external payable {
        // We can receive the ether to the current smart contract from outside
        // With use of EXTERNAL and PAYABLE
    }

    uint public count == 0;

    /*  Fallback function act as a default or catch-all function when a 
    transaction is sent to the contract without specifying a 
    particular function to call.
    */
    fallback() external payable {
        // Code to execute when the contract receives ether without a specific function call
        count++;
    }

    function checkBalance() public view returns (uint){
        // here this keyword indicates the address of current smart contract
        return addresss(this).balance;
    }

    function transferFund(address payable _to) public payable {
        (bool sent, ) = _to.call{value: msg.value}("");
        // here require has condition and error message
        // If condition is true, then it'll continue execution of next lines
        // otherwise it'll stop execution and will show error message
        require(sent, "Failed!");


    }
    // revert prints the error message when any condition is true
    //  if (a <=10) { revert("must be greater than 10"); }

}

contract Inherited is Parent {
    // here you can use variables and functions of Parent contract
}

// importing another smart contract
contract Mycontract{
    // created object of another contract which we want to use
    Parent public vault;
    
    constructor(Parent _vault){
        vault = _vault;
    }

    
    function setSecret(string memory _secret) public{
        // callling function of another smart contract using its object
        vault.setSecret(_secret);
    }

}

// another common way to talk to smart contract is to use INTERFACES
interface  IERC20 {
    // state those function which we want to use from that contract
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
    external returns (bool success);
}

contract Cont{
    function deposit(address _tokenAddress, uint _amount) public{
        IERC20(_tokenaddress).transferFrom(msg.sender, address(this), _amount);
    }
}