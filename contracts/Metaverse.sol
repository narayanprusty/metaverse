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
inhertance basically copies code from parent contract to
child contract

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
}