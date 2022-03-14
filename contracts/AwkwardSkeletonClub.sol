// SPDX-License-Identifier: MIT 

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract AwkwardSkeletonClub is AccessControl, ERC721, ERC721Enumerable{

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    uint256 public maxSupply;

    constructor(uint256 _maxSupply) ERC721("AwkwardSkeletonClub", "ASC") {
        _grantRole(ADMIN_ROLE, msg.sender);
        maxSupply = _maxSupply;
    }

    //Modifiers
    modifier onlyAdmin(){
        require(hasRole(ADMIN_ROLE, msg.sender), "This function can only be used by the admin");
        _;
    }

    //Functions
    function mint() public{

        _safeMint(msg.sender, tokenId);
    }

    //Roles
    function addRole(bytes32 role, address account) public onlyAdmin {
        _grantRole(role, account);
    }

    function revoRole(bytes32 role, address account) public onlyAdmin {
       _revokeRole(role, account);
    }

    //Overide Interface

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}