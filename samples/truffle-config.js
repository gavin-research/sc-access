
const HDWalletProvider = require("@truffle/hdwallet-provider");
var mnemonic =
  "math razor capable expose worth grape metal sunset metal sudden usage scheme";
// const infuraKey = "fj4jll3k.....";
//
// const fs = require('fs');
// const mnemonic = fs.readFileSync(".secret").toString().trim();

module.exports = {
  contracts_directory: "./../contracts/access",
  contracts_build_directory: "./../contracts/access/build/contracts",
  migrations_directory: "./../contracts/access/migrations",

 
  networks: {
    ibc0: {
      host: "127.0.0.1", // Localhost (default: none)
      port: 8645, // Standard Ethereum port (default: none)
      network_id: "*", // Any network (default: none)
      networkCheckTimeout: 10000,
      provider: () =>
        new HDWalletProvider({
          mnemonic: {
            phrase: mnemonic,
          },
          providerOrUrl: "http://localhost:8645",
          addressIndex: 0,
          numberOfAddresses: 10,
          pollingInterval: 8000, // Reducing socket hang up error
        }),
    }
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.9", // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {
        // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: true,
          runs: 1000,
        },
        //  evmVersion: "byzantium"
      },
    },
  }
};

