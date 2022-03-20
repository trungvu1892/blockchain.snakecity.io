// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

contract OpenSnakeEgg is AccessControlEnumerable, ERC721Enumerable, ERC721Burnable {

    uint eggPrice = 20;

    uint randNonce = 0;

    event BaseURIChanged(string uri);

    uint256 public currentId;

    string private _uri;

    struct SnakeEgg {
        string snakeSpiece;
        uint star;

    }

    event OpenSnake(uint256 id, address owner, SnakeEgg newSnake);

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    constructor(string memory name, string memory symbol, string memory uri) ERC721(name, symbol) {
        _uri = uri;

        _setupRole(MINTER_ROLE, _msgSender());
    }

    function setBaseURI(string memory uri) public virtual {
        require(bytes(uri).length > 0, "Snake: uri is invalid");

        _uri = uri;

        emit BaseURIChanged(uri);
    }

    function getBalance() external view returns(uint) {
        return address(this).balance;    
    }

    function getSpiece() private view returns (string memory) 
    {   
        uint8 randomSpiece = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, randNonce))) %4 );
        if(randomSpiece == 0){
            return "Water";
        }
        if(randomSpiece == 1){
            return "Fire";
        }
        if(randomSpiece == 2){
            return  "Ice";
        }
        if(randomSpiece == 3){
            return "Land";
        }
        return "";
    } 

    function getRarity() private pure returns (uint) {
        return 1;
    }

    function mint(address to) public virtual payable {
        require(msg.value >= eggPrice, "Not enough SNCT Token!");
        _mint(to, ++currentId);

        string memory snakeSpiece = getSpiece();
        
        uint star = 1;

        SnakeEgg memory newSnake = SnakeEgg(snakeSpiece, star);

        emit OpenSnake(currentId, to, newSnake);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _uri;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlEnumerable, ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}