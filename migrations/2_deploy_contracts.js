var TokenSecurities = artifacts.require("./TokenSecurities.sol");

module.exports = function(deployer) {
	name = 'TestToken';
	symbol = 'Test';
	totalSupply = 100000;
  deployer.deploy(TokenSecurities, name, symbol, totalSupply);
};
