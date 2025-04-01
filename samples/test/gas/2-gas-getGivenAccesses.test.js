const Access = artifacts.require("Access");

contract('Access', function(accounts) {
  it("Test gas", async () => {
    const scAccess = await Access.deployed();

    const accounts = await web3.eth.getAccounts();
    const alice = accounts[1];
    const bob = accounts[2];
    const aga = accounts[3];
    
    // get user nonce
    const nonce = await scAccess.getNonce(alice);
    const nonceNumber = nonce.toNumber();
  
  
    const hashedCode = web3.utils.keccak256(nonceNumber.toString());
  
    const signature = await web3.eth.sign(hashedCode, alice)
  
    // split signature
    const r = signature.slice(0, 66);
    const s = "0x" + signature.slice(66, 130);
    const v = parseInt(signature.slice(130, 132), 16);
    
    const structFirma = {
      _hashCodeCert: hashedCode,
      _r: r,
      _s: s,
      _v: v
    };
  
    const accessValue = 1;
  
    const receipt1 = await scAccess.getAccessList(alice, {
      from: alice,
    })
  
    //Create list of entities with access
    const receipt = await scAccess.getEntidades(alice, structFirma, {
      from: alice,
    });
  
    const gasUsed1 = receipt1.receipt.gasUsed;
    const gasUsed = receipt.receipt.gasUsed;
    console.log('Gas Used to get the Given Accesses to which Entities and Certificates: ', gasUsed1 + gasUsed);

    // Obtain gasPrice from the transactions
    const tx1 = await web3.eth.getTransaction(receipt1.tx);
    const tx = await web3.eth.getTransaction(receipt.tx);
    console.log('Gas Price: ', tx1.gasPrice + tx.gasPrice);

    // Final balance
    const final = await web3.eth.getBalance(accounts[1]);
    console.log(`Final: ${final.toString()}`);
  });
});