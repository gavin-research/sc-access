# Access Control using a Blockchain Demo

Here you will find an access control using Blockchain technology. 

# Table of Contents

- [Access Control using a Blockchain Demo](#access-control-using-a-blockchain-demo)
- [Table of Contents](#table-of-contents)
- [About this project](#about-this-project)
- [Preparation](#preparation)
- [Setup and tests](#setup-and-tests)
- [Gas Consumption](#gas-consumption)
- [To end the tests](#to-end-the-tests)


# About this project
This project consists in a Smart Contract that allows for an access control to get information stored in a mapping from an external call. The following use cases are covered and can be tested:

- Give access, among different access types, to an address to consult certain content in a mapping.
- Check what type of access has been given to what addresses over what data in the mapping.
- Recover the content in the mapping if the address sending the transaction has the proper access to do so.

# Preparation
Execute `npm install` in the following order on these directories to install dependencies.

- *contracts/access*
- *samples*

# Setup and tests
Execute `make setup` from *samples*
Once the command finishes you will have deployed the Smart Contract Access in a GETH Blockchain.

You can check the flow of giving access to an entity and then making a transaction as said entity to data in the following way:

Execute `make test-getGivenAccesses` from *samples* to see what addresses have access to "alice" certificates.

Execute `make test-give-access` from *samples*
This will give access to "bob", with address "0x00731540cd6060991D6B9C57CE295998d9bC2faB", to the certificate "Online Course".

Execute again `make test-getGivenAccesses` from *samples* to now see bob's address added to the list.

Execute now `make test-getInfo` to, as bob, ask for the data in the mapping associated to "Online Course" and get it now that you have access to it.


# Gas Consumption

Execute `make test-gas` to get the gas consumption of the Smart Contract Functions for each petition. 
Algorithm 1:
- Contract: ContractA
- Initial: 100000000000000000000
- GasUsed: 126018
- GasPrice: 1000000000
- Final: 99999873982000000000

# To end the tests

Execute `make down` to stop the containers
