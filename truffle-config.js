require("dotenv").config();
let HDWalletProvider = require("truffle-hdwallet-provider");

module.exports = {
  networks: {
    local: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*",
    },
    ropsten: {
      provider: () =>
        new HDWalletProvider(
          process.env.NEVERLAND_DEPLOYER_KEY,
          "https://ropsten.infura.io/v3/" + process.env.INFURA_PROJECT_ID
        ),
      network_id: '3',
      gasPrice: 15000000000,
    },
    kovan: {
      provider: () =>
        new HDWalletProvider(
          process.env.NEVERLAND_DEPLOYER_KEY,
          "https://kovan.infura.io/v3/"  + process.env.INFURA_PROJECT_ID
        ),
      network_id: '*',
      gasPrice: 2000000000,
    },
  },
  compilers: {
    solc: {
      version: "0.5.16",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200,
        },
      },
    },
  },
};
