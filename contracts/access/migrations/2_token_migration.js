
const SCContract = artifacts.require("Access");


const deployApp = async (deployer) => {
  await deployer.deploy(SCContract);
};



module.exports = async function(deployer, network) {
  await deployApp(deployer);
};


