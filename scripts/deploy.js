const deploy = async () => {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contract with the account:", deployer.address);

    const AwkwardSkeletonClub = await ethers.getContractFactory("AwkwardSkeletonClub");
    const deployed = await AwkwardSkeletonClub.deploy();

    console.log("Awkward Skeleton Club is deployed at:", deployed.address);

};

deploy()
.then(() => process.exit(0))
.catch(error =>{
    console.log(error);
    process.exit(1);
});