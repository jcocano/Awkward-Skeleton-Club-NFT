// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

//Author: Block3 (@ferduhart, @richgtz)
//Developper: Jesus Cocaño (@jcocano)
//Tittle: Awkward Skeleton Club NFT

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "erc721a/contracts/ERC721A.sol";

contract AwkwardSkeletonClub is Ownable, ERC721A, PaymentSplitter{

    using Strings for uint;

    enum Phase {
        Whitelist,
        Public,
        SoldOut,
        Reveal
    }

    string private baseURI;
    string public hiddenURI;

    Phase public salesPhase;

    uint private constant MAXSUPPLY = 7373;
    uint private constant MAXMINTPERTX = 10;

    uint public wlprice = 0.03 ether;
    uint public pubprice = 0.04 ether;

    bool public paused = true;
    bool public revealed = false;


    bytes32 public merkleRoot;

    mapping(address => uint256) public totalPublicMint;
    mapping(address => uint256) public totalWhitelistMint;

    uint private teamLength;

    constructor(
        address[] memory _team,
        uint[] memory _teamShares,
        bytes32 _merkleRoot, 
        string memory _baseURI,
        string memory _hiddenURI
    ) ERC721A ("Awkward Skeleton Club", "ASC")
      PaymentSplitter(_team, _teamShares){
        merkleRoot = _merkleRoot;
        baseURI = _baseURI;
        hiddenURI = _hiddenURI;
        teamLength = _team.length;
    }

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "Cannot be called from another contract");
        _;
    }

    modifier mintCompliance(uint256 _mintAmmount) {
    require(_mintAmmount > 0 && _mintAmmount <= MAXMINTPERTX, "ASC: Mint must be greater than 0 and at most 10!");
    require(totalSupply() + _mintAmmount <= MAXSUPPLY, "ASC: Max supply exceeded!");
    _;
    }

    //Mint
    function whiteListMint(uint256 _mintAmmount, bytes32[] calldata _proof) external payable mintCompliance(_mintAmmount) callerIsUser{
        uint256 price = wlprice;
        require(price != 0, "ASC: Price must be greater that 0");
        require(salesPhase == Phase.Whitelist, "ASC: Whitelist sale is not activated");
        require(msg.value >= price * _mintAmmount, "You don't have enought funds");
        require(!paused, "ASC contract is paused!");
        require(isWhiteListed(msg.sender, _proof), "ASC: You'r not whitelisted");

        totalWhitelistMint[msg.sender] += _mintAmmount;
        _safeMint(msg.sender, _mintAmmount);
    }

    function publicMint(uint256 _mintAmmount) external payable mintCompliance(_mintAmmount) callerIsUser{
        uint256 price = pubprice;
        require(price != 0, "ASC: Price must be greater that 0");
        require(salesPhase == Phase.Public, "ASC: Public sale is not activated");
        require(msg.value >= price * _mintAmmount, "You don't have enought funds");
        require(!paused, "ASC contract is paused!");

        totalPublicMint[msg.sender] += _mintAmmount;
        _safeMint(msg.sender, _mintAmmount);
    }

    function givaweyMint(uint256 _mintAmmount, address _reciver) external mintCompliance(_mintAmmount) onlyOwner{
        _safeMint(_reciver, _mintAmmount);
    }

    //Miscellaneous
    function walletOfOwner(address _owner) external view returns (uint256[] memory) {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
    uint256 currentTokenId = _startTokenId();
    uint256 ownedTokenIndex = 0;
    address latestOwnerAddress;

    while (ownedTokenIndex < ownerTokenCount && currentTokenId <= MAXSUPPLY) {
    TokenOwnership memory ownership = _ownerships[currentTokenId];

    if (!ownership.burned && ownership.addr != address(0)) {
        latestOwnerAddress = ownership.addr;
    }

    if (latestOwnerAddress == _owner) {
        ownedTokenIds[ownedTokenIndex] = currentTokenId;

        ownedTokenIndex++;
        }

      currentTokenId++;
    }

    return ownedTokenIds;
    }

    function _startTokenId() internal view virtual override returns (uint256) {
    return 1;
    }

    function selectPhase(uint _phase) external onlyOwner{
        salesPhase = Phase(_phase);
    }

    function setPaused(bool _state) external onlyOwner {
        paused = _state;
    }

    function setBaseUri(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    function setHiddenMetadataUri(string memory _hiddenURI) external onlyOwner {
        hiddenURI = _hiddenURI;
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
    require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");

    if (revealed == false) {
      return hiddenURI;
    } 

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), ".json"))
        : '';
    }

    function setRevealed(bool _state) external onlyOwner {
        revealed = _state;
    }

    //Whitelist
    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function isWhiteListed(address _account, bytes32[] calldata _proof) internal view returns(bool) {
        return _verify(leaf(_account), _proof);
    }

    function leaf(address _account) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(_account));
    }

    function _verify(bytes32 _leaf, bytes32[] memory _proof) internal view returns(bool) {
        return MerkleProof.verify(_proof, merkleRoot, _leaf);
    }

    //withdrawal
    function withdrawalsAll() external {
        for(uint i = 0 ; i < teamLength ; i++) {
            release(payable(payee(i)));
        }
    }

}