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

    struct SnakeRarity {
         uint star;
         uint percentage;
    }

    SnakeRarity[5] public snakeRarities;

    struct SnakeEgg {
        string snakeSpiece;
        uint star;

    }

    event OpenSnake(uint256 id, address owner, SnakeEgg newSnake);

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    constructor(string memory name, string memory symbol, string memory uri) ERC721(name, symbol) {
        _uri = uri;

        _setupRole(MINTER_ROLE, _msgSender());

        snakeRarities[0] = SnakeRarity({star: 1, percentage: 50});
        snakeRarities[1] = SnakeRarity({star: 2, percentage: 25});
        snakeRarities[2] = SnakeRarity({star: 3, percentage: 18});
        snakeRarities[3] = SnakeRarity({star: 4, percentage: 6});
        snakeRarities[4] = SnakeRarity({star: 5, percentage: 1});
    }

    function setBaseURI(string memory uri) public virtual {
        require(bytes(uri).length > 0, "Snake: uri is invalid");

        _uri = uri;

        emit BaseURIChanged(uri);
    }

    function getBalance() external view returns(uint) {
        return address(this).balance;    
    }

    function getSpiece(uint8 randomSpiece) private pure returns (string memory spiece) 
    {   
        if(randomSpiece == 0){
            return "Water";
        }
        else if(randomSpiece == 1){
            return "Fire";
        }
        else if(randomSpiece == 2){
            return "Ice";
        }
        else if(randomSpiece == 3){
            return "Land";
        }
    } 

    function getRarity() public view returns (uint) {
        // uint snakeStar = 1;
        // uint256[] probability;
        // for (uint256 i = 0; i < snakeRarities.length; i++) {
        //     // 
        // }
        // uint pIndex = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, randNonce))) % 100 );
        // uint rarity = snakeRarities[probability[pIndex]];
        // snakeStar = rarity.star;
        // return snakeStar;
    }

    function mint(address to) public virtual payable {
        // require(msg.value >= eggPrice, "Not enough SNCT Token!");
        _mint(to, ++currentId);

  uint8 randomSpiece = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, randNonce))) %4 );
        string memory snakeSpiece = getSpiece(randomSpiece);
        
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