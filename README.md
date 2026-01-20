# RecipeVault Smart Contract

A decentralized Intellectual Property Registry platform built on the Stacks blockchain for chefs and food companies to register, protect, and manage proprietary recipes and cooking methods.

## Overview

RecipeVault enables culinary professionals to establish immutable proof of ownership for their recipes without revealing the actual recipe content on-chain. By storing cryptographic hashes of recipes, the contract provides IP protection while maintaining recipe confidentiality.

## Features

### Core Functionality

- **Recipe Registration**: Register recipes with cryptographic proof of ownership
- **IP Transfer**: Transfer recipe ownership rights to other parties
- **Version Control**: Update recipe hashes for new versions while maintaining ownership history
- **Access Control**: Deactivate/reactivate recipes as needed
- **Ownership Verification**: Publicly verify recipe ownership claims
- **Transfer History**: Track complete ownership history for each recipe

### Security

- Only recipe owners can transfer, update, or deactivate their recipes
- Immutable registration timestamps using Stacks block height
- Cryptographic hashing ensures recipe confidentiality
- All ownership changes are permanently recorded on-chain

## Smart Contract Functions

### Public Functions

#### `register-recipe`
Register a new recipe to the blockchain.

**Parameters:**
- `recipe-name` (string-ascii 100): Name of the recipe
- `recipe-hash` (buff 32): SHA256 hash of the recipe content
- `category` (string-ascii 50): Recipe category (e.g., "Dessert", "Main Course")

**Returns:** Recipe ID (uint)

**Example:**
```clarity
(contract-call? .recipe-vault register-recipe 
  "Secret Chocolate Cake" 
  0x1234567890abcdef... 
  "Dessert")
```

#### `transfer-recipe`
Transfer recipe ownership to another principal.

**Parameters:**
- `recipe-id` (uint): ID of the recipe to transfer
- `new-owner` (principal): Address of the new owner

**Returns:** Boolean success

**Example:**
```clarity
(contract-call? .recipe-vault transfer-recipe 
  u1 
  'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

#### `deactivate-recipe`
Temporarily deactivate a recipe (prevents updates).

**Parameters:**
- `recipe-id` (uint): ID of the recipe to deactivate

**Returns:** Boolean success

#### `reactivate-recipe`
Reactivate a previously deactivated recipe.

**Parameters:**
- `recipe-id` (uint): ID of the recipe to reactivate

**Returns:** Boolean success

#### `update-recipe-hash`
Update the recipe hash (for versioning or corrections).

**Parameters:**
- `recipe-id` (uint): ID of the recipe to update
- `new-hash` (buff 32): New SHA256 hash of the recipe

**Returns:** Boolean success

### Read-Only Functions

#### `get-recipe`
Retrieve full recipe details by ID.

**Parameters:**
- `recipe-id` (uint): Recipe ID

**Returns:** Recipe object or none

#### `get-owner-recipes`
Get all recipe IDs owned by a principal.

**Parameters:**
- `owner` (principal): Owner's address

**Returns:** List of recipe IDs

#### `get-recipe-count`
Get total number of registered recipes.

**Returns:** Total count (uint)

#### `get-transfer-history`
Get transfer history for a recipe.

**Parameters:**
- `recipe-id` (uint): Recipe ID

**Returns:** Transfer record or none

#### `verify-ownership`
Verify if a principal owns a specific recipe.

**Parameters:**
- `recipe-id` (uint): Recipe ID
- `claimer` (principal): Address to verify

**Returns:** Boolean

## Data Structures

### Recipe Object
```clarity
{
  owner: principal,
  recipe-name: (string-ascii 100),
  recipe-hash: (buff 32),
  category: (string-ascii 50),
  registered-at: uint,
  is-active: bool
}
```

### Transfer Record
```clarity
{
  from: principal,
  to: principal,
  transferred-at: uint
}
```

## Error Codes

- `u100`: Owner-only operation
- `u101`: Recipe not found
- `u102`: Unauthorized access
- `u103`: Recipe already exists
- `u104`: Invalid input parameters

## Usage Guide

### For Chefs and Food Companies

1. **Prepare Your Recipe**
   - Document your recipe off-chain
   - Generate a SHA256 hash of the recipe content
   - Choose an appropriate category

2. **Register the Recipe**
   - Call `register-recipe` with your recipe details
   - Save the returned recipe ID
   - Your recipe is now timestamped and protected on-chain

3. **Manage Your IP**
   - Transfer ownership when selling recipe rights
   - Update hashes when modifying recipes
   - Deactivate recipes when needed

4. **Prove Ownership**
   - Use the recipe hash to prove you own the original
   - Reference the on-chain timestamp for priority claims
   - Share transfer history for provenance

### Best Practices

- **Hash Generation**: Use SHA256 to hash your complete recipe document
- **Off-Chain Storage**: Store actual recipes securely off-chain (encrypted cloud storage, etc.)
- **Documentation**: Keep detailed records linking recipe IDs to your off-chain storage
- **Transfers**: Document transfer agreements off-chain alongside on-chain transfers
- **Categories**: Use consistent category naming for easier discovery

## Deployment

### Prerequisites
- Stacks wallet with STX for transaction fees
- Clarity CLI or Clarinet for testing
- Node.js (optional, for tooling)

### Deploy Steps

1. **Test Locally**
```bash
clarinet test
```

2. **Deploy to Testnet**
```bash
clarinet deploy --testnet
```

3. **Deploy to Mainnet**
```bash
clarinet deploy --mainnet
```

## Integration Examples

### JavaScript/TypeScript (with @stacks/transactions)

```javascript
import { 
  makeContractCall, 
  stringAsciiCV, 
  bufferCV,
  uintCV 
} from '@stacks/transactions';

// Register a recipe
const recipeHash = Buffer.from('your-sha256-hash', 'hex');

const txOptions = {
  contractAddress: 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7',
  contractName: 'recipe-vault',
  functionName: 'register-recipe',
  functionArgs: [
    stringAsciiCV('Secret Chocolate Cake'),
    bufferCV(recipeHash),
    stringAsciiCV('Dessert')
  ],
  // ... other options
};

const transaction = await makeContractCall(txOptions);
```

## Use Cases

- **Professional Chefs**: Protect signature dishes and techniques
- **Food Companies**: Register proprietary formulations and processes
- **Recipe Marketplaces**: Enable verified recipe trading
- **Culinary Schools**: Document original curriculum recipes
- **Food Bloggers**: Establish creation dates for original recipes
- **R&D Departments**: Track development of new food products

## Contributing

Contributions are welcome! Please ensure all tests pass before submitting pull requests.

## Support

For questions or issues, please open an issue on the repository or contact the development team.

## Disclaimer

This smart contract provides a record of registration and ownership claims but does not constitute legal advice. Consult with an intellectual property attorney for formal IP protection strategies.