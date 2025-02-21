# PointStack

A decentralized community rewards distribution system built on the Stacks blockchain that enables fair and transparent point allocation to community contributors.

## Overview

PointStack is a smart contract system that manages the distribution of community points to eligible contributors. It provides a comprehensive framework for administering rewards, tracking distributions, and managing point expiration.

## Features

- **Fungible Token System**: Community points implemented as fungible tokens on the Stacks blockchain
- **Eligibility Management**: Flexible system for adding and removing eligible contributors
- **Automated Claims**: Self-service point claiming for eligible contributors
- **Point Expiration**: Automatic expiration mechanism for unclaimed points
- **Event Logging**: Comprehensive event tracking system
- **Administrative Controls**: Secure admin functions for system management


## Smart Contract Functions

### Administrative Functions

- `add-eligible-contributor`: Add a single contributor to the eligibility list
- `remove-eligible-contributor`: Remove a contributor from the eligibility list
- `bulk-add-eligible-contributors`: Add multiple contributors in one transaction
- `update-points-reward`: Modify the points awarded per contribution
- `update-expiry-period`: Update the expiration period for unclaimed points


### User Functions

- `claim-reward-points`: Allow eligible contributors to claim their points
- `expire-unclaimed-points`: Process expiration of unclaimed points after the expiry period


### Read-Only Functions

- `get-rewards-active-status`: Check if the rewards system is active
- `is-contributor-eligible`: Verify if an address is eligible for rewards
- `has-contributor-claimed-points`: Check if a contributor has claimed their points
- `get-contributor-claimed-amount`: Get the amount of points claimed by a contributor
- `get-total-points-distributed`: View total points distributed
- `get-points-per-contribution`: Check current points reward amount
- `get-expiry-period`: View the current expiry period
- `get-rewards-start-block`: Get the block height when rewards started
- `get-event`: Retrieve specific event details


## Error Codes

```plaintext
u100 - Not contract owner
u101 - Reward already claimed
u102 - Contributor not eligible
u103 - Insufficient points balance
u104 - Rewards not active
u105 - Invalid points amount
u106 - Expiry period not ended
u107 - Invalid contributor
u108 - Invalid duration
```

## Technical Details

- **Token Supply**: Initial mint of 1,000,000,000 community points
- **Points per Contribution**: 100 points (configurable)
- **Expiry Period**: 10,000 blocks (configurable)
- **Event Logging**: Supports up to 20 ASCII characters for event type and 256 for data


## Security Features

- Owner-only administrative functions
- Double-claim prevention
- Balance checks before transfers
- Eligibility verification
- Expiration controls


## Getting Started

To deploy and interact with PointStack:

1. Deploy the contract to the Stacks blockchain
2. Initialize the contract with eligible contributors
3. Configure points per contribution and expiry period as needed
4. Monitor events through the logging system


## Best Practices

- Regularly review and update eligible contributors
- Monitor unclaimed points and expiration periods
- Keep track of distributed points through events
- Maintain adequate point balance in the contract


## Contributing

Contributions are welcome! Please submit issues and pull requests to the repository.
