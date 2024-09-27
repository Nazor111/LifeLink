# LifeLink - Healthcare Smart Contract

## Overview

This smart contract implements a secure and privacy-focused system for managing patient health records and provider access in a decentralized healthcare ecosystem. Built on the Stacks blockchain using Clarity, this contract enables patients to control their health data and grant time-limited access to healthcare providers.

## Features

- **Patient Registration**: Allows patients to register and store encrypted health data.
- **Provider Registration**: Enables healthcare providers to register with their credentials.
- **Secure Data Storage**: Patient data is stored in an encrypted format.
- **Granular Access Control**: Patients can grant and revoke access to specific providers.
- **Timed Access**: Implements time-limited access for providers, enhancing data privacy.
- **Data Update Mechanism**: Patients can update their health records securely.
- **Access Verification**: Providers can verify their access status before attempting to read patient data.

## Smart Contract Functions

### Public Functions

1. `register-patient`: Register a new patient with encrypted data.
2. `update-patient-data`: Update a patient's encrypted data.
3. `grant-provider-access`: Grant time-limited access to a provider.
4. `access-patient-data`: Allow a provider to access patient data.
5. `register-provider`: Register a new healthcare provider.

### Read-Only Functions

1. `provider-has-access?`: Check if a provider has current access to a patient's data.
2. `get-patient-providers`: Get a list of providers for a patient.
3. `get-provider-info`: Retrieve information about a provider.
4. `get-patient-data-hash`: Get the hash of a patient's data.
5. `get-patient-count`: Get the total number of registered patients.
6. `get-provider-count`: Get the total number of registered providers.
7. `get-provider-access-details`: Get detailed access information for a provider.

## Setup and Deployment

1. Ensure you have the Stacks blockchain development environment set up.
2. Clone this repository to your local machine.
3. Deploy the smart contract to the Stacks blockchain using the appropriate deployment commands.

## Usage

After deployment, interact with the contract using a Stacks wallet or through API calls. Here are some example interactions:

- Patients can register and update their data using `register-patient` and `update-patient-data`.
- Providers can register using `register-provider`.
- Patients can grant access to providers using `grant-provider-access`.
- Providers can check and access patient data using `provider-has-access?` and `access-patient-data`.

## Security Considerations

- All patient data should be encrypted before being passed to the smart contract.
- The contract uses principal-based authentication for all operations.
- Access expiration is enforced to ensure data privacy over time.

## Contributing

Contributions to improve the smart contract are welcome. Please submit pull requests or open issues to discuss proposed changes.

