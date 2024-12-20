# CredStack - Decentralized Professional Credential Verification System

CredStack is a decentralized credential verification system built on the Stacks blockchain using Clarity smart contracts. It enables secure, verifiable, and privacy-preserving management of professional credentials, certifications, and employment history.

## Features

### User Profile Management
- Create and manage professional profiles
- Store basic user information on-chain
- Track profile creation and update timestamps

### Credential Management
- Issue verifiable credentials by authorized institutions
- Support for multiple credential types (degrees, certifications, employment history)
- Expiration date management
- Privacy controls for selective disclosure

### Multi-party Verification
- Request credential verification from multiple parties
- Configurable number of required verifications
- Status tracking for verification processes
- Automated verification state management

### Authorized Issuers System
- Managed registry of authorized credential issuers
- Reputation scoring for issuers
- Track record of issued credentials
- Institutional categorization

### Privacy Controls
- Toggle credential visibility
- Private/public credential status
- Selective information disclosure

### Reputation System
- Dynamic reputation scoring for issuers
- Score adjustments based on verification accuracy
- Track total credentials issued

## Smart Contract Functions

### Read-Only Functions
```clarity
get-user-profile: Retrieve user profile information
get-credential: Get credential details
get-issuer-details: View issuer information
get-verification-request: Check verification request status
```

### Public Functions
```clarity
create-profile: Create new user profile
register-issuer: Add authorized issuer
issue-credential: Issue new credential
toggle-credential-privacy: Manage credential visibility
request-verification: Initiate verification process
verify-credential: Submit credential verification
update-issuer-reputation: Adjust issuer reputation scores
```

## Data Structures

### UserProfiles
- Principal-based user identification
- Profile status tracking
- Timestamp management

### Credentials
- User and credential ID mapping
- Comprehensive credential details
- Privacy and verification status

### AuthorizedIssuers
- Issuer details and categorization
- Reputation scoring
- Credential issuance tracking

### VerificationRequests
- Multi-party verification tracking
- Required verification thresholds
- Current verification counts

## Error Handling
```clarity
err-owner-only (u100): Restricted to contract owner
err-not-authorized (u101): Unauthorized access
err-already-exists (u102): Duplicate entry
err-not-found (u103): Resource not found
err-expired (u104): Expired or invalid status
```

## Usage Example

1. Institution Registration:
```clarity
(register-issuer institution-address "University Name" "Educational")
```

2. Profile Creation:
```clarity
(create-profile "John Doe")
```

3. Credential Issuance:
```clarity
(issue-credential user-address "Bachelor's Degree" "Computer Science" expiry-date false)
```

4. Verification Request:
```clarity
(request-verification credential-id u3)
```

## Security Considerations
- Owner-only administrative functions
- Multi-party verification requirements
- Privacy controls for sensitive data
- Reputation system for trust management
- State validation checks

## Future Enhancements
- Credential revocation mechanism
- Enhanced privacy features
- Bulk operations support
- Extended verification types
- Integration with additional identity systems