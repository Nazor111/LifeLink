;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-not-authorized (err u100))
(define-constant err-patient-not-found (err u101))
(define-constant err-provider-not-found (err u102))
(define-constant err-already-registered (err u103))
(define-constant err-invalid-data (err u104))
(define-constant err-provider-limit-reached (err u105))
(define-constant err-invalid-input (err u106))
(define-constant err-access-expired (err u107))

;; Define data maps
(define-map patients 
  principal 
  {
    encrypted-data: (buff 1024),
    providers: (list 20 principal),
    last-updated: uint,
    data-hash: (buff 32)
  }
)

(define-map provider-access
  {patient: principal, provider: principal}
  {
    access: bool,
    encryption-key: (buff 128),
    access-granted-at: uint,
    access-level: (string-ascii 20),
    access-expiration: uint
  }
)

(define-map provider-info
  principal
  {
    name: (string-ascii 50),
    license-number: (string-ascii 20),
    specialty: (string-ascii 30)
  }
)

;; Define data variables
(define-data-var patient-count uint u0)
(define-data-var provider-count uint u0)

;; Helper functions for input validation
(define-private (is-valid-string (input (string-ascii 50)))
  (and (>= (len input) u1) (<= (len input) u50))
)

(define-private (is-valid-license-number (input (string-ascii 20)))
  (and (>= (len input) u5) (<= (len input) u20))
)

(define-private (is-valid-specialty (input (string-ascii 30)))
  (and (>= (len input) u3) (<= (len input) u30))
)

(define-private (is-valid-access-level (input (string-ascii 20)))
  (or (is-eq input "read") (is-eq input "write") (is-eq input "full"))
)

;; Helper function to check if access has expired
(define-private (is-access-expired (access-granted-at uint) (access-expiration uint))
  (> block-height (+ access-granted-at access-expiration))
)

;; Helper function to revoke all provider access for a patient
(define-private (revoke-provider-access (provider principal) (patient principal))
  (map-delete provider-access {patient: patient, provider: provider})
)

;; Define public functions

;; Function to delete patient data
(define-public (delete-patient-data)
  (let
    (
      (patient tx-sender)
      (patient-data (map-get? patients patient))
    )
    (asserts! (is-some patient-data) err-patient-not-found)
    (let
      (
        (current-providers (get providers (unwrap-panic patient-data)))
      )
      ;; Revoke access for all providers
      (map revoke-provider-access current-providers (list patient))
      ;; Delete patient record
      (map-delete patients patient)
      ;; Decrease patient count
      (var-set patient-count (- (var-get patient-count) u1))
      (ok true)
    )
  )
)

;; Function to register a new patient
(define-public (register-patient (encrypted-data (buff 1024)))
  (let
    (
      (patient tx-sender)
      (data-hash (sha256 encrypted-data))
    )
    (asserts! (is-none (map-get? patients patient)) err-already-registered)
    (asserts! (> (len encrypted-data) u0) err-invalid-data)
    (map-set patients patient {
      encrypted-data: encrypted-data,
      providers: (list),
      last-updated: block-height,
      data-hash: data-hash
    })
    (var-set patient-count (+ (var-get patient-count) u1))
    (ok true)
  )
)

;; Function to update patient data
(define-public (update-patient-data (new-encrypted-data (buff 1024)))
  (let
    (
      (patient tx-sender)
      (data-hash (sha256 new-encrypted-data))
      (patient-data (map-get? patients patient))
    )
    (asserts! (> (len new-encrypted-data) u0) err-invalid-data)
    (asserts! (is-some patient-data) err-patient-not-found)
    (ok (map-set patients patient 
      (merge (unwrap-panic patient-data) 
        {
          encrypted-data: new-encrypted-data,
          last-updated: block-height,
          data-hash: data-hash
        }
      )
    ))
  )
)

