// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Erc721.sol";
import "./Ownable.sol";

contract BPNft is Erc721, Ownable{

    function _mint(address _to, uint256 _tokenId, string calldata _uri) external onlyOwner {
        super._mint(_to, _tokenId);
        super._setTokenUri(_tokenId, _uri);
    }


}
