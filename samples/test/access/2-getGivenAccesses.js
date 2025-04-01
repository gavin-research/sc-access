require("web3")
const SCAccess = artifacts.require("Access");
module.exports = async (callback) => {
  const accounts = await web3.eth.getAccounts();
  const alice = accounts[1];
  const bob = accounts[2];
  const aga = accounts[3];

  const scAccess = await SCAccess.deployed();

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

  await scAccess.getAccessList(alice, {
    from: alice,
  })

  //create list of entities with access first
  const entidades = await scAccess.getEntidades(alice, structFirma, {
    from: alice,
  });

  const givenAccesses = await scAccess.getPastEvents("CertEntites", {
    fromBlock: 0,
  });
  
const lastEvent = givenAccesses.length-1;

for(i = 0; i<givenAccesses[lastEvent].returnValues.certsAddress.length; i++){
  console.log("-----------------------------------------------");
  console.log("Certificado: ", givenAccesses[lastEvent].returnValues.certsAddress[i]);

  for(j = 0; j < 4; j++){
    // certificado, access type - 0, 1, 2 or 3, entity
    var entidad = givenAccesses[lastEvent].returnValues.accessList[i][j];
    var tipoaccesso = '';
    switch(j){
      case 0:
        tipoaccesso = "Total";
        break;
      case 1:
        tipoaccesso = "Partial";
        break;
      case 2:
        tipoaccesso = "Via Third Party";
        break;
      case 3:
        tipoaccesso = "Denied";
        break;
    }
    console.log("Access Type: ",tipoaccesso,"  - Entities: ", entidad);
  }

}

  console.log("Access List:");


  callback();
};