;; Function to grant access to a provider with expiration
(define-public (grant-provider-access (provider principal) (encryption-key (buff 128)) (access-level (string-ascii 20)) (access-duration uint))
  (let
    (
      (patient tx-sender)
      (patient-data (map-get? patients patient))
    )
    (asserts! (is-some (map-get? provider-info provider)) err-provider-not-found)
    (asserts! (is-some patient-data) err-patient-not-found)
    (asserts! (is-valid-access-level access-level) err-invalid-input)
    (asserts! (> (len encryption-key) u0) err-invalid-input)
    (asserts! (> access-duration u0) err-invalid-input)
    (let
      (
        (current-data (unwrap-panic patient-data))
        (current-providers (get providers current-data))
      )
      (asserts! (< (len current-providers) u20) err-provider-limit-reached)
      (map-set provider-access {patient: patient, provider: provider}
        {
          access: true, 
          encryption-key: encryption-key, 
          access-granted-at: block-height, 
          access-level: access-level,
          access-expiration: access-duration
        }
      )
      (ok (map-set patients patient 
        (merge current-data 
          {providers: (unwrap-panic (as-max-len? (append current-providers provider) u20))}
        )
      ))
    )
  )
)

;; Function for provider to access patient data
(define-public (access-patient-data (patient principal))
  (let
    (
      (provider tx-sender)
      (access-data (map-get? provider-access {patient: patient, provider: provider}))
    )
    (match access-data
      access-info (if (and (get access access-info) 
                           (not (is-access-expired 
                                  (get access-granted-at access-info)
                                  (get access-expiration access-info))))
        (ok {
          encryption-key: (get encryption-key access-info),
          access-level: (get access-level access-info)
        })
        (if (is-access-expired 
              (get access-granted-at access-info)
              (get access-expiration access-info))
          err-access-expired
          err-not-authorized
        )
      )
      err-provider-not-found
    )
  )
)

;; Function to register a provider
(define-public (register-provider (name (string-ascii 50)) (license-number (string-ascii 20)) (specialty (string-ascii 30)))
  (let
    (
      (provider tx-sender)
    )
    (asserts! (is-none (map-get? provider-info provider)) err-already-registered)
    (asserts! (is-valid-string name) err-invalid-input)
    (asserts! (is-valid-license-number license-number) err-invalid-input)
    (asserts! (is-valid-specialty specialty) err-invalid-input)
    (map-set provider-info provider {
      name: name,
      license-number: license-number,
      specialty: specialty
    })
    (var-set provider-count (+ (var-get provider-count) u1))
    (ok true)
  )
)

;; Read-only functions

;; Function to check if a provider has access to a patient's data
(define-read-only (provider-has-access? (patient principal) (provider principal))
  (match (map-get? provider-access {patient: patient, provider: provider})
    access-data (and (get access access-data) 
                     (not (is-access-expired 
                            (get access-granted-at access-data)
                            (get access-expiration access-data))))
    false
  )
)

;; Function to get patient's providers list
(define-read-only (get-patient-providers (patient principal))
  (match (map-get? patients patient)
    patient-data (ok (get providers patient-data))
    err-patient-not-found
  )
)

;; Function to get provider information
(define-read-only (get-provider-info (provider principal))
  (match (map-get? provider-info provider)
    info (ok info)
    err-provider-not-found
  )
)

;; Function to get patient data hash
(define-read-only (get-patient-data-hash (patient principal))
  (match (map-get? patients patient)
    patient-data (ok (get data-hash patient-data))
    err-patient-not-found
  )
)

;; Function to get total patient count
(define-read-only (get-patient-count)
  (ok (var-get patient-count))
)

;; Function to get total provider count
(define-read-only (get-provider-count)
  (ok (var-get provider-count))
)

;; Function to get provider access details
(define-read-only (get-provider-access-details (patient principal) (provider principal))
  (match (map-get? provider-access {patient: patient, provider: provider})
    access-data (ok {
      access: (get access access-data),
      access-granted-at: (get access-granted-at access-data),
      access-level: (get access-level access-data),
      access-expiration: (get access-expiration access-data),
      is-expired: (is-access-expired (get access-granted-at access-data) (get access-expiration access-data))
    })
    err-provider-not-found
  )
)