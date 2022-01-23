
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
        this.proxy = await Proxy.new()
       
    })

    it("should deploy the contracts correctly", async () => {
        console.log(`address of admin in proxy: ${await this.proxy.admin()}`)
        console.log(`address of proxy: ${this.proxy.address}`)
        console.log(`address of box: ${this.box.address}`)
        console.log(`address of boxV2: ${this.boxV2.address}`)
    })

    it("should set proxy impl and call the function", async () => {
        await this.proxy.setImplementation(this.box.address)
        const boxProxy = await Box.at(this.proxy.address)
        console.log(`get init ${await boxProxy.getInit()}`)
        // await boxProxy.initialize() // 42
        console.log(`getmagicnumber in box(after init): ${await this.box.getMagicNumber()}`) // print 42
        await boxProxy.setMagicNumber(45) // 45
        
        console.log(`getmagicnumber in box: ${await this.box.getMagicNumber()}`) // print 0
        console.log(`getmagicnumber: ${await boxProxy.getMagicNumber()}`) // print 45
    })

    it("should change proxy impl", async () => {
        await this.proxy.setImplementation(this.boxV2.address, {from:admin}) // change impl
        const boxProxy = await BoxV2.at(this.proxy.address) // use BoxV2 abi
        
        await boxProxy.double() // now we can call that function
        
        console.log(`getmagicnumber: ${await boxProxy.getMagicNumber()}`) // print 90
    })

})

/*

this pattern is transparent proxy pattern

UUPS pattern is different than this
it requires setting the address on the contract side i guess, need to look more into it

*/