pragma solidity ^0.4.19;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/token/ERC721/ERC721BasicToken.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';


contract TokenSecurities is ERC721BasicToken, Ownable {
    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint256 public price;
    uint256 public INITITAL_SUPPLY;

    constructor(string _name, string _symbol, uint256 _totalSupply) ERC721BasicToken public {
        name = _name;
        symbol = _symbol;
        INITITAL_SUPPLY = _totalSupply;
    }

    /// @dev The main TokenInfo struct. Every token in the TokenSecurity Network is represented by a copy
    ///  of this structure, so great care was taken to ensure that it fits neatly into
    ///  exactly two 256-bit words. Note that the order of the members in this structure
    ///  is important because of the byte-packing rules used by Ethereum.
    ///  Ref: http://solidity.readthedocs.io/en/develop/miscellaneous.html
    struct TokenInfo {
        string tokenName;
        string tokenSymbol;
        uint256 tokenPrice;
    }

    /// @dev An array containing the TokenInfo struct for all tokens in existence. The ID
    ///  of each token is actually an index into this array
    TokenInfo[] public tokens;


    /// @dev mint only to contract owner
    function mint(string _name, string _symbol, uint256 _price) public onlyOwner {
        TokenInfo memory _TokenSecurities = TokenInfo({ tokenName: _name, tokenSymbol: _symbol, tokenPrice: _price });
        uint256 _tokenId = tokens.push(_TokenSecurities) - 1;

        _mint(msg.sender, _tokenId);
    }

    ///@dev getSecutiry information and assign variables
    function getSecurity(uint256 _tokenId) public view returns (string, string, uint256) {
        TokenInfo memory _token = tokens[_tokenId];

        name = _token.tokenName;
        symbol = _token.tokenSymbol;
        price = _token.tokenPrice;

        return (name, symbol, price);   
    }

    /// @dev Gets the balance of the specified address
    /// @param _owner address to query the balance of
    /// @return uint256 representing the amount owned by the passed address
    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != address(0));
        return ownedTokensCount[_owner];
    }


    function getTokenBalance(address _owner) public view returns (uint256) {
        require(owner != address(0));
        return ownedTokensCount[_owner];
    }

    function transferToNewOwner(address _from, address _to, uint256 _tokenId) public payable {
        require(msg.value >= 1);
        safeTransferFrom(_from, _to, _tokenId);
    }

}