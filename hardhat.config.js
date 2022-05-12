require("@nomiclabs/hardhat-waffle");
require("hardhat-deploy");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
	const accounts = await hre.ethers.getSigners();

	for (const account of accounts) {
		console.log(account.address);
	}
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const RINKEBY_RPC_URL =
	process.env.RINKEBY_RPC_URL ||
	"https://eth-rinkeby.alchemyapi.io/v2/UWqLxnNOFtEpSgCzrfuVUkqQ_NJs4Z0k";

const PRIVATE_KEY = process.env.PRIVATE_KEY || "your private key";

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
	solidity: "0.8.7",
	networks: {
		hardhat: {
			chainId: 31337,
		},
		rinkeby: {
			chainId: 4,
			url: process.env.RINKEBY_RPC_URL,
			accounts: [process.env.PRIVATE_KEY],
		},
	},
	namedAccounts: {
		default: 0,
	},
};
