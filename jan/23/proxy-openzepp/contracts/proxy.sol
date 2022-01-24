// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { StorageSlot } from "./storage.sol";

contract Proxy {
    bytes32 private constant _IMPL_SLOT =
        bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
    bytes32 private constant _ADMIN_SLOT =
        bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

    constructor() {
        _setAdmin(msg.sender);
    }

    modifier ifAdmin() {
        require(msg.sender == _admin(), "proxy: only admin");
        _;
    }

    function setImplementation(address implementation_) external virtual ifAdmin {
        StorageSlot.setAddressAt(_IMPL_SLOT, implementation_);
    }

    function getImplementation() external view returns (address) {
        return _implementation();
    }

    function setAdmin(address admin_) public virtual ifAdmin {
        _setAdmin(admin_);
    }

    function getAdmin() external view returns (address) {
        return _admin();
    }


    function _delegate(address implementation) internal virtual {
        // assembly {
        //     calldatacopy(0, 0, calldatasize())
        //     let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)
            
        //     returndatacopy(0, 0, returndatasize())

        //     switch result
        //     // delegatecall returns 0 on error.
        //     case 0 { revert(0, returndatasize()) }
        //     default { return(0, returndatasize()) }
        // }

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())

            let result := delegatecall(
                gas(),
                implementation, // get slot address of the address variable, since state vars are just syntactic sugar
                ptr,
                calldatasize(),
                0,
                0
            )

            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }

    function _setAdmin(address admin_) internal {
        StorageSlot.setAddressAt(_ADMIN_SLOT, admin_);
    }

    function _admin() internal view virtual returns (address) {
        return StorageSlot.getAddressAt(_ADMIN_SLOT);
    }
    function _implementation() internal view virtual returns (address) {
        return StorageSlot.getAddressAt(_IMPL_SLOT);
    }


    function _fallback() internal virtual {
        if (msg.sender == _admin()) {
            // admin cant call the functions , why ??
        } else {
            _beforeFallback();
            _delegate(_implementation());
        }
        
    }

    fallback () external payable virtual {
        _fallback();
    }

    receive () external payable virtual {
        _fallback();
    }

    function _beforeFallback() internal virtual {
    }
}

/*
diff between internal and external , internal can be used in constructors etc , one time
and use the same function in external calls with some condition
*/