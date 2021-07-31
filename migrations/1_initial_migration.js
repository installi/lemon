const Authority = artifacts.require("Authority");

const Lemon = artifacts.require("Lemon");
const Fuse = artifacts.require("Fuse");
const Babylon = artifacts.require("Babylon");

module.exports = async function (deployer, network, accounts) {
  deployer.deploy(Authority);
};
