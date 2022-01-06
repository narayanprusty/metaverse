/*
interfaces are used to defined prototype of contracts
in the context of clients

interfaces can have unimplemented functions only

all the functions in interface should be external and 
by all functions are implicitely virtual

contracts can inherit interfaces to make sure they are
adhering to the prototype
*/
interface Object {
  function setTokenData(uint256 tokenId, string memory data) external;
  function getTokenData(uint256 tokenId) external view returns (string memory);
}