// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Proxy {
    address public implementation; // Address of the logic contract
    address public admin;          // Address of the admin (who can upgrade the implementation)

    event Upgraded(address indexed newImplementation);

    constructor(address _implementation) {
        implementation = _implementation;
        admin = msg.sender;
    }

    // Function to upgrade the logic contract
    function upgrade(address _newImplementation) external {
        require(msg.sender == admin, "Only admin can upgrade");
        require(_newImplementation != address(0), "Invalid implementation address");
        implementation = _newImplementation;
        emit Upgraded(_newImplementation);
    }

    // Fallback function to delegate calls to the implementation contract
    fallback() external payable {
        _delegate(implementation);
    }

    // Receive function to accept ETH
    receive() external payable {
        _delegate(implementation);
    }

    // Delegate function with proper error handling
    function _delegate(address _impl) internal {
        require(_impl != address(0), "Implementation not set");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), _impl, 0, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(0, 0, size)
            switch result
            case 0 { revert(0, size) }
            default { return(0, size) }
        }
    }
}
