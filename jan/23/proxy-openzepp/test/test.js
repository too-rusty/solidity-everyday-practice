
const { ether, expectEvent, expectRevert, BN } = require("@openzeppelin/test-helpers");
const { expect } = require("chai");

const Proxy = artifacts.require("Proxy")
const Box = artifacts.require("Box")
const BoxV2 = artifacts.require("BoxV2")

contract("ProxyContracts", async (accounts) => {
    let admin, user;
    before(async () => {
        [admin, user] = accounts
        this.box = await Box.new()
        this.boxV2 = await BoxV2.new()
        this.proxy = await Proxy.new({from:admin})
    })

    it("should deploy the contracts correctly", async () => {
        expect(await this.proxy.getAdmin()).to.be.equal(admin)
    })

    it("should set proxy impl and call the function", async () => {
        await this.proxy.setImplementation(this.box.address, {from:admin})
        const boxProxy = await Box.at(this.proxy.address)

        expect(await this.proxy.getImplementation()).to.be.equal(this.box.address);
        
        await boxProxy.initialize() // 42
        console.log(`getmagicnumber in box(after init): ${await this.box.getx()}`) // print 42
        await boxProxy.setx(45, {from: user}) // 45
        
        console.log(`getx in box: ${await this.box.getx({from: user})}`) // print 0
        console.log(`getx: ${await boxProxy.getx({from: user})}`) // print 45
    })

    it("should not allow non admin to set address or admin", async () => {
        // expectRevert(await this.proxy.setImplementation("", {from:user}), "proxy: only admin")
    })

    // it("should change proxy impl", async () => {
    //     await this.proxy.setImplementation(this.boxV2.address, {from:admin}) // change impl
    //     const boxProxy = await BoxV2.at(this.proxy.address) // use BoxV2 abi
        
    //     await boxProxy.double() // now we can call that function
        
    //     console.log(`getmagicnumber: ${await boxProxy.getMagicNumber()}`) // print 90
    // })

})

/*

1. why shouldnt admin call the impl contract

2. selector clash ?

3. still not the best design, refer to openzeppelin later

*/