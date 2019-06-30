import assertRevert from "zeppelin-solidity/test/helpers/assertRevert";

var TokenSecurities = artifacts.require('./TokenSecurities.sol');

const name = "TestNetwork";
const symbol = "TST";
const totalSupply = 100000000;


contract("TokenSecurities", (accounts) => {
	var token;
	const [firstAccount, secondAccount] = accounts;
	it("Set up contract for each test case", async () => {
		token = await TokenSecurities.new(name, symbol, totalSupply, {from: firstAccount});
	});

	it("should start with no tokens", async () => {
		assert.equal((await token.balanceOf(firstAccount)), 0)
	});

	it("new tokens should be created", async () => {
		await token.mint("My new token", "TKN", 100000)
		assert.equal((await token.balanceOf(firstAccount)).toNumber(), 1)
	});

	it("should set the owner to the creator contract", async () => {
		const owner = await token.owner();
		assert.equal(owner, firstAccount);
	});

	it("should mint new tokens", async () => {
		let tokenSecurity = await token.mint("My new token", "TKN", 10);
		assert.ok(tokenSecurity)
	});

	it("shoud return balance of address", async () => {
		let ownerBalance = await token.balanceOf(firstAccount)
		assert.equal(ownerBalance.c[0], 2);
	});

	it("should transfer ownership of contract and allow new owner to mint", async () => {
		await token.transferOwnership(secondAccount);
		await assertRevert(token.mint("My new token", "TKN", 10));
	});

	it("owner of contract should be address contract transfered to.", async () => {
		assert.equal(await token.owner(), secondAccount);
	});

	it("should get security", async () => {
		await token.getSecurity(0);
		await assertRevert(token.mint("My new token", "TKN", 10));
	});

});

contract("Transfer Ownership of Token", (accounts) => {
	const [firstAccount, secondAccount, thirdAccount] = accounts;

	it("Should transfer ownership of a token", async () => {
		let contract = await TokenSecurities.new(name, symbol, totalSupply, {from: firstAccount});
		let token = await contract.mint("My new token", "TKN", 10);
		let tokenIndex = token.receipt.transactionIndex;
		await contract.safeTransferFrom(firstAccount, secondAccount, tokenIndex);
		assert.equal(await contract.ownerOf(tokenIndex), secondAccount);
	});
});
