pragma solidity 0.5.16;

import "./LandController.sol";

contract LandNFT is LandController {

    // Set in case the core contract is broken and an upgrade is required
    address public newContractAddress;

    event NewLandCreated(uint256 tokenId, address owner);

    /// @notice Creates the main Dune Metaverse smart contract instance.
    constructor () public {
        // Starts paused.
        paused = true;

        // the creator of the contract is the initial CEO
        ceoAddress = msg.sender;
    }

    /// @dev Used to mark the smart contract as upgraded, in case there is a serious
    ///  breaking bug. This method does nothing but keep track of the new contract and
    ///  emit a message indicating that the new address is set. It's up to clients of this
    ///  contract to update to the new contract address in that case. (This contract will
    ///  be paused indefinitely if such an upgrade takes place.)
    /// @param _v2Address new address
    function setNewAddress(address _v2Address) external onlyCEO whenPaused {
        // See README.md for updgrade plan
        newContractAddress = _v2Address;
        emit ContractUpgrade(_v2Address);
    }

    /// @notice No tipping!
    /// @dev Reject all Ether from being sent here (Hopefully, we can prevent user accidents.)
    function() external payable {
        require(
            msg.sender == address(this)
        );
    }

    /// @notice Returns all the relevant information about a specific LAND NFT.
    /// @param _id The ID of the LAND NFT of interest.
    function getLandInfo(uint256 _id)
        external
        view
        returns (
        uint256 creationTime,
        uint256 tileId,
        uint256 value,
        address owner
    ) {
        Land storage land = lands[_id];

        creationTime = uint256(land.creationTime);
        tileId = uint256(land.tileId);
        owner = address(land.owner);
        value = uint256(land.value);
    }

    function createLand(
        uint256 _size,
        uint256 _tileId,
        uint256 _value,
        address _owner,
        string calldata _url,
        string calldata _element,
        string calldata _name
    )
        external
        onlyCEO
        returns (uint)
    {
        _createLand(_size, _tileId, _value, _owner, _url, _element, _name);
    }

    /// @dev Override unpause so it requires all external contract addresses
    ///  to be set before contract can be unpaused. Also, we can't have
    ///  newContractAddress set either, because then the contract was upgraded.
    /// @notice This is public rather than external so we can call super.unpause
    ///  without using an expensive CALL.
    function unpause() public onlyCEO whenPaused {
        require(newContractAddress == address(0));

        // Actually unpause the contract.
        super.unpause();
    }

    // @dev Allows the CFO to capture the balance available to the contract.
    function withdrawBalance() external onlyCFO {
        uint256 balance = address(this).balance;
        if (balance > 0) {
            cfoAddress.transfer(balance);
        }
    }
}
