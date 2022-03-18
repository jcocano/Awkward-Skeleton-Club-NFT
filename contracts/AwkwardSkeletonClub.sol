// SPDX-License-Identifier: MIT 

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";


contract AwkwardSkeletonClub is AccessControl, ERC721, ERC721Enumerable{
    
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private supply;

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

    constructor(
        string memory _initBaseURI,
        string memory _initNotRevealedUri
    ) ERC721("AwkwardSkeletonClub", "ASC") {
        _grantRole(ADMIN_ROLE, msg.sender);

        setBaseURI(_initBaseURI);
        setNotRevealedURI(_initNotRevealedUri);

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

    modifier mintConditional(uint256 _mintAmount ){
        require(_mintAmount > 0 && _mintAmount <= maxMintAmount, "Wrong amount of mint, must be between 1 and 10");
        require(supply.current() + _mintAmount <= maxSupply, "Max Supply exeded!");
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
    function mint(uint256 _mintAmount) public payable mintConditional(_mintAmount){
        require(!paused,"ASC is on Pause!");
        require(msg.value >= cost * _mintAmount, "Insufficient funds!");

        _mintFunction(msg.sender, _mintAmount);
    }

    function givaweyMint(uint256 _mintAmount, address _reciver) public mintConditional(_mintAmount) onlyCommunity{
        _mintFunction(_reciver, _mintAmount);
    } 

    function reveal(bool _newState) public onlyAdmin {
        revealed = _newState;
    }

    function setCost(uint256 _newCost) public onlyAdmin {
        cost = _newCost;
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyAdmin {
        maxMintAmount = _newmaxMintAmount;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyAdmin
    {
        baseExtension = _newBaseExtension;
    }

    function setBaseURI(string memory _newBaseURI) public onlyAdmin {
        baseURI = _newBaseURI;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyAdmin {
        notRevealedUri = _notRevealedURI;
    }
    
    function pause(bool _state) public onlyAdmin {
        paused = _state;
    }

    function _mintFunction(address _reciver, uint256 _mintAmount) internal {
        for (uint256 i = 0; i < _mintAmount; i++) {
        supply.increment();
        _safeMint(_reciver, supply.current());
        }
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