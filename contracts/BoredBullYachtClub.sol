//SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./ERC721REnumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BoredBullYachtClub is ERC721rEnumerable, Ownable {

    // Project dependent parameters
    uint256 private constant MAX_SUPPLY = 2500;

    using Strings for uint256;
    string private baseURI;
    string private baseExtension = ".json";
    bool private paused = false;
    
    mapping(address => uint256) public WalletMintBalance;

    constructor(string memory _name, string memory _symbol, string memory _initBaseURI) 
        ERC721r(_name, _symbol, MAX_SUPPLY) {
            baseURI = _initBaseURI;
        }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0 ?
                string(abi.encodePacked(currentBaseURI, _tokenId.toString(), baseExtension)) : "";
    }
    
    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract.");
        _;
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory)  {
        return baseURI;
    }

    // public
    function mint() public callerIsUser {
        require(!paused, "Contract is paused.");
        require(WalletMintBalance[msg.sender] == 0, "You can mint only 1 NFT per wallet.");
        uint256 supply = totalSupply();
        require(supply < MAX_SUPPLY, "Collecton Sold.");

        _mintRandom(msg.sender, 1);
        WalletMintBalance[msg.sender]++;
    }

    function walletOfOwner(address _owner) public view returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    // Admin functions

    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension) external onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function pause(bool _state) external onlyOwner {
        paused = _state;
    }

    function withdraw() external payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }
}