const Access = artifacts.require("Access");

contract('Access', function(accounts) {
  it("Test gas", async () => {
    const accounts = await web3.eth.getAccounts();
    const alice = accounts[1];
    const bob = accounts[2];
    const aga = accounts[3];
  
    const certificatecode = "Online Course";
    const entity = bob;
  
    const scAccess = await Access.deployed();
  
    // get user nonce
    const nonce = await scAccess.getNonce(bob);
    const nonceNumber = nonce.toNumber();
  
    console.log(nonceNumber);
  
    const hashedCode = web3.utils.keccak256(nonceNumber.toString());
    console.log({ hashedCode });
  
    const signature = await web3.eth.sign(hashedCode, bob)
    console.log({ signature });
  
    // split signature
    const r = signature.slice(0, 66);
    const s = "0x" + signature.slice(66, 130);
    const v = parseInt(signature.slice(130, 132), 16);
    console.log({ r, s, v });
  
  
    const structFirma = {
      _hashCodeCert: hashedCode,
      _r: r,
      _s: s,
      _v: v
    };
    
    const receipt = await scAccess.getDataWithAccess(certificatecode, structFirma, {
      from: bob,
    });
  
    const gasUsed = receipt.receipt.gasUsed;
    console.log('Gas Used to get the data an Entity has Access to: ', gasUsed);

    // Obtain gasPrice from the transaction
    const tx = await web3.eth.getTransaction(receipt.tx);
    console.log('Gas Price: ', tx.gasPrice);

    // Final balance
    const final = await web3.eth.getBalance(accounts[1]);
    console.log(`Final: ${final.toString()}`);
  });
});