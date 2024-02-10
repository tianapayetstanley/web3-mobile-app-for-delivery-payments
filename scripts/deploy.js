// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const company = "0x2C17bF990f33afcFdE985E19137A92B1C486D0e1";
  const device = "0x7943984e2BA9Fe097286aED8D6c31f94FeC0800F";
  const driver = "0x8a40840554c7972fF50208FA442B80f0b14Fc378";

  const paymentAmount = hre.ethers.parseEther("0.005");

  const contract = await hre.ethers.deployContract(
    "GeoLogix",
    [device, company, driver],
    {
      value: paymentAmount,
    }
  );

  await contract.waitForDeployment();

  console.log(
    `Contract with ${ethers.formatEther(paymentAmount)}ETH is deployed to ${
      contract.target
    }`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
