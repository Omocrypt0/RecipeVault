;; RecipeVault - Intellectual Property Registry for Recipes
;; A platform for chefs and food companies to register proprietary recipes

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-already-exists (err u103))
(define-constant err-invalid-input (err u104))

;; Data Variables
(define-data-var recipe-counter uint u0)

;; Data Maps
(define-map recipes
  uint
  {
    owner: principal,
    recipe-name: (string-ascii 100),
    recipe-hash: (buff 32),
    category: (string-ascii 50),
    registered-at: uint,
    is-active: bool
  }
)

(define-map owner-recipes
  principal
  (list 100 uint)
)

(define-map recipe-transfers
  uint
  {
    from: principal,
    to: principal,
    transferred-at: uint
  }
)

;; Read-only functions
(define-read-only (get-recipe (recipe-id uint))
  (map-get? recipes recipe-id)
)

(define-read-only (get-owner-recipes (owner principal))
  (default-to (list) (map-get? owner-recipes owner))
)

(define-read-only (get-recipe-count)
  (var-get recipe-counter)
)

(define-read-only (get-transfer-history (recipe-id uint))
  (map-get? recipe-transfers recipe-id)
)

(define-read-only (verify-ownership (recipe-id uint) (claimer principal))
  (match (map-get? recipes recipe-id)
    recipe (ok (is-eq (get owner recipe) claimer))
    (err err-not-found)
  )
)

;; Private functions
(define-private (add-recipe-to-owner (owner principal) (recipe-id uint))
  (let
    (
      (current-recipes (default-to (list) (map-get? owner-recipes owner)))
    )
    (map-set owner-recipes owner (unwrap-panic (as-max-len? (append current-recipes recipe-id) u100)))
  )
)

(define-private (remove-recipe-from-owner (owner principal) (recipe-id uint))
  (let
    (
      (current-recipes (default-to (list) (map-get? owner-recipes owner)))
      (filtered-recipes (filter is-not-recipe-id current-recipes))
    )
    (map-set owner-recipes owner filtered-recipes)
  )
)

(define-private (is-not-recipe-id (id uint))
  (not (is-eq id (var-get recipe-counter)))
)

;; Public functions
(define-public (register-recipe 
  (recipe-name (string-ascii 100))
  (recipe-hash (buff 32))
  (category (string-ascii 50))
)
  (let
    (
      (new-recipe-id (+ (var-get recipe-counter) u1))
    )
    ;; Validate inputs
    (asserts! (> (len recipe-name) u0) err-invalid-input)
    (asserts! (> (len category) u0) err-invalid-input)
    
    ;; Create recipe entry
    (map-set recipes new-recipe-id
      {
        owner: tx-sender,
        recipe-name: recipe-name,
        recipe-hash: recipe-hash,
        category: category,
        registered-at: stacks-block-height,
        is-active: true
      }
    )
    
    ;; Add to owner's recipe list
    (add-recipe-to-owner tx-sender new-recipe-id)
    
    ;; Increment counter
    (var-set recipe-counter new-recipe-id)
    
    (ok new-recipe-id)
  )
)

(define-public (transfer-recipe (recipe-id uint) (new-owner principal))
  (let
    (
      (recipe (unwrap! (map-get? recipes recipe-id) err-not-found))
    )
    ;; Check ownership
    (asserts! (is-eq (get owner recipe) tx-sender) err-unauthorized)
    (asserts! (get is-active recipe) err-unauthorized)
    
    ;; Update recipe owner
    (map-set recipes recipe-id (merge recipe { owner: new-owner }))
    
    ;; Record transfer
    (map-set recipe-transfers recipe-id
      {
        from: tx-sender,
        to: new-owner,
        transferred-at: stacks-block-height
      }
    )
    
    ;; Update ownership lists
    (add-recipe-to-owner new-owner recipe-id)
    
    (ok true)
  )
)

(define-public (deactivate-recipe (recipe-id uint))
  (let
    (
      (recipe (unwrap! (map-get? recipes recipe-id) err-not-found))
    )
    ;; Check ownership
    (asserts! (is-eq (get owner recipe) tx-sender) err-unauthorized)
    
    ;; Deactivate recipe
    (map-set recipes recipe-id (merge recipe { is-active: false }))
    
    (ok true)
  )
)

(define-public (reactivate-recipe (recipe-id uint))
  (let
    (
      (recipe (unwrap! (map-get? recipes recipe-id) err-not-found))
    )
    ;; Check ownership
    (asserts! (is-eq (get owner recipe) tx-sender) err-unauthorized)
    
    ;; Reactivate recipe
    (map-set recipes recipe-id (merge recipe { is-active: true }))
    
    (ok true)
  )
)

(define-public (update-recipe-hash (recipe-id uint) (new-hash (buff 32)))
  (let
    (
      (recipe (unwrap! (map-get? recipes recipe-id) err-not-found))
    )
    ;; Check ownership
    (asserts! (is-eq (get owner recipe) tx-sender) err-unauthorized)
    (asserts! (get is-active recipe) err-unauthorized)
    
    ;; Update hash
    (map-set recipes recipe-id (merge recipe { recipe-hash: new-hash }))
    
    (ok true)
  )
)