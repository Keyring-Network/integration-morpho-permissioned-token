# Keyring Morpho Market

[![CI](https://github.com/Keyring-Network/integration-integration-morpho-permissioned-token/actions/workflows/foundry.yml/badge.svg)](https://github.com/Keyring-Network/integration-integration-morpho-permissioned-token/actions/workflows/foundry.yml)

This repository implements permissioned Morpho vaults using Keyring Network, with a minimal footprint. It reuses the concept of permissioned tokens, similar to those used by Centrifuge for their RWA tokens.

## Key Benefits

- Zero modifications required to the Metamorpho vault codebase
- Based on audited, deployed, and production-tested smart contracts developed by Centrifuge
- Simple and efficient implementation

For reference, see the [Centrifuge repository](https://github.com/centrifuge/morpho-market/).

## Development

### Getting Started

```sh
git clone git@github.com:Keyring-Network/integration-integration-morpho-permissioned-token.git
cd integration-morpho-permissioned-token
forge soldeer install
```

### Testing

Run the test suite:

```sh
forge test
```

### Code Coverage

Generate a coverage report:

```sh
forge coverage
```
