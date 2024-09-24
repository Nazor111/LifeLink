;; Portable Healthcare Records Smart Contract

;; Define constants
(define-constant err-not-owner (err u100))
(define-constant err-invalid-data (err u101))
(define-constant err-record-not-found (err u102))
(define-constant err-access-denied (err u103))

;; Define data maps
(define-map patient-records (tuple (patient-id principal) (record-id uint)) (tuple (data (string-ascii 1000)) (authorized-providers (list 10 principal))))
(define-map provider-access principal (list 10 (tuple (patient-id principal) (record-id uint))))

;; Public function to add a new healthcare record
(define-public (add-healthcare-record (patient-id principal) (record-id uint) (data (string-ascii 1000)))
  (begin
    (asserts! (is-eq tx-sender patient-id) err-not-owner)
    (map-set patient-records (tuple patient-id record-id) (tuple data (list tx-sender)))
    (ok true)))

;; Public function to share a healthcare record with a provider
(define-public (share-healthcare-record (patient-id principal) (record-id uint) (provider principal))
  (let ((record (map-get? patient-records (tuple patient-id record-id))))
    (if (is-none record)
        (err err-record-not-found)
        (begin
          (map-set patient-records (tuple patient-id record-id) (tuple (get data (unwrap! record)) (append (get authorized-providers (unwrap! record)) provider)))
          (map-set provider-access provider (append (default-to (list) (map-get? provider-access provider)) (tuple patient-id record-id)))
          (ok true)))))

;; Public function to revoke a provider's access to a healthcare record
(define-public (revoke-healthcare-access (patient-id principal) (record-id uint) (provider principal))
  (let ((record (map-get? patient-records (tuple patient-id record-id))))
    (if (is-none record)
        (err err-record-not-found)
        (let ((authorized-providers (get authorized-providers (unwrap! record))))
          (if (not (contains? authorized-providers provider))
              (err err-access-denied)
              (begin
                (map-set patient-records (tuple patient-id record-id) (tuple (get data (unwrap! record)) (filter (lambda (p) (is-not-eq p provider)) authorized-providers)))
                (map-set provider-access provider (filter (lambda (r) (not (and (is-eq (get patient-id r) patient-id) (is-eq (get record-id r) record-id)))) (default-to (list) (map-get? provider-access provider))))
                (ok true)))))))

;; Read-only function to get a healthcare record
(define-read-only (get-healthcare-record (patient-id principal) (record-id uint))
  (let ((record (map-get? patient-records (tuple patient-id record-id))))
    (if (is-none record)
        (err err-record-not-found)
        (ok (get data (unwrap! record))))))

;; Read-only function to get a provider's authorized healthcare records
(define-read-only (get-authorized-records (provider principal))
  (ok (default-to (list) (map-get? provider-access provider))))