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
        _setTokenURI9(newTokenId, tokenURI);
        createMarketItem(newTokenId, price);
        return newTokenId;
    }

    // Create Market Item
    function createMarketItem(uint256 tokenId, uint256 price) private {
        require(price > 0, "Price must be at least 1");
        require(msg.value == listingPrice, "Price must be equal to listing price");
        idMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false
        );
        _transfer(msg.sender, address(this), tokenId);
        emit idMarketItemCreated(tokenId, msg.sender, address(this), price, false);
    }

    // Function Of Resale NFT Token
    function reSaleToken(uint256 tokenId, uint256 price) public payable {
        require(idMarketItem[tokenId].owner == msg.sender, "Only item owner can purchase this operation");
        require(msg.value == listingPrice, "Price must be equal to lsting price");
        idMarketItem[tokenId].sold = false;
        idMarketItem[tokenId].price = price;
        idMarketItem[tokenId].owner = payable(address(this));
        idMarketItem[tokenId].seller = payable(msg.sender);
        _itemsSold.decrement();
        _transfer(msg.sender, address(this), tokenId);
    } 

    //Function Create Market Sale
    function createMarketSale(uint256 price) public payable {
        uint256 price = idMarketItem[_tokenIds].price;
        require(msg.value == price, "Please submit the aasking price in order to complete the purchase");
        idMarketItem[tokenId].owner =  payable(msg.sender);
        idMarketItem[tokenId].sold = true;
        idMarketItem[tokenId].owner = payable(address(0));
        _itemsSold.increment(); 
        _transfer(address(this), msg.sender, tokenId);
        payable(owner).transfer(listingPrice);
        payable(idMarketItem[tokenId].seller).tranfer(msg.value);
    }

    //Function For Unsold NFT Data
    function fetchMarketItem() public view returns(MarketItem[] memory) {
        uint256 itemCount = _tokenIds.current();
        uint256 unsoldItemCount = _tokenIds.current(); - _itemsSold.current();
        uint256 currentIndex = 0;
        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (idMarketItem[i + 1].owner == address(this)) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }  
        return items;
    }

    //Purchase Items
    function fetchMyNft() public view returns(MarketItem[] memory){
        uint256 totalCount = _tokenIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalCount; i++) {
            if (idMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }
        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalCount; i++) {
            if (idMarketItem[i + 1].owner ==  msg.sender) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    //Singule User Items
    function fetchItemsListed() public view returns (MarketItem[] memory) {
        uint256 totalCount = _tokenIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < totalCount; i++) {
            if (idMarketItem[i + 1].seller == msg.sender) {
                itemCount += 1;
            }
        }
        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalCount; i++) {
            if (idMarketItem[i + 1].seller ==  msg.sender) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

}
