pragma solidity ^0.4.19;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol';
import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';


contract TokenSecurities is ERC721Token, Ownable, Pausable {
	using SafeMath for uint256;

	string public name;
	string public symbol;
    uint256 public price;
	uint256 public INITITAL_SUPPLY;

    constructor(string _name, string _symbol, uint256 _totalSupply) ERC721Token(_name, _symbol) public {
    	name = _name;
    	symbol = _symbol;
    	INITITAL_SUPPLY = _totalSupply;
    }

    /// @dev The main SecurityInfo struct. Every token in the TokenSecurity Network is represented by a copy
    ///  of this structure, so great care was taken to ensure that it fits neatly into
    ///  exactly two 256-bit words. Note that the order of the members in this structure
    ///  is important because of the byte-packing rules used by Ethereum.
    ///  Ref: http://solidity.readthedocs.io/en/develop/miscellaneous.html
    struct SecurityInfo {
    	string securityName;
    	string securitySymbol;
    	uint256 securityPrice;
    }

    /// @dev An array containing the SecurityInfo struct for all tokens in existence. The ID
    ///  of each token is actually an index into this array
    SecurityInfo[] public securities;

    /// @dev A mapping from token IDs to the address that owns them. All tokens have
    ///  some valid owner address.
    mapping (uint256 => address) public securityIndexToOwner;

    // @dev A mapping from owner address to count of tokens that address owns.
    //  Used internally inside balanceOf() to resolve ownership count.
    mapping (address => uint256) ownershipTokenCount;

    /// @dev A mapping from tokenIDs to an address that has been approved to call
    ///  transferFrom(). Each token can only have one approved address for transfer
    ///  at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public securityIndexToApproved;

    /// @dev Assigns ownership of a specific Tokensecurity to an address.
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        ownershipTokenCount[_to]++;
        securityIndexToOwner[_tokenId] = _to; // transfering ownership of security token
        // When creating new security tokens _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;   
            delete securityIndexToApproved[_tokenId];
        }
        // Emit the transfer event of the security token
        emit Transfer(_from, _to, _tokenId);
    }

    
    ///@dev getSecutiry information and assign variables
    function getSecurity(uint256 _tokenId) public returns (string, string, uint256) {
    	SecurityInfo memory _security = securities[_tokenId];

    	name = _security.securityName;
    	symbol = _security.securitySymbol;
    	price = _security.securityPrice;

        return (name, symbol, price);   
    }

    /// @dev mintNewSecurities only to contract owner
    function mint(string _name, string _symbol, uint256 _price) public onlyOwner {
    	SecurityInfo memory _TokenSecurities = SecurityInfo({ securityName: _name, securitySymbol: _symbol, securityPrice: _price });
    	uint256 _tokenId = securities.push(_TokenSecurities) - 1;

    	_mint(msg.sender, _tokenId);
    }

    /// @dev Checks if a given address is the current owner of a particular token.
    /// @param _claimant the address we are validating against.
    /// @param _tokenId token id, only valid when > 0
    function owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return securityIndexToOwner[_tokenId] == _claimant;
    }

    /// @dev Checks if a given address currently has transferApproval for a particular token.
    /// @param _claimant the address we are confirming token is approved for.
    /// @param _tokenId token id, only valid when > 0
    function approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return securityIndexToApproved[_tokenId] == _claimant;
    }

    /// @dev Marks an address as being approved for transferFrom(), overwriting any previous
    ///  approval. 
    function approve(uint256 _tokenId, address _approved) internal {
        securityIndexToApproved[_tokenId] = _approved;
    }

   	/// @dev Gets the balance of the specified address
   	/// @param _owner address to query the balance of
    /// @return uint256 representing the amount owned by the passed address
  	function balanceOf(address _owner) public view returns (uint256) {
    	require(_owner != address(0));
    	return ownedTokensCount[_owner];
  	}

    /// @notice Transfers a Token to another address. If transferring to a smart
    /// contract be VERY CAREFUL to ensure that it is aware of ERC-721 
    /// or your Token may be lost forever.
    /// @param _to The address of the recipient, can be a user or contract.
    /// @param _tokenId The ID of the Token to transfer.
    /// @dev Required for ERC-721 compliance.
    function transfer(address _to, uint256 _tokenId) external whenNotPaused {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any tokens (except very briefly
        // after a gen0 cat is created and before it goes on auction).
        require(_to != address(this));

        // You can only send your own token.
        require(owns(msg.sender, _tokenId));

        // Reassign ownership, clear pending approvals, emit Transfer event.
        _transfer(msg.sender, _to, _tokenId);
    }
}