#  Biodiversity Preservation Fund Smart Contract

A decentralized funding platform for biodiversity conservation projects built on the Stacks blockchain using Clarity smart contract language.

##  Overview

The Biodiversity Preservation Fund enables transparent, community-governed funding for conservation projects worldwide. Organizations can propose projects, the community votes on their legitimacy, and supporters can contribute STX tokens to fund approved initiatives.

##  Key Features

###  **Democratic Governance**
- Community voting on proposed projects
- 66% approval threshold required for project activation
- 7-day voting periods for thorough consideration
- Prevents spam and ensures quality projects

###  **Secure Funding**
- Minimum 1 STX contribution requirement
- Automatic fund management and tracking
- Funds released only when targets are met
- Complete transparency of all contributions

###  **Role-Based Access**
- **Project Creators**: Propose and manage conservation projects
- **Contributors**: Fund approved projects and vote
- **Validators**: Authorized oversight for project legitimacy
- **Contract Owner**: Governance and validator management

###  **Comprehensive Tracking**
- Real-time funding progress
- Contributor statistics and history
- Project lifecycle management
- Funding percentage calculations

##  Getting Started

### Prerequisites
- Stacks wallet (Hiro Wallet recommended)
- STX tokens for contributions
- Understanding of Clarity smart contracts

### Deployment

1. **Deploy the Contract**
   ```bash
   clarinet deploy --testnet
   ```

2. **Initialize the Contract**
   ```clarity
   (contract-call? .biodiversity-fund initialize)
   ```

##  Usage Guide

### Creating a Project

Project creators can propose new biodiversity conservation initiatives:

```clarity
(contract-call? .biodiversity-fund create-project 
  "Amazon Rainforest Protection"
  "Protecting 1000 acres of Amazon rainforest from deforestation through land acquisition and community partnerships."
  u50000000  ;; 50 STX target
  u30)       ;; 30 days duration
```

**Parameters:**
- `title`: Project name (max 100 characters)
- `description`: Detailed project description (max 500 characters)
- `target-amount`: Funding goal in microSTX (1 STX = 1,000,000 microSTX)
- `duration-days`: Project duration in days

### Voting on Projects

Community members vote on proposed projects during the 7-day voting period:

```clarity
;; Vote in favor of a project
(contract-call? .biodiversity-fund vote-on-project u1 true)

;; Vote against a project
(contract-call? .biodiversity-fund vote-on-project u1 false)
```

### Contributing to Projects

Once approved, anyone can contribute to active projects:

```clarity
;; Contribute 5 STX to project #1
(contract-call? .biodiversity-fund contribute-to-project u1 u5000000)
```

### Project Lifecycle

1. **Created** → Project proposed, enters voting phase
2. **Voting** → 7-day community voting period
3. **Active** → Approved projects accepting contributions
4. **Completed** → Funding goal met, funds withdrawn
5. **Rejected** → Failed to meet approval threshold

##  Available Functions

### Public Functions

| Function | Description | Access |
|----------|-------------|--------|
| `initialize` | Set up contract with owner as validator | Owner only |
| `create-project` | Propose new conservation project | Anyone |
| `vote-on-project` | Vote on project during voting period | Anyone |
| `finalize-project-voting` | Complete voting and set project status | Anyone |
| `contribute-to-project` | Fund active projects | Anyone |
| `withdraw-project-funds` | Claim funds when goal is met | Creator only |
| `add-validator` | Authorize new project validators | Owner only |

### Read-Only Functions

| Function | Description |
|----------|-------------|
| `get-project-details` | Retrieve complete project information |
| `get-contribution` | Check contribution amount by user |
| `get-user-stats` | Get contributor statistics |
| `get-total-funds` | Total funds in the contract |
| `get-project-count` | Number of projects created |
| `is-validator` | Check if address is authorized validator |
| `get-governance-threshold` | Current voting threshold |
| `is-funding-goal-met` | Check if project reached target |
| `get-funding-percentage` | Calculate funding completion percentage |

##  Security Features

### Access Controls
- Owner-only functions for critical operations
- Project creators can only withdraw from their own projects
- Validators must be explicitly authorized

### Financial Security
- Minimum contribution requirements prevent spam
- Funds held in contract until targets are met
- Automatic STX transfers with built-in error handling

### Governance Protection
- Single vote per address per project
- Time-bounded voting periods
- Clear approval thresholds

##  Error Codes

| Code | Error | Description |
|------|-------|-------------|
| u100 | `ERR-OWNER-ONLY` | Function restricted to contract owner |
| u101 | `ERR-NOT-AUTHORIZED` | User not authorized for this action |
| u102 | `ERR-INVALID-AMOUNT` | Amount must be greater than zero |
| u103 | `ERR-PROJECT-NOT-FOUND` | Project ID does not exist |
| u104 | `ERR-PROJECT-ALREADY-EXISTS` | Project already created |
| u105 | `ERR-INSUFFICIENT-FUNDS` | Not enough funds for operation |
| u106 | `ERR-PROJECT-NOT-ACTIVE` | Project not in active status |
| u107 | `ERR-VOTING-PERIOD-ENDED` | Voting deadline has passed |
| u108 | `ERR-ALREADY-VOTED` | User has already voted on project |
| u109 | `ERR-MINIMUM-CONTRIBUTION` | Below minimum contribution amount |

##  Project Examples

### Suitable Projects
- **Habitat Restoration**: Reforestation, wetland restoration, coral reef protection
- **Species Protection**: Anti-poaching efforts, breeding programs, sanctuary creation
- **Research Funding**: Biodiversity surveys, climate impact studies, conservation research
- **Community Programs**: Indigenous conservation, eco-tourism, sustainable practices
- **Technology Solutions**: Wildlife monitoring, conservation apps, data collection

### Project Requirements
- Clear conservation objectives
- Measurable impact metrics
- Transparent fund utilization
- Regular progress reporting
- Community benefit focus

##  Testing

### Testnet Deployment
```bash
# Deploy to testnet
clarinet deploy --testnet

# Test project creation
clarinet console --testnet
```

### Local Testing
```bash
# Run tests locally
clarinet test

# Check contract syntax
clarinet check
```

##  Contributing

We welcome contributions to improve the Biodiversity Preservation Fund:

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

### Development Setup
```bash
# Install Clarinet
npm install -g @hirosystems/clarinet-cli

# Clone repository
git clone [repository-url]
cd biodiversity-preservation-fund

# Run tests
clarinet test
```

##  License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

##  Acknowledgments

- Built on the Stacks blockchain for transparency and decentralization
- Inspired by global biodiversity conservation efforts
- Thanks to the Clarity smart contract language for security features

##  Contact

- **Project Lead**: [Your Name]
- **Email**: [your-email@example.com]
- **Twitter**: [@your-twitter]
- **Discord**: [Your Discord Server]

---

** Help preserve our planet's biodiversity - one project at a time.**