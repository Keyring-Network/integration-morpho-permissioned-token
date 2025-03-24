# Keyring Morpho Market

This repository implements permissioned Morpho vaults using Keyring Network, with a minimal footprint. It reuses the concept of permissioned tokens, similar to those used by Centrifuge for their RWA tokens.

## Key benefits of this approach

- Zero modifications required to the Metamorpho vault codebase
- Based on audited, deployed, and production-tested smart contracts developed by Centrifuge
- Simple and efficient implementation

## Concerns of this approach

- Need to deal with a wrapping token, adding UX blockers

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
