// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


contract Proxy {

    // seems like this is embedded in a way so can be ignored while calling proxy functions
    bytes32 private constant _IMPL_SLOT =
        bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
    bytes32 private constant _ADMIN_SLOT =
        bytes32(uint256(keccak256("eip1967.proxy.owner")) - 1);
    // address public implementation; // better not use it but direct assembly code !!!!
    // address public admin = msg.sender; // better not use it but direct assembly code !!!!
    
    // address public owner; // THIS WAS SET AS 45 in hex ???????????

    // uint256 magicNumber; // not required
    // bool initialized;    // not required

    function setImplementation(address implementation_) public {
        require(getAdmin() == msg.sender, "proxy:only admin");
    StorageSlot.setAddressAt(_IMPL_SLOT, implementation_);
    }

    function getImplementation() public view returns (address) {
    return StorageSlot.getAddressAt(_IMPL_SLOT);
    }

    function setAdmin(address admin_) public {
    StorageSlot.setAddressAt(_ADMIN_SLOT, admin_);
    }

    function getAdmin() public view returns (address) {
    return StorageSlot.getAddressAt(_ADMIN_SLOT);
    }


    fallback() external {
        _delegate(StorageSlot.getAddressAt(_IMPL_SLOT));
    }

    function _delegate(address addr) internal {
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())

            let result := delegatecall(
                gas(),
                addr, // get slot address of the address variable, since state vars are just syntactic sugar
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

}




contract Box {
    uint256 magicNumber;
    bool initialized;
    
    function initialize() public { // equivalent to constructor
    require(!initialized, "already initialized");
    magicNumber = 42;
    initialized = true;
    }

    function setMagicNumber(uint256 newMagicNumber) public {
    magicNumber = newMagicNumber;
    }

    function getMagicNumber() public view returns (uint256) {
    return magicNumber;
    }

    function getInit() public view returns (bool) {
    return initialized;
    }
}


contract BoxV2 {
    uint256 magicNumber;

    function setMagicNumber(uint256 newMagicNumber) public {
    magicNumber = newMagicNumber;
    }

    function getMagicNumber() public view returns (uint256) {
    return magicNumber;
    }

    function double() public {
    magicNumber *= 2;
    }

}

contract Ownable {
    address owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    function transferOwnership(address newowner) external onlyOwner {
        owner = newowner;
    }

}

contract ProxyAdmin is Ownable {
    
    constructor() Ownable() {
    }
}

// library for low level storage management
library StorageSlot {
  function getAddressAt(bytes32 slot) internal view returns (address a) {
    assembly {
      a := sload(slot)
    }
  }

  function setAddressAt(bytes32 slot, address address_) internal {
    assembly {
      sstore(slot, address_)
    }
  }
}


/*

THEORY
------

Proxy contracts are a way to upgrade the underlying logic of the contracts.

But they dont upgrade the state, if you need that, better to deploy another set of proxy contracts.



User -> Proxy [ State stored here] ----> Contract1 Logic
                                     |
                                     |
                                     --> Contract2 Logic


how to use proxy contract, simply reinitiate the contract with the abi ( after all u need only abi and address )


Ethereum transactions contain a field called data.
This field is optional and must be empty when sending ethers, but, when interacting with a contract, it must contain something.
It contains call data, which is information required to call a specific contract function.

Function keccak signature and params encoded together form the data that is used to execute contract call

When delegatecall is used, callee uses caller’s state. That’s it: the contract you’re calling with delegatecall uses the state of the caller contract.

imagine we have a contract that we are using for a long time, we dont want to change the state but only logic
hence delegatecall is the best method for this

if we use only impementation and magicNumber then its a problem as they are occupying the same memory slot

So STORE implementation contract address at a unique address

ok seems like variables in proxy contracts are not required

generally openzeppelin provides PROXY_ADMIN contract which is used to set addresses etc in proxy contracts

actually the vairables order should be same in logic contracts and not required in proxy contracts

not 100% sure but UUPS vs Transparent, they are almost same but UUPS requires setting on the other end
unlike transparent which requires setting it on the proxy end

ok i faced many problems while trying to initialize owner / admin , i guess that is why we use ProxyAdmin

so i understood the error and how to resolve it
this is it ......
1. dont use any vars in proxy contract
2. use assembly to get and set the slot
3. use constructor, that is not a problem
4. use modifier that is also ok to know that only admin is calling the contract
5. use proxyadmin to call the proxy contract maybe, that is best, if its admin then all function else only the other function

https://www.youtube.com/watch?v=JgSj7IiE4jA for possible errors maybe

*/