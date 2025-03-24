# Keyring Morpho Market

To have permissioned Morpho vaults using Keyring Network, while having a minimal footprint, this repository re-use the concept of permissioned token, used by Centrifuge for their RWA tokens.

Advantages of this approach:

- Null footprint on the Metamorpho vault codebase
- Inspiration from audited, deployed and used smart contract, developped by Centrifuge

see [Centrifuge repository](https://github.com/centrifuge/morpho-market/)

## Developing

#### Getting started

```sh
git clone git@github.com:Keyring-Network/integration-integration-morpho-permissioned-token.git
cd integration-morpho-permissioned-token
forge soldeer install
```

#### Testing

```sh
forge test
```
