;; Community Rewards Distribution Contract 
;; Basic implementation with core reward distribution functionality

;; Define constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERROR-NOT-CONTRACT-OWNER (err u100))
(define-constant ERROR-REWARD-ALREADY-CLAIMED (err u101))
(define-constant ERROR-CONTRIBUTOR-NOT-ELIGIBLE (err u102))
(define-constant ERROR-INSUFFICIENT-POINTS-BALANCE (err u103))

;; Define data variables
(define-data-var total-points-distributed uint u0)
(define-data-var points-per-contribution uint u100)

;; Define data maps
(define-map eligible-contributors principal bool)
(define-map claimed-reward-points principal uint)

;; Define fungible token
(define-fungible-token community-points)

;; Admin functions
(define-public (add-eligible-contributor (contributor-address principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERROR-NOT-CONTRACT-OWNER)
    (ok (map-set eligible-contributors contributor-address true))))

(define-public (remove-eligible-contributor (contributor-address principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERROR-NOT-CONTRACT-OWNER)
    (ok (map-delete eligible-contributors contributor-address))))

(define-public (update-points-reward (new-amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERROR-NOT-CONTRACT-OWNER)
    (var-set points-per-contribution new-amount)
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

;; Contract initialization
(begin
  (ft-mint? community-points u1000000000 CONTRACT-OWNER))