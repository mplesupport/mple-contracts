const { BN, expectEvent, expectRevert, constants } = require('@openzeppelin/test-helpers');

const Mple = artifacts.require("MPLE")

module.exports = function (deployer) {
  deployer.deploy(Mple);
};
