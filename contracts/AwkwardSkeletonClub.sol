// SPDX-License-Identifier: MIT 

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";


contract AwkwardSkeletonClub is AccessControl, ERC721, ERC721Enumerable{
    //Roles
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant COMMUNITY_ROLE = keccak256("COMMUNITY_ROLE");

    //Vars

    string public baseURI;
    string public baseExtension = ".json";
    string public notRevealedUri;

    uint256 public cost = 0.04 ether;
    uint256 public whiteListCost = 0.03 ether;
    uint256 public maxSupply = 7373;
    uint256 public maxMintAmount = 10;

    bool public paused = true;
    bool public revealed = false;

    constructor() ERC721("AwkwardSkeletonClub", "ASC") {
        _grantRole(ADMIN_ROLE, msg.sender);

    }

    //Modifiers
    modifier onlyAdmin(){
        require(hasRole(ADMIN_ROLE, msg.sender), "This function can only be used by the admin");
        _;
    }
    modifier onlyCommunity(){
        require(hasRole(COMMUNITY_ROLE, msg.sender), "This function can only be used by commuty wallet");
        _;
    }

    //Roles
    function addRole(bytes32 role, address account) public onlyAdmin {
        _grantRole(role, account);
    }

    function revoRole(bytes32 role, address account) public onlyAdmin {
       _revokeRole(role, account);
    }

    //functions
    function reveal() public onlyAdmin {
        revealed = true;
    }

    function setCost(uint256 _newCost) public onlyAdmin {
        cost = _newCost;
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyAdmin {
        maxMintAmount = _newmaxMintAmount;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyAdmin {
        notRevealedUri = _notRevealedURI;
    }
    
    function pause(bool _state) public onlyAdmin {
        paused = _state;
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