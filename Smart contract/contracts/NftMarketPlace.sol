// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// Internal import for nft Openzeppline
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "hardhat/console"; 

contract AFMarketplace is ERC721URIStorage{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;

    uint256 listingPrice = 0.0000011 ether;

    address payable owner;

    mapping(uint256 => MarketItem) private idMarketItem;

    struct MarketItem {
        uint256 tokenId;
        address payable owner;
        address payable seller;
        uint256 price;
        bool sold;
    }

    event idMarketItemCreated (
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner of the marketplace can change the listing price");
        _;
    }

    constructor () ERC721 ("Africa NFT Token", ANT) {
        owner == payable(msg.sender);
    }

    // This function is use for updating charging fee for users listing NFT on the marketplace, 
    function updateListingPrice(uint256 _listingPrice) public payable onlyOwner{
        _listingPrice = listingPrice;   
    }

    //This function help fetch the listing price
    function getListingPrice() public view returns(uint256) {
        return listingPrice;
    }

    //NFT Create Token
    function createToken(string memory tokenURI, uint256 price) public payable returns(uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _mint(msg.sender, newTokenId);
         
    }
}
