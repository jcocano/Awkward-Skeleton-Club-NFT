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

    enum phase {
        Whitelist,
        Public,
        SoldOut,
        Reveal
    }

    string public baseURI;

    phase public salesPhase;

    uint private constant MAXSUPPLY = 7373;
    uint private constant MAXMINTPERTX = 10;

    uint public wlprice = 0.03 ether;
    uint public price = 0.04 ether;

    bool public paused = true;
    bool public whitelistMint = false;
    bool public revealed = false;


    bytes32 public merkleRoot;

    mapping(address => uint256) public totalPublicMint;
    mapping(address => uint256) public totalWhitelistMint;

    uint private teamLength;

    constructor(
        address[] memory _team,
        uint[] memory _teamShares,
        bytes32 _merkleRoot, 
        string memory _baseURI
    ) ERC721A ("Awkward Skeleton Club", "ASC")
      PaymentSplitter(_team, _teamShares){
        merkleRoot = _merkleRoot;
        baseURI = _baseURI;
        teamLength = _team.length;
    }

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "Cannot be called from another contract");
        _;
    }

    modifier mintCompliance(uint256 _mintAmmount) {
    require(_mintAmmount > 0 && _mintAmmount <= MAXMINTPERTX, 'Mint must be greater than 0 and at most 10!');
    require(totalSupply() + _mintAmmount <= MAXSUPPLY, 'Max supply exceeded!');
    _;
    }

    //Mint
    function whiteListMint(uint256 _mintAmmount, bytes32[] calldata _proof) external payable mintCompliance(_mintAmmount) callerIsUser{
        //TBW
    }

    function publicMint(uint256 _mintAmmount, bytes32[] calldata _proof) external payable mintCompliance(_mintAmmount) callerIsUser{
        //TBW
    }

    function givaweyMint(uint256 _mintAmmount, address _reciver) public mintCompliance(_mintAmmount) onlyOwner{
        _safeMint(_reciver, _mintAmmount);
    }

    //Miscellaneous
    function selectPhase(uint _phase) external onlyOwner{
        salesPhase = phase(_phase);
    }

    function setPaused(bool _state) public onlyOwner {
        paused = _state;
    }

    function setRevealed(bool _state) public onlyOwner {
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