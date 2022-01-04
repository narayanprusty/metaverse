//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Identity {

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
  error UnwantedUpdate(address id, UserStatus status);

  constructor () {
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

  external makes it accessible externally only 
  */
  function registerUser (string calldata name, uint age) external onlyOwner {
    User memory user = User(name, UserStatus.ACTIVE, age);

    /*
    assigments from memory to memory always creates a reference
    */
    address id = msg.sender;

    /* 
    assignments from memory to storage or vice-versa always creates an
    independent copy 
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

    if (user.status == UserStatus.ACTIVE) {
      return true;
    }

    return false;
  }

  function updateUserStatus (address id, UserStatus status) external onlyOwner {
    User storage user = users[id];

    
    if (user.status == status) {
      /*
      revert is similar to require but it doesn't have a condition parameter and takes
      a error message string only

      also to throw custom errors we need to use revert
      */
      revert UnwantedUpdate(id, status);
    }
   
    user.status = status;

    /* 
    .push(...) is used to append (i.e., assign) an element to end of 
    an array

    assignments to storage always creates a copy. the assignment can be 
    from memory, local storage or storage
    */
    history[id].push(user);
  }
}