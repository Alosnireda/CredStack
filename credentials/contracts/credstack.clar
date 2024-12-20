;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-not-found (err u103))
(define-constant err-expired (err u104))

;; Data Variables
(define-map UserProfiles
    principal
    {
        name: (string-ascii 64),
        profile-status: (string-ascii 20),
        created-at: uint,
        updated-at: uint
    }
)

(define-map Credentials
    {user: principal, credential-id: uint}
    {
        issuer: principal,
        credential-type: (string-ascii 64),
        description: (string-ascii 256),
        issue-date: uint,
        expiry-date: uint,
        is-private: bool,
        verification-status: (string-ascii 20)
    }
)

(define-map AuthorizedIssuers
    principal
    {
        name: (string-ascii 64),
        issuer-type: (string-ascii 20),
        reputation-score: uint,
        total-credentials-issued: uint
    }
)

(define-map VerificationRequests
    uint
    {
        credential-id: uint,
        requester: principal,
        status: (string-ascii 20),
        required-verifications: uint,
        current-verifications: uint
    }
)

;; Data variables for counters
(define-data-var credential-id-nonce uint u0)
(define-data-var verification-request-nonce uint u0)

;; Read-only functions
(define-read-only (get-user-profile (user principal))
    (map-get? UserProfiles user)
)

(define-read-only (get-credential 
    (user principal) 
    (credential-id uint))
    (map-get? Credentials {user: user, credential-id: credential-id})
)

(define-read-only (get-issuer-details (issuer principal))
    (map-get? AuthorizedIssuers issuer)
)

(define-read-only (get-verification-request (request-id uint))
    (map-get? VerificationRequests request-id)
)

;; Public functions

;; User Profile Management
(define-public (create-profile (name (string-ascii 64)))
    (let
        ((user tx-sender))
        (asserts! (is-none (get-user-profile user)) err-already-exists)
        (ok (map-set UserProfiles
            user
            {
                name: name,
                profile-status: "active",
                created-at: block-height,
                updated-at: block-height
            }
        ))
    )
)

;; Issuer Management
(define-public (register-issuer 
    (issuer-principal principal)
    (name (string-ascii 64))
    (issuer-type (string-ascii 20)))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ok (map-set AuthorizedIssuers
            issuer-principal
            {
                name: name,
                issuer-type: issuer-type,
                reputation-score: u100,
                total-credentials-issued: u0
            }
        ))
    )
)

;; Credential Management
(define-public (issue-credential
    (user principal)
    (credential-type (string-ascii 64))
    (description (string-ascii 256))
    (expiry-date uint)
    (is-private bool))
    (let
        ((issuer tx-sender)
         (new-id (+ (var-get credential-id-nonce) u1))
         (issuer-data (unwrap! (get-issuer-details issuer) err-not-authorized)))
        (asserts! (not (is-none (get-user-profile user))) err-not-found)
        (var-set credential-id-nonce new-id)
        (ok (map-set Credentials
            {user: user, credential-id: new-id}
            {
                issuer: issuer,
                credential-type: credential-type,
                description: description,
                issue-date: block-height,
                expiry-date: expiry-date,
                is-private: is-private,
                verification-status: "active"
            }
        ))
    )
)

;; Privacy Management
(define-public (toggle-credential-privacy
    (credential-id uint))
    (let
        ((credential (unwrap! (get-credential tx-sender credential-id) err-not-found))
         (current-privacy (get is-private credential)))
        (ok (map-set Credentials
            {user: tx-sender, credential-id: credential-id}
            (merge credential {is-private: (not current-privacy)})
        ))
    )
)

;; Multi-party Verification
(define-public (request-verification
    (credential-id uint)
    (required-verifications uint))
    (let
        ((new-request-id (+ (var-get verification-request-nonce) u1)))
        (var-set verification-request-nonce new-request-id)
        (ok (map-set VerificationRequests
            new-request-id
            {
                credential-id: credential-id,
                requester: tx-sender,
                status: "pending",
                required-verifications: required-verifications,
                current-verifications: u0
            }
        ))
    )
)

(define-public (verify-credential
    (request-id uint))
    (let
        ((request (unwrap! (get-verification-request request-id) err-not-found))
         (verifier tx-sender)
         (issuer-data (unwrap! (get-issuer-details verifier) err-not-authorized))
         (new-verification-count (+ (get current-verifications request) u1)))
        (asserts! (is-eq (get status request) "pending") err-expired)
        (if (>= new-verification-count (get required-verifications request))
            (map-set VerificationRequests
                request-id
                (merge request {
                    status: "verified",
                    current-verifications: new-verification-count
                })
            )
            (map-set VerificationRequests
                request-id
                (merge request {
                    current-verifications: new-verification-count
                })
            )
        )
        (ok true)
    )
)

;; Reputation System
(define-public (update-issuer-reputation
    (issuer principal)
    (score-change int))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (let
            ((issuer-data (unwrap! (get-issuer-details issuer) err-not-found))
             (current-score (get reputation-score issuer-data))
             (new-score (+ current-score (if (> score-change i0)
                                           (to-uint score-change)
                                           u0))))
            (ok (map-set AuthorizedIssuers
                issuer
                (merge issuer-data {
                    reputation-score: new-score
                })
            ))
        )
    )
)