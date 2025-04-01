require("web3")
const SCAccess = artifacts.require("Access");

module.exports = async (callback) => {
  const accounts = await web3.eth.getAccounts();
  const alice = accounts[1];
  const bob = accounts[2];
  const aga = accounts[3];

  const certificatecode = "Online Course";
  const entity = bob;

  const scAccess = await SCAccess.deployed();

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

  const accessValue = 1;

  await scAccess.getDataWithAccess(certificatecode, structFirma, {
    from: bob,
  });

  const accessInfo = await scAccess.getPastEvents("DataWithAccess", {
    fromBlock: 0,
  });
  
  console.log(accessInfo);


  callback();
};
