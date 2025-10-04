## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Adicional

forge install transmissions11/solmate

## FORGE CREATE - ANTIGUO
forge create --rpc-url https://eth-sepolia.g.alchemy.com/v2/xxxxxx \ 
   --constructor-args "MyToken" "MT" 18 1000000000000000000000  \ 
   --private-key 0xxxxxxx  \ 
   --etherscan-api-key xxxx  \ 
   --verify
   src/MyToken.sol:MyToken

## Actualizado

forge create src/MyToken.sol:MyToken   
--rpc-url https://eth-sepolia.g.alchemy.com/v2/NhtK-EalUVBo1hkOh8G_kQljT3VOQEU8   
--private-key 0x86025bec599bee8a7302c836abb73aadbedd2df0d7f771b7f850efd65294ea03   
--constructor-args "MyToken" "MT" 18 1000000000000000000000   
--etherscan-api-key NHXUVKYPHEITT9IX2AUPMKTKN4SJFMBUAU   
--verify


## CORRECTO CON SCRIPT

forge script script/Deploy.s.sol:DeployScript \
  --rpc-url https://eth-sepolia.g.alchemy.com/v2/NhtK-EalUVBo1hkOh8G_kQljT3VOQEU8 \
  --private-key 0x86025bec599bee8a7302c836abb73aadbedd2df0d7f771b7f850efd65294ea03 \
  --broadcast \
  --verify \
  --etherscan-api-key NHXUVKYPHEITT9IX2AUPMKTKN4SJFMBUAU


## VERIFY
forge verify-contract 0xTU_DIRECCION_DEL_CONTRATO \
  src/MyToken.sol:MyToken \
  --chain sepolia \
  --etherscan-api-key NHXUVKYPHEITT9IX2AUPMKTKN4SJFMBUAU \
  --constructor-args $(cast abi-encode "constructor(string,string,uint8,uint256)" "MyToken" "MT" 18 1000000000000000000000)

## SCRIPT + ENV
source .env

forge script script/MyToken.s.sol:DeployScript \
  --rpc-url sepolia \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify

## CAST
cast call 0x6b175474e89094c44da98b954eedeac495271d0f \
  "totalSupply()(uint256)" \
  --rpc-url https://eth-mainnet.g.alchemy.com/v2/NhtK-EalUVBo1hkOh8G_kQljT3VOQEU8

##  EXPORT 
export ETH_RPC_URL="https://eth-mainnet.g.alchemy.com/v2/NhtK-EalUVBo1hkOh8G_kQljT3VOQEU8"

cast chain-id
cast client
cast gas-price
cast block-number
cast basefee
cast block 12345678
cast age

## CONTRACT VAULT
forge build

source .env

forge script script/DeployVault.s.sol:DeployVaultScript \
  --rpc-url sepolia \
  --broadcast \
  --verify

cast send <CONTRACT_ADDRESS> \
  "deposit(uint256)" 10 \
  --private-key $PRIVATE_KEY \
  --rpc-url sepolia

 cast send 0x8199Bd12B63D700a7fD27531d0FfbA2CCcc5d89a   "dummy()" 1   --private-key $PRIVATE_KEY   --rpc-url sepolia

 cast send 0x8199Bd12B63D700a7fD27531d0FfbA2CCcc5d89a   "deposit(uint256)" 1gwei   --private-key $PRIVATE_KEY   --rpc-url sepolia

 cast etherscan-source <contract_address>


cast interface 0x8199Bd12B63D700a7fD27531d0FfbA2CCcc5d89a --chain sepolia

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

anvil -h

anvil -a 20

anvil --hardfork istanbul


### CHISEL
```shell
$ chisel
```
●Obtener saldo de direcciones:
address(0).balance

● Codifique varios parámetros:
abi.encode(256, bytes32(0), "Chisel!")

● Llame a una función de vista:
myViewFunc(128)

● Ejemplo de operaciones bit a bit:
1 << 8  // output result is 256, type uint256

------------------------------------------------------------

● Define veriables:
uint256 a = 0xa57b;

● Llamar a funciones de cambio de estado o a varias funciones:
myStateMutatingFunc(128) || myViewFunc(128);

● Definir funciones internas:

function hash64(bytes32 _a, bytes32 _b) internal pure returns (bytes32 _hash) {
  assembly {
    // Store the 64 bytes we want to hash in scratch space
    mstore(0x00, _a)
    mstore(0x20, _b)

    // Hash the memory in scratch space
    // and assign the result to `_hash`
    _hash := keccak256(0x00, 0x40)
  }
}

● Definir eventos y estructuras
event ItHappened(bytes32 indexed hash);
struct Complex256 { uint256 re; uint256 im; }


### TEST

# Ejecutar todos los tests
forge test

# Ejecutar con más detalle
forge test -vvv

# Solo tests de deposit
forge test --match-test test_Deposit

# Solo tests que deben revertir
forge test --match-test testFail

# Ver gas report
forge test --gas-report

# Ejecutar un test específico con máximo detalle
forge test --match-test test_Deposit -vvvv

# Ejecutar todos los tests del contrato VaultTest
forge test --match-contract VaultTest


### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
