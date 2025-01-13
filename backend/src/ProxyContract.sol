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

    // Delegate function
    function _delegate(address _impl) internal {
        require(_impl != address(0), "Implementation not set");
        (bool success, bytes memory data) = _impl.delegatecall(msg.data);
        require(success, "Delegatecall failed");
    }
}
