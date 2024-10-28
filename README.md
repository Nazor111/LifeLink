# LifeLink - Healthcare Smart Contract

## Overview

This smart contract implements a secure and privacy-focused system for managing patient health records and provider access in a decentralized healthcare ecosystem. Built on the Stacks blockchain using Clarity, this contract enables patients to control their health data and grant time-limited access to healthcare providers while maintaining compliance with healthcare privacy standards.

## Features

- **Patient Registration**: Allows patients to register and store encrypted health data
- **Provider Registration**: Enables healthcare providers to register with their credentials
- **Secure Data Storage**: Patient data is stored in an encrypted format with data hashing
- **Granular Access Control**: Patients can grant and revoke access to specific providers
- **Timed Access**: Implements time-limited access for providers, enhancing data privacy
- **Data Update Mechanism**: Patients can update their health records securely
- **Access Verification**: Providers can verify their access status before attempting to read patient data
- **Data Deletion**: Supports complete removal of patient data for privacy compliance
- **Provider Revocation**: Allows patients to selectively revoke provider access

## Smart Contract Functions

### Public Functions

1. `register-patient`: Register a new patient with encrypted data
2. `update-patient-data`: Update a patient's encrypted data
3. `grant-provider-access`: Grant time-limited access to a provider
4. `access-patient-data`: Allow a provider to access patient data
5. `register-provider`: Register a new healthcare provider
6. `delete-patient-data`: Remove all patient data and provider access records
7. `revoke-provider`: Revoke a specific provider's access to patient data

### Read-Only Functions

1. `provider-has-access?`: Check if a provider has current access to a patient's data
2. `get-patient-providers`: Get a list of providers for a patient
3. `get-provider-info`: Retrieve information about a provider
4. `get-patient-data-hash`: Get the hash of a patient's data
5. `get-patient-count`: Get the total number of registered patients
6. `get-provider-count`: Get the total number of registered providers
7. `get-provider-access-details`: Get detailed access information for a provider

## Setup and Deployment

1. Ensure you have the Stacks blockchain development environment set up
2. Clone this repository to your local machine
3. Deploy the smart contract to the Stacks blockchain using Clarinet
4. Test the contract using the provided test suite

```bash
# Install dependencies
clarinet install

# Run tests
clarinet test

# Deploy contract
clarinet deploy
```

## Usage

### For Patients

```clarity
;; Register as a new patient
(contract-call? .lifelink register-patient encrypted-data)

;; Update health records
(contract-call? .lifelink update-patient-data new-encrypted-data)

;; Grant provider access
(contract-call? .lifelink grant-provider-access provider-principal encryption-key "read" u30)

;; Revoke provider access
(contract-call? .lifelink revoke-provider provider-principal)

;; Delete all patient data
(contract-call? .lifelink delete-patient-data)
```

### For Providers

```clarity
;; Register as a provider
(contract-call? .lifelink register-provider "Dr. Smith" "LIC123456" "Cardiology")

;; Check access status
(contract-call? .lifelink provider-has-access? patient-principal tx-sender)

;; Access patient data
(contract-call? .lifelink access-patient-data patient-principal)
```

## Security and Privacy Features

- **Encryption**: All patient data must be encrypted before being stored on-chain
- **Access Control**: 
  - Only patients can grant or revoke access to their data
  - Providers can only access data they've been explicitly granted access to
  - Time-limited access with automatic expiration
- **Data Privacy**:
  - Support for complete data deletion
  - Selective provider access revocation
  - Data hashing for integrity verification
- **Authentication**:
  - Principal-based authentication for all operations
  - Provider credential verification
  - Access level controls (read/write/full)

## Error Handling

The contract includes comprehensive error handling for common scenarios:

- `err-not-authorized`: Unauthorized access attempt
- `err-patient-not-found`: Patient record doesn't exist
- `err-provider-not-found`: Provider not registered
- `err-already-registered`: Duplicate registration attempt
- `err-invalid-data`: Invalid or empty data submission
- `err-provider-limit-reached`: Maximum provider limit reached
- `err-access-expired`: Provider access has expired
- `err-provider-not-in-list`: Provider not in patient's provider list

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/NewFeature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/NewFeature`)
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Best Practices

1. Always encrypt sensitive data before sending it to the contract
2. Regularly verify provider access status
3. Set appropriate access durations for providers
4. Maintain secure key management for encryption/decryption
5. Regularly audit provider access lists

## Future Enhancements

- Batch operations for provider access management
- Advanced access control patterns (role-based, multi-sig)
- Integration with healthcare standards (HL7, FHIR)
- Enhanced audit logging capabilities
- Emergency access protocols
- Data recovery mechanisms

## Support

For technical support or questions:
1. Open an issue in the GitHub repository
2. Join our developer community
3. Review the technical documentation