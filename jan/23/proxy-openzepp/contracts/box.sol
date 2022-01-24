// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Box {
    uint256 x;
    bool initialized;

    function initialize() external {
        require(!initialized, "Box: already initialized");
        x = 42;
        initialized = true;
    }

    function setx(uint256 _x) external {
        x = _x;
    }
    function getx() external view returns(uint256) {
        return x;
    }
}


contract BoxV2 {
    uint256 x;

    function setx(uint256 _x) external {
        x = _x;
    }
    function getx() external view returns(uint256) {
        return x;
    }
    function double() external {
        x *= 2;
    }
}