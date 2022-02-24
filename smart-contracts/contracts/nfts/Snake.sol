// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

contract Snake is AccessControlEnumerable, ERC721Enumerable, ERC721Burnable  {

    event BaseURIChanged(string uri);

    event SnakeCreated(uint256 id, address owner, uint256[] propTypes, uint256[] propValues);

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    string private _uri;

    uint256 public currentId;

    mapping(uint256 => uint256) public props;

    constructor(string memory name, string memory symbol, string memory uri) ERC721(name, symbol) {
        _uri = uri;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
    }

    function setBaseURI(string memory uri) public virtual {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Snake: must have admin role to set");

        require(bytes(uri).length > 0, "Snake: uri is invalid");

        _uri = uri;

        emit BaseURIChanged(uri);
    }

    function mint(address to, uint256[] memory propTypes, uint256[] memory propValues) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "Snake: must have minter role to mint");

        _mint(to, ++currentId);

        uint256 length = propTypes.length;

        require(length == propValues.length, "Snake: array length is invalid");

        for (uint256 i = 0; i < length; i++) {
            props[propTypes[i]] = propValues[i];
        }

        emit SnakeCreated(currentId, to, propTypes, propValues);
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