;; Community Rewards Distribution Contract - Enhanced with bulk operations and event logging

;; Define constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERROR-NOT-CONTRACT-OWNER (err u100))
(define-constant ERROR-REWARD-ALREADY-CLAIMED (err u101))
(define-constant ERROR-CONTRIBUTOR-NOT-ELIGIBLE (err u102))
(define-constant ERROR-INSUFFICIENT-POINTS-BALANCE (err u103))
(define-constant ERROR-INVALID-POINTS (err u104))
(define-constant ERROR-INVALID-CONTRIBUTOR (err u105))

;; Define data variables
(define-data-var total-points-distributed uint u0)
(define-data-var points-per-contribution uint u100)
(define-data-var next-event-id uint u0)

;; Define data maps
(define-map eligible-contributors principal bool)
(define-map claimed-reward-points principal uint)
(define-map contract-events uint {event-type: (string-ascii 20), data: (string-ascii 256)})

;; Define fungible token
(define-fungible-token community-points)

;; Event logging function
(define-private (log-event (event-type (string-ascii 20)) (data (string-ascii 256)))
  (let ((event-id (var-get next-event-id)))
    (map-set contract-events event-id {event-type: event-type, data: data})
    (var-set next-event-id (+ event-id u1))
    event-id))

;; Admin functions
(define-public (add-eligible-contributor (contributor-address principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERROR-NOT-CONTRACT-OWNER)
    (asserts! (is-none (map-get? eligible-contributors contributor-address)) ERROR-INVALID-CONTRIBUTOR)
    (log-event "contributor-add" "new contributor")
    (ok (map-set eligible-contributors contributor-address true))))

(define-public (remove-eligible-contributor (contributor-address principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERROR-NOT-CONTRACT-OWNER)
    (asserts! (is-some (map-get? eligible-contributors contributor-address)) ERROR-CONTRIBUTOR-NOT-ELIGIBLE)
    (log-event "contributor-remove" "removed contributor")
    (ok (map-delete eligible-contributors contributor-address))))

(define-public (bulk-add-eligible-contributors (contributor-addresses (list 200 principal)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERROR-NOT-CONTRACT-OWNER)
    (log-event "bulk-contrib-add" "contributors added")
    (ok (map add-eligible-contributor contributor-addresses))))

(define-public (update-points-reward (new-amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERROR-NOT-CONTRACT-OWNER)
    (asserts! (> new-amount u0) ERROR-INVALID-POINTS)
    (var-set points-per-contribution new-amount)
    (log-event "amount-updated" "amount changed")
    (ok new-amount)))

;; Points claim function
(define-public (claim-reward-points)
  (let (
    (contributor-address tx-sender)
    (claim-amount (var-get points-per-contribution))
  )
    (asserts! (is-some (map-get? eligible-contributors contributor-address)) ERROR-CONTRIBUTOR-NOT-ELIGIBLE)
    (asserts! (is-none (map-get? claimed-reward-points contributor-address)) ERROR-REWARD-ALREADY-CLAIMED)
    (asserts! (<= claim-amount (ft-get-balance community-points CONTRACT-OWNER)) ERROR-INSUFFICIENT-POINTS-BALANCE)
    (try! (ft-transfer? community-points claim-amount CONTRACT-OWNER contributor-address))
    (map-set claimed-reward-points contributor-address claim-amount)
    (var-set total-points-distributed (+ (var-get total-points-distributed) claim-amount))
    (log-event "points-claimed" "points claimed")
    (ok claim-amount)))

;; Read-only functions
(define-read-only (is-contributor-eligible (contributor-address principal))
  (default-to false (map-get? eligible-contributors contributor-address)))

(define-read-only (has-contributor-claimed-points (contributor-address principal))
  (is-some (map-get? claimed-reward-points contributor-address)))

(define-read-only (get-contributor-claimed-amount (contributor-address principal))
  (default-to u0 (map-get? claimed-reward-points contributor-address)))

(define-read-only (get-total-points-distributed)
  (var-get total-points-distributed))

(define-read-only (get-points-per-contribution)
  (var-get points-per-contribution))

(define-read-only (get-event (event-id uint))
  (map-get? contract-events event-id))

;; Contract initialization
(begin
  (ft-mint? community-points u1000000000 CONTRACT-OWNER))