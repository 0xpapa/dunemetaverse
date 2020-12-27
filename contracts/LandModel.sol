pragma solidity 0.5.16;

import "./AccessControl.sol";

contract LandModel is AccessControl {
    /*** EVENTS ***/

    /// @dev The Creation event is fired whenever new piece of land comes into existence. This obviously
    ///  includes any time land is created through the _createland method
    event Creation(address indexed owner, uint256 landId, uint256 tileId, uint256 weight, uint64 creationTime);

    /// @dev Transfer event as defined in current draft of ERC721. Emitted every time land
    ///  ownership is assigned.
    event Transfer(address indexed from, address indexed to, uint256 tokenId);

    /*** DATA TYPES ***/

    /// @dev The main Land struct. Every land in Dune Metaverse is represented by a copy
    ///  of this structure, so great care was taken to ensure that it fits neatly into
    ///  exactly two 256-bit words. Note that the order of the members in this structure
    ///  is important because of the byte-packing rules used by Ethereum.
    ///  Ref: http://solidity.readthedocs.io/en/develop/miscellaneous.html
    struct Land {
        uint256 value;
        address owner;
        uint256 size;

        string url;
        string element;
        string name;

        // The timestamp from the block when this land came into existence.
        uint64 creationTime;
        uint32 tileId;
    }

    /*** STORAGE ***/

    /// @dev An array containing the land struct for all lands in existence. The ID
    ///  of each land is actually an index into this array.
    Land[] lands;

    /// @dev A mapping from land IDs to the address that owns them.
    mapping (uint256 => address) public landIndexToOwner;

    // @dev A mapping from owner address to count of tokens that address owns.
    //  Used internally inside balanceOf() to resolve ownership count.
    mapping (address => uint256) ownershipTokenCount;

    /// @dev A mapping from landIDs to an address that has been approved to call
    ///  transferFrom(). Each land can only have one approved address for transfer
    ///  at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public landIndexToApproved;

    /// @dev Assigns ownership of a specific land to an address.
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        ownershipTokenCount[_to]++;
        // transfer ownership
        landIndexToOwner[_tokenId] = _to;
        // When creating new Land NFT _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;

            // clear any previously approved ownership exchange
            delete landIndexToApproved[_tokenId];
        }
        // Emit the transfer event.
        emit Transfer(_from, _to, _tokenId);
    }

    /// @dev An internal method that creates a new land and stores it. This
    ///  method doesn't do any checking and should only be called when the
    ///  input data is known to be valid. Will generate both a Creation event
    ///  and a Transfer event.
    /// @param _size The area size of the NFT
    /// @param _tileId The tileId represented on the dune metaverse
    /// @param _value The amount this NFT got sold for
    /// @param _owner The new owner of this land
    function _createLand(
        uint256 _size,
        uint256 _tileId,
        uint256 _value,
        address _owner,
        string memory _url,
        string memory _element,
        string memory _name
    )
        internal
        returns (uint)
    {
        require(_size == uint256(uint32(_size)));
        require(_tileId == uint256(uint16(_tileId)));
        require(_owner != address(0));

        Land memory _land = Land({
            value: _value,
            owner: _owner,
            element: _element,
            url: _url,
            name: _name,
            creationTime: uint64(now),
            size: uint32(_size),
            tileId: uint16(_tileId)
        });
        uint256 newLandId = lands.push(_land) - 1;

        // It's probably never going to happen, 4 billion pieces of land is A LOT, but
        // let's just be 100% sure we never let this happen.
        require(newLandId == uint256(uint32(newLandId)));

        // emit the Creation event
        emit Creation(
            _owner,
            newLandId,
            uint256(_land.tileId),
            uint256(_land.value),
            uint64(_land.creationTime)
        );

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _transfer(address(0), _owner, newLandId);
        return newLandId;
    }
}
