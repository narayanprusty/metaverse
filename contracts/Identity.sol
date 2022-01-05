//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/*
you can import .sol files from npm, local directory,
github URL, swarm and IPFS. 
*/
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/*
a contract can inherit one ore more contracts. in solidity
inhertance basically copies code from parent contract to
child contract

ERC721 is standard for representing NFTs. Each ERC721 holds
multiple NFTs of an DApp. For example: A Pokemon like game
will have a ERC721 contracts and each pokemons will be 
represented by a token. Each token will have an owner.
*/
contract Identity is ERC721 {

  enum UserStatus {
    ACTIVE,
    BLOCKED
  }

  struct User {
    string name;
    UserStatus status;
    uint age;
  }

  /* 
  you can use .transfer(..) and .send(..) on "address payable" type, 
  but not on "address" type. the difference exists only during compilation time
  
  public keyword generates a getter function owner() which can be called 
  internally or externally (txns or other contracts) 

  Both immutable and constant are keywords that can be used on state variables 
  to restrict modifications to their state. The difference is that constant variables 
  can never be changed after compilation, while immutable variables can be 
  set only within the constructor.
  */
  address payable immutable public owner;

  /* 
  private makes it accessible by current contract only.
  it cannot be accessed by derived contracts or externally 
  */
  mapping (address => User) private users;
  mapping (address => User[]) private history;

  uint256 private tokenCounter;

  /*
  every transaction generates logs stored in transaction receipt. each txn log
  consists of data and topics

  events are used to send notifications to the client. they are stored in the data 
  part of transaction logs

  indexed attributes of events are stored in topics part. topics allow search for
  events so you can filter txns by events
  */
  event UserCreated(User user, address indexed id);

  /*
  custom errors are preferred instead of string messages when we want
  to detect type of errors or dynamically create the error data. its
  difficult to create dynamic strings in solidity so custom errors are in this case
  */
  error UnwantedUpdate(address id, string name);

  /*
  constructor is executed during initialization of the contract. if you are inheriting
  other contracts then you must invoke their constructors also
  */
  constructor (
    string memory name,
    string memory symbol
  ) ERC721(name, symbol) {
    /* 
    you must explicitly cast address to address payable 
    but you can cast address payable to address explicitly or implicitly 

    tx.origin provides the fromAddress of the transaction whereas
    msg.sender is the caller of the function (another contract or transaction sender)
    */
    owner = payable(msg.sender);
  }

  /*
  you can think of modifiers as hooks applied to functions
  
  a modifier can have one or more modifiers applied to it

  modifiers can also accept parameters

  when multiple modifiers are applied then execute in left to right order
  */
  modifier onlyOwner() {
    /*
    require is used to throw an error and stop execution of contract

    different between assert and require is that assert consumes the remaining
    gas whereas require doesn't
    */
    require(msg.sender == owner, "only owner can call this function");

    //underscore indicates where the caller code is executed
    _;
  }

  /*   
  for array (string is an array), structs and mapping types we must specify
  data location (memory or calldata) in function arguments and inside function. 
  
  for other types data location is memory by default in the function body and parameters
  and cannot be modified

  function aruments have a additional data location called as call data.
  calldata makes the argument unmodifiable and is gas efficient 

  external makes it accessible externally only. it cannot be called internally by
  another function
  */
  function registerUser (string calldata name, uint age, address id) external onlyOwner {
    User memory user = User(name, UserStatus.BLOCKED, age);

    /* 
    assignments from memory to storage or vice-versa always creates an
    independent copy. whereas assignments from memory to memory always 
    creates an reference
    */
    users[id] = user;

    /*
    send event
    */
    emit UserCreated(user, id);
  }

  /* 
  view indicates that the function doesn't change the state of the contract but
  it reads the state. Whereas pure indicates that the function neither reads or 
  writes the state of the contract.

  internal makes it accessible by the current contract
  and derived contracts only. it cannot be accessed externally
  */
  function isUserActive (address id) internal view returns (bool) {
    /* 
    assignments from storage to local storage always creates reference   
    */    
    User storage user = users[id];

    /*
    check if map key exists
    */
    if(user.age == 0) {
      revert("User doesn't exist");
    }

    if (user.status == UserStatus.ACTIVE) {
      return true;
    }

    return false;
  }

  function updateUserName (address id, string memory name) external onlyOwner {
    User storage user = users[id];

    bytes32 oldNameHash = keccak256(bytes(user.name));
    bytes32 nameHash = keccak256(bytes(name));
    
    /* 
    you cannot compare strings in solidity so we has to apply this
    trick
    */
    if (oldNameHash == nameHash) {
      /*
      revert is similar to require but it doesn't have a condition parameter and takes
      a error message string only

      also to throw custom errors we need to use revert
      */
      revert UnwantedUpdate(id, name);
    }
   
    user.name = name;

    /* 
    .push(...) is used to append (i.e., assign) an element to end of 
    an array

    assignments to storage always creates a copy. the assignment can be 
    from memory, local storage or storage
    */
    history[id].push(user);
  }

  /* 
  payable is an internal modifier which allows this function to receive ether.
  if payable is not specified and an transaction or external contract calls 
  this function with non-zero ether value then the transaction will be rejected
  and ether will be refunded 
  */
  function activateProfile () external payable {
    if (isUserActive(msg.sender) == false) {
      if (msg.value >= 0.1 ether) {
        users[msg.sender].status = UserStatus.ACTIVE;

        /*
        here we are creating an NFT representing your identity

        tokenCounter represents unique ID of each identity NFT
        */
        _mint(msg.sender, tokenCounter);
        tokenCounter++;
      } else {
        revert("Insufficient fees");
      }
    } else {
      revert("User is already active");
    }
  }

  /* 
  this function is called when the transaction data doesn't match any function name

  the payable modifier here indicates that this function will be called even if
  there is non-zero ether sent. if we remove the payable modifier then this will be
  called only if ether value is 0 and function name doesn't match

  in case payable modifier is removed and the function name doesn't match and ether value
  is non-zero then the transaction fails and ether is refunded. 
  */
  fallback() external payable {
    revert();
  }

  /* 
  this is called when a transaction sends ether to the contract without any data

  if this function is not defined then the transaction reverts and the ether
  is refunded to the caller
  */
  receive() external payable {
    revert();
  }
}