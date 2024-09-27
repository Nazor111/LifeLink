;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-not-authorized (err u100))
(define-constant err-patient-not-found (err u101))
(define-constant err-provider-not-found (err u102))
(define-constant err-already-registered (err u103))
(define-constant err-invalid-data (err u104))
(define-constant err-provider-limit-reached (err u105))

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
    access-level: (string-ascii 20)
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

;; Define public functions

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

;; Function to grant access to a provider
(define-public (grant-provider-access (provider principal) (encryption-key (buff 128)) (access-level (string-ascii 20)))
  (let
    (
      (patient tx-sender)
      (patient-data (map-get? patients patient))
    )
    (asserts! (is-some (map-get? provider-info provider)) err-provider-not-found)
    (asserts! (is-some patient-data) err-patient-not-found)
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
          access-level: access-level
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
      access-info (if (get access access-info)
        (ok {
          encryption-key: (get encryption-key access-info),
          access-level: (get access-level access-info)
        })
        err-not-authorized
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
    access-data (get access access-data)
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