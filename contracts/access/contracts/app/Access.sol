// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.9;

import "solidity-bytes-utils/contracts/BytesLib.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Access {
    using BytesLib for *;

    address private owner;

    enum Acceso{
        no_registro, // default
        acceso_total, // total access to information
        acceso_parcial, // partial access to information
        acceso_usuario_y_terceros_total, // access to information via a third party
        acceso_denegado // access given previously but now removed
    }

    Acceso constant defaultaccess = Acceso.no_registro;

    address[][] public entidades1cert;
    address[][][] public entidades;

    mapping(address => string) private valid_issuers; 

    mapping(string => address) private holders; 

    mapping(address => string[]) public holdersEspejo;

    //mapping name of course - entity with access - access type
    mapping (string => mapping(address => Acceso)) public access;

    //mapping user - nonce for signature requests
    mapping(address => uint256) private nonce_sign; 

//mappings needed to get the information of type of access of each entity and to each certificate
    mapping(address => mapping(address => Acceso)) public accesslist;
    mapping(address => mapping(string => mapping(Acceso => address[]))) public accesslista;
    mapping(address => address[][][]) public userEntidades;

//mapping of data - "private" data to consult given access rights on data
    mapping(string => string) private information;

    struct FirmaValidacion {
        bytes32 _hashCodeCert;
        bytes32 _r;
        bytes32 _s;
        uint8 _v;
    }

    constructor() public {
        owner = msg.sender;
        
        //alice (account 0xcBED645B1C1a6254f1149Df51d3591c6B3803007) certificates:

        holders["Online Course"]=
        0xcBED645B1C1a6254f1149Df51d3591c6B3803007;
        
        holders["Driver License"]=
        0xcBED645B1C1a6254f1149Df51d3591c6B3803007;

        //bob (account 0x00731540cd6060991D6B9C57CE295998d9bC2faB) certificates:

        holders["AGA University"]=
        0x00731540cd6060991D6B9C57CE295998d9bC2faB;


        holdersEspejo[0xcBED645B1C1a6254f1149Df51d3591c6B3803007]=
        ["Online Course",
        "Driver License"];

        holdersEspejo[0x00731540cd6060991D6B9C57CE295998d9bC2faB]=
        ["AGA University"];
 
    //////////////////////////////////////////////////////////////////////////////////////////////

        //alice can access to her own certificates data
        access["Online Course"]
            [0xcBED645B1C1a6254f1149Df51d3591c6B3803007] =  Acceso.acceso_total;

        access["Driving License"]
            [0xcBED645B1C1a6254f1149Df51d3591c6B3803007] = Acceso.acceso_total;

        ////

        //bob can access to his own certificates data
        access["AGA University"]
            [0x00731540cd6060991D6B9C57CE295998d9bC2faB] =  Acceso.acceso_total;

        //holder, certificate, access type, verifiers
        //alice
        accesslista[0xcBED645B1C1a6254f1149Df51d3591c6B3803007]
            ["Online Course"]
            [Acceso.acceso_total] = 
            [0xcBED645B1C1a6254f1149Df51d3591c6B3803007, 0xa89F47C6b463f74d87572b058427dA0A13ec5425];
        accesslista[0xcBED645B1C1a6254f1149Df51d3591c6B3803007]
            ["Online Course"]
            [Acceso.acceso_parcial] =
            [0x95222290DD7278Aa3Ddd389Cc1E1d165CC4BAfe5, 0x478D97356251BF1F1e744587E67207dAb100CaDb];
        accesslista[0xcBED645B1C1a6254f1149Df51d3591c6B3803007]
            ["Driver License"]
            [Acceso.acceso_total] = 
            [0xcBED645B1C1a6254f1149Df51d3591c6B3803007, 0x4838B106FCe9647Bdf1E7877BF73cE8B0BAD5f97];

        //bob
        accesslista[0x00731540cd6060991D6B9C57CE295998d9bC2faB]
            ["AGA University"]
            [Acceso.acceso_total] = 
            [0x00731540cd6060991D6B9C57CE295998d9bC2faB, 0x333343333CE9647Bdf1e7877bf73ce8b0Bad5F97];
        
        //"private" information that can only be requested with proper access type
        information["Online Course"] = "Solidity YUL programmer";
        information["Driver License"] = "Truck";
        information["AGA University"] = "Blockchain Master";

    }

    event ModifyAccess(address indexed entity, string certificate, Acceso access);

    event NonceSign(uint256 nonce);

    event AddedValidIssuer(address issuerAddy, string issuerName);

    event DataWithAccess( 
        address indexed from,
        string message,
        string info
    );

    event CertEntites(
        address from,
        string[] certsAddress,
        address[][][] accessList
    );
    
    modifier onlyOwner() {
        require(msg.sender == owner, "MiniMessage: caller is not the owner");
        _;
    }

    function getIssuer(address issuer) public view returns(string memory){
        return valid_issuers[issuer];
    }

    function getNonce(address user) public view returns (uint256){
        return nonce_sign[user];
    }

    function getHolderofCert(string memory cert) public view returns(address){
        return holders[cert];
    }

    function getHoldersEspejo(address holder) public view returns(string[] memory){
        return holdersEspejo[holder];
    }

    function getAccessList(address holder) public{
        string[] storage certificates = holdersEspejo[holder];
        
        delete entidades;
        delete entidades1cert;

        Acceso[4] memory tipo_de_acceso = [Acceso.acceso_total, Acceso.acceso_parcial, 
                Acceso.acceso_usuario_y_terceros_total, Acceso.acceso_denegado];

        for(uint256 i = 0; i < certificates.length; i++){
            for(uint j = 0; j < 4; j++){
                Acceso acceso = tipo_de_acceso[j];
                address[] memory entidad = accesslista[holder][certificates[i]][acceso];
                entidades1cert.push(entidad);
            }
            entidades.push(entidades1cert);
            delete entidades1cert;
        }
        userEntidades[holder] = entidades;
        
    }

    function getEntidades(address holder, FirmaValidacion calldata firma) public returns (address[][][] memory) {
        address signer = _getSigner(firma);
        require(firma._hashCodeCert == keccak256(abi.encodePacked(Strings.toString(nonce_sign[signer]))), "Invalid signer");
        require(holder == signer, "Invalid signer. Msg signer is not the user requested.");

        emit CertEntites(holder, holdersEspejo[holder], userEntidades[holder]);
        return userEntidades[holder];
    }


     function modifyAccess(
        address entity,
        string memory certificate,
        FirmaValidacion calldata firma,
        Acceso accessvalue
    ) external {
        address signer = _getSigner(firma);
        require(firma._hashCodeCert == keccak256(abi.encodePacked(Strings.toString(nonce_sign[signer]))), "Invalid signer");
        require(holders[certificate] == signer, "Invalid signer 2");
        require(holders[certificate] != entity, "Holders cannot remove their own access to a certification");

        nonce_sign[signer] = nonce_sign[signer] + 1;
        access[certificate][entity] = accessvalue;

        Acceso[4] memory tipo_de_acceso = [Acceso.acceso_total, Acceso.acceso_parcial, 
                Acceso.acceso_usuario_y_terceros_total, Acceso.acceso_denegado];
        for(uint j = 0; j < 4; j++){
                Acceso acceso = tipo_de_acceso[j];
                address[] storage entidad = accesslista[signer][certificate][acceso];
                
                for(uint i=0; i < entidad.length; i++){
                    if(entidad[i] == entity){
                        for (uint k = i; k < entidad.length - 1; k++) {
                            entidad[k] = entidad[k + 1];
                        }
                        entidad.pop();
                    } 
                }
            }
        accesslista[signer][certificate][accessvalue].push(entity);

        emit ModifyAccess(
            entity,
            certificate,
            accessvalue);
    }

     function _getSigner(FirmaValidacion memory firma) internal pure returns (address) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, firma._hashCodeCert));
        address signer = ecrecover(prefixedHashMessage, firma._v, firma._r, firma._s);
        
        return signer;
    }

    function getDataWithAccess(
        string memory message,
        FirmaValidacion calldata firma
    ) external {
        address signer = _getSigner(firma);
        require(firma._hashCodeCert == keccak256(abi.encodePacked(Strings.toString(nonce_sign[signer]))), "Invalid signer");
        
        nonce_sign[signer] = nonce_sign[signer] + 1;
        string memory info;

        if((access[message][signer] == Acceso.acceso_total) || 
            (access[message][signer] == Acceso.acceso_parcial) || 
            (access[message][signer] == Acceso.acceso_usuario_y_terceros_total) ||
            (holders[message] == signer)){

            info = information[message];
            
            //shows event with "private" info if caller has access
            emit DataWithAccess(
                signer,
                message,
                info
            );

        }else{
            // shows event with "NO ACCESS TO CERTIFICATION" if caller doesn't have access to the data
            info = "NO ACCESS TO CERTIFICATION";
            emit DataWithAccess(
                signer,
                message,
                info
            );
        }
    }
}