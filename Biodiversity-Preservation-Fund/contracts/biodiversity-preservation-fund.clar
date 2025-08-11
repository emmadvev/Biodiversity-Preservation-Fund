;; Biodiversity Preservation Fund Smart Contract
;; A decentralized fund for supporting biodiversity conservation projects

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-OWNER-ONLY (err u100))
(define-constant ERR-NOT-AUTHORIZED (err u101))
(define-constant ERR-INVALID-AMOUNT (err u102))
(define-constant ERR-PROJECT-NOT-FOUND (err u103))
(define-constant ERR-PROJECT-ALREADY-EXISTS (err u104))
(define-constant ERR-INSUFFICIENT-FUNDS (err u105))
(define-constant ERR-PROJECT-NOT-ACTIVE (err u106))
(define-constant ERR-VOTING-PERIOD-ENDED (err u107))
(define-constant ERR-ALREADY-VOTED (err u108))
(define-constant ERR-MINIMUM-CONTRIBUTION (err u109))

;; Minimum contribution amount (1 STX)
(define-constant MIN-CONTRIBUTION u1000000)

;; Data Variables
(define-data-var total-funds uint u0)
(define-data-var project-counter uint u0)
(define-data-var governance-threshold uint u66) ;; 66% approval needed

;; Data Maps
(define-map projects
  { project-id: uint }
  {
    title: (string-ascii 100),
    description: (string-ascii 500),
    creator: principal,
    target-amount: uint,
    current-funding: uint,
    created-at: uint,
    deadline: uint,
    status: (string-ascii 20),
    votes-for: uint,
    votes-against: uint,
    voting-deadline: uint
  }
)

(define-map contributors
  { contributor: principal, project-id: uint }
  { amount: uint, timestamp: uint }
)

(define-map user-contributions
  { contributor: principal }
  { total-contributed: uint, projects-supported: uint }
)

(define-map project-votes
  { voter: principal, project-id: uint }
  { vote: bool, timestamp: uint }
)

(define-map authorized-validators
  { validator: principal }
  { is-active: bool, projects-validated: uint }
)

;; Public Functions

;; Initialize contract with owner as first validator
(define-public (initialize)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
    (map-set authorized-validators 
      { validator: CONTRACT-OWNER }
      { is-active: true, projects-validated: u0 })
    (ok true)
  )
)

;; Add new biodiversity project
(define-public (create-project 
  (title (string-ascii 100))
  (description (string-ascii 500))
  (target-amount uint)
  (duration-days uint))
  (let (
    (project-id (+ (var-get project-counter) u1))
    (current-block-height block-height)
    (deadline (+ current-block-height (* duration-days u144))) ;; ~144 blocks per day
    (voting-deadline (+ current-block-height u1008)) ;; ~7 days for voting
  )
    (asserts! (> target-amount u0) ERR-INVALID-AMOUNT)
    (asserts! (> duration-days u0) ERR-INVALID-AMOUNT)
    
    (map-set projects
      { project-id: project-id }
      {
        title: title,
        description: description,
        creator: tx-sender,
        target-amount: target-amount,
        current-funding: u0,
        created-at: current-block-height,
        deadline: deadline,
        status: "voting",
        votes-for: u0,
        votes-against: u0,
        voting-deadline: voting-deadline
      }
    )
    
    (var-set project-counter project-id)
    (ok project-id)
  )
)

;; Vote on project (governance mechanism)
(define-public (vote-on-project (project-id uint) (vote-for bool))
  (let (
    (project (unwrap! (map-get? projects { project-id: project-id }) ERR-PROJECT-NOT-FOUND))
    (current-block block-height)
    (existing-vote (map-get? project-votes { voter: tx-sender, project-id: project-id }))
  )
    (asserts! (< current-block (get voting-deadline project)) ERR-VOTING-PERIOD-ENDED)
    (asserts! (is-none existing-vote) ERR-ALREADY-VOTED)
    (asserts! (is-eq (get status project) "voting") ERR-PROJECT-NOT-ACTIVE)
    
    ;; Record vote
    (map-set project-votes
      { voter: tx-sender, project-id: project-id }
      { vote: vote-for, timestamp: current-block }
    )
    
    ;; Update project vote counts
    (map-set projects
      { project-id: project-id }
      (merge project {
        votes-for: (if vote-for (+ (get votes-for project) u1) (get votes-for project)),
        votes-against: (if vote-for (get votes-against project) (+ (get votes-against project) u1))
      })
    )
    
    (ok true)
  )
)

;; Finalize project voting
(define-public (finalize-project-voting (project-id uint))
  (let (
    (project (unwrap! (map-get? projects { project-id: project-id }) ERR-PROJECT-NOT-FOUND))
    (current-block block-height)
    (total-votes (+ (get votes-for project) (get votes-against project)))
    (approval-rate (if (> total-votes u0) 
                     (/ (* (get votes-for project) u100) total-votes) 
                     u0))
  )
    (asserts! (>= current-block (get voting-deadline project)) ERR-VOTING-PERIOD-ENDED)
    (asserts! (is-eq (get status project) "voting") ERR-PROJECT-NOT-ACTIVE)
    
    (map-set projects
      { project-id: project-id }
      (merge project {
        status: (if (>= approval-rate (var-get governance-threshold)) "active" "rejected")
      })
    )
    
    (ok (>= approval-rate (var-get governance-threshold)))
  )
)

;; Contribute to approved project
(define-public (contribute-to-project (project-id uint) (amount uint))
  (let (
    (project (unwrap! (map-get? projects { project-id: project-id }) ERR-PROJECT-NOT-FOUND))
    (contributor-data (default-to 
                        { total-contributed: u0, projects-supported: u0 }
                        (map-get? user-contributions { contributor: tx-sender })))
  )
    (asserts! (>= amount MIN-CONTRIBUTION) ERR-MINIMUM-CONTRIBUTION)
    (asserts! (is-eq (get status project) "active") ERR-PROJECT-NOT-ACTIVE)
    (asserts! (< block-height (get deadline project)) ERR-PROJECT-NOT-ACTIVE)
    
    ;; Transfer STX from contributor to contract
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    
    ;; Update project funding
    (map-set projects
      { project-id: project-id }
      (merge project {
        current-funding: (+ (get current-funding project) amount)
      })
    )
    
    ;; Record contribution
    (map-set contributors
      { contributor: tx-sender, project-id: project-id }
      { amount: amount, timestamp: block-height }
    )
    
    ;; Update contributor stats
    (map-set user-contributions
      { contributor: tx-sender }
      {
        total-contributed: (+ (get total-contributed contributor-data) amount),
        projects-supported: (+ (get projects-supported contributor-data) u1)
      }
    )
    
    ;; Update total funds
    (var-set total-funds (+ (var-get total-funds) amount))
    
    (ok true)
  )
)

;; Withdraw funds (only project creator after successful funding)
(define-public (withdraw-project-funds (project-id uint))
  (let (
    (project (unwrap! (map-get? projects { project-id: project-id }) ERR-PROJECT-NOT-FOUND))
  )
    (asserts! (is-eq tx-sender (get creator project)) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status project) "active") ERR-PROJECT-NOT-ACTIVE)
    (asserts! (>= (get current-funding project) (get target-amount project)) ERR-INSUFFICIENT-FUNDS)
    
    ;; Transfer funds to project creator
    (try! (as-contract (stx-transfer? (get current-funding project) tx-sender (get creator project))))
    
    ;; Update project status
    (map-set projects
      { project-id: project-id }
      (merge project { status: "completed" })
    )
    
    (ok (get current-funding project))
  )
)

;; Add validator (owner only)
(define-public (add-validator (new-validator principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
    (map-set authorized-validators
      { validator: new-validator }
      { is-active: true, projects-validated: u0 }
    )
    (ok true)
  )
)

;; Read-only Functions

(define-read-only (get-project-details (project-id uint))
  (map-get? projects { project-id: project-id })
)

(define-read-only (get-contribution (contributor principal) (project-id uint))
  (map-get? contributors { contributor: contributor, project-id: project-id })
)

(define-read-only (get-user-stats (user principal))
  (map-get? user-contributions { contributor: user })
)

(define-read-only (get-total-funds)
  (var-get total-funds)
)

(define-read-only (get-project-count)
  (var-get project-counter)
)

(define-read-only (is-validator (validator principal))
  (default-to { is-active: false, projects-validated: u0 }
              (map-get? authorized-validators { validator: validator }))
)

(define-read-only (get-governance-threshold)
  (var-get governance-threshold)
)

;; Check if project funding goal is met
(define-read-only (is-funding-goal-met (project-id uint))
  (match (map-get? projects { project-id: project-id })
    project (>= (get current-funding project) (get target-amount project))
    false
  )
)

;; Get project funding percentage
(define-read-only (get-funding-percentage (project-id uint))
  (match (map-get? projects { project-id: project-id })
    project (if (> (get target-amount project) u0)
              (/ (* (get current-funding project) u100) (get target-amount project))
              u0)
    u0
  )
)