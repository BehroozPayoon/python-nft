pragma solidity ^0.8.0;

library AddressUtils {
    function isContract(address _addr) internal view returns (bool addressCheck) {
        bytes32 codeHash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codeHash := extcodehash(_addr) }
        addressCheck = (codeHash != 0x0 && codeHash != accountHash);
    }
}
