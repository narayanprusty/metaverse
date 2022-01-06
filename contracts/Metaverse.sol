//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/*
you can import .sol files from npm, local directory,
github URL, swarm and IPFS. 
*/
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Identity.sol";

/*
a contract can inherit one ore more contracts. in solidity
inhertance basically copies code (functions and modifiers) 
from parent contract to child contract

when inheriting two or more contracts and if they have functions
with same name then they must be overridden.

when overriding parent contract functions you need to make sure
the funciton arguments match otherwise compiler will throw error

state variables of parent contracts cannot be access by child contracts

ERC721 is standard for representing NFTs. Each ERC721 holds
multiple NFTs of an DApp. For example: A Pokemon like game
will have a single ERC721 contract and each pokemons will be 
represented by a token in the contract. Each token will have an owner.
*/
contract Metaverse is ERC721, Identity {
  uint256 private tokenCounter;

  /*
  constructor is executed during initialization of the contract. if you are inheriting
  other contracts then you must invoke their constructors also
  */
  constructor (
    string memory name,
    string memory symbol
  ) ERC721(name, symbol) Identity() {}

  /*
  override keyword must be specified to override a virtual function
  */
  function profileActivated(address id) internal override {
    _mint(id, tokenCounter);
    tokenCounter++;
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