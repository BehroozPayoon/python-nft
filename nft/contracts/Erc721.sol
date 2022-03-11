// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IErc721.sol";
import "../interfaces/IERC721Metadata.sol";

contract Erc721 is IErc721, IERC721Metadata {
    string constant NOT_OWNER_OR_OPERATOR = "You are not owner or operator of token";
    string constant NOT_OWNER_APPROVED_OR_OPERATOR = "You dont have permission to transfer";
    string constant NOT_VALID_TOKEN = "Not a valid token";
    string constant NOT_OWNER = "Not token owner";
    string constant ZERO_ADDRESS = "Zero address error";
    string constant IS_OWNER = "You are token owner";
    string constant TOKEN_ALREADY_EXISTS = "Token already exists";

    /**
    * Name of collection
    */
    string internal name;
    /**
    * Symbol of collection
    */
    string internal symbol;
    /**
    * Mapping from tokenId to metadata uri.
    */
    mapping (uint256 => string) internal idToUri;

     /**
     * Mapping for tokenId to owner address
     */
    mapping(uint256 => address) internal idToOwner;

    /**
     * Mapping for tokenId to approved address
     */
    mapping(uint256 => address) internal idToApproval;

    /**
     * Mapping from owner address to count of tokens
     */
    mapping(address => uint256) internal ownerToTokenCount;

    /**
    *  Mapping from owner address to mapping of operator addresses.
    */
    mapping (address => mapping (address => bool)) internal ownerToOperators;

    constructor(string _name, string _symbol) {
        name = _name;
        symbol = _symbol;
    }

    modifier canOperate(uint256 _tokenId) {
        address tokenOwner = idToOwner[_tokenId];
        require(tokenOwner == msg.sender || ownerToOperators[tokenOwner][msg.sender], NOT_OWNER_OR_OPERATOR);
        _;
    }

    modifier canTransfer(uint256 _tokenId) {
        address tokenOwner = idToOwner[_tokenId];
        require(tokenOwner == msg.sender
        || idToApproval[_tokenId] == msg.sender
        || ownerToOperators[tokenOwner][msg.sender],
        NOT_OWNER_APPROVED_OR_OPERATOR);
        _;
    }

    modifier validToken(uint256 _tokenId) {
        require(idToOwner[_tokenId] != address(0), NOT_VALID_TOKEN);
        _;
    }

    function name() external override view returns (string memory) {
        return name;
    }

    function symbol() external override view returns (string memory) {
        return symbol;
    }

    function tokenURI(uint256 _tokenId) external override view validToken(_tokenId) returns (string memory) {
        return _tokenURI(_tokenId);
    }

    function safeTransferFrom(
        address _from, address _to, uint256 _tokenId, bytes calldata _data) external override {
        _safeTransferFrom(_from, _to, _tokenId, _data);
    }

    function safeTransferFrom(
        address _from, address _to, uint256 _tokenId) external override {
        _safeTransferFrom(_from, _to, _tokenId, "");
    }

    function transferFrom(
        address _from, address _to, uint256 _tokenId) external override canTransfer(_tokenId) validToken(_tokenId) {
        address tokenOwner = idToOwner[_tokenId];
        require(tokenOwner == _from, NOT_OWNER);
        require(_to != address(0), ZERO_ADDRESS);

        _transfer(_to, _tokenId);
    }

    function approve(
        address _approved, uint256 _tokenId) external override canOperate(_tokenId) validToken(_tokenId) {
        address tokenOwner = idToOwner[_tokenId];
        require(_approved != tokenOwner, IS_OWNER);
        idToApproval[_tokenId] = _approved;
        emit Approval(tokenOwner, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) external override {
        ownerToOperators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function balanceOf(address _owner) external override view returns(uint256) {
        require(_owner != address(0), ZERO_ADDRESS);
        return _getOwnedTokensCount(_owner);
    }

    function ownerOf(uint256 _tokenId) external override view returns (address _owner) {
        _owner = idToOwner[_tokenId];
        require(_owner != address(0), ZERO_ADDRESS);
    }

    function getApproved(uint256 _tokenId) external override view validToken(_tokenId) returns (address){
        return idToApproval[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) external override view returns (bool){
        return ownerToOperators[_owner][_operator];
    }

    function _tokenURI(uint256 _tokenId) internal virtual view returns (string memory) {
        return idToUri[_tokenId];
    }

    function _safeTransferFrom(
        address _from, address _to, uint256 _tokenId, bytes memory _data) private canTransfer(_tokenId) validToken(_tokenId) {
        address tokenOwner = idToOwner[_tokenId];
        require(tokenOwner == _from, NOT_OWNER);
        require(_to != address(0), ZERO_ADDRESS);

        _transfer(_to, _tokenId);
    }

    function _transfer(address _to, uint256 _tokenId) internal virtual validToken(_tokenId) {
        address from = idToOwner[_tokenId];
        _clearApproval(_tokenId);
        _removeToken(from, _tokenId);
        _addToken(_to, _tokenId);
        emit Transfer(from, _to, _tokenId);
    }

    function _mint(address _to, uint256 _tokenId) internal virtual {
        require(_to != address(0), ZERO_ADDRESS);
        require(idToOwner[_tokenId] == address(0), TOKEN_ALREADY_EXISTS);
        _addToken(_to, _tokenId);
        emit Transfer(address(0), _to, _tokenId);
    }

    function _burn(uint256 _tokenId) internal virtual validToken(_tokenId) {
        address tokenOwner = idToOwner[_tokenId];
        _clearApproval(_tokenId);
        _removeToken(tokenOwner, _tokenId);
        delete idToUri[_tokenId];
        emit Transfer(tokenOwner, address(0), _tokenId);
    }

    function _clearApproval(uint256 _tokenId) private
    {
        delete idToApproval[_tokenId];
    }

    function _removeToken(address _from, uint256 _tokenId) internal virtual{
        require(idToOwner[_tokenId] == _from, NOT_OWNER);
        ownerToTokenCount[_from] -= 1;
        delete idToOwner[_tokenId];
    }

    function _addToken(address _from, address _to, uint256 _tokenId) internal virtual {
        require(idToOwner[_tokenId] == address(0), TOKEN_ALREADY_EXISTS);
        idToOwner[_tokenId] = _to;
        ownerToTokenCount[_to] += 1;
    }

    function _getOwnedTokensCount(address _owner) internal virtual view returns (uint256) {
        return ownerToTokenCount[_owner];
    }

    function _setTokenUri(uint256 _tokenId, string memory _uri) internal validToken(_tokenId) {
        idToUri[_tokenId] = _uri;
    }
}
