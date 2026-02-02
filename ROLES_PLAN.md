# Pending Tree Verification & Crowdsourced Confirmation: Implementation Phases

This document breaks down the implementation into clear, testable phases. Each phase can be developed and tested independently.

---

## Phase 1: Data Model & Constants

- [ ] Update Firestore `trees` documents:
  - Add `status` (`pending`, `approved`, `rejected`)
  - Add `upvotes` (array of user IDs)
  - Add `createdBy` (user ID)
- [ ] Add `roles` field to user documents (e.g., `{ roles: ['admin'] }`)
- [ ] Create `lib/constants.dart` for settings:
  - Required upvotes for approval (default: 3)

---

## Phase 2: Submission & Role Logic

- [ ] On tree submission:
  - If user is admin, set `status: approved`
  - Else, set `status: pending`, `createdBy`, and empty `upvotes`
- [ ] Prevent submitter from upvoting their own tree

---

## Phase 3: Upvoting & Auto-Approval

- [ ] Allow users (except submitter) to upvote pending trees (one upvote per user)
- [ ] When upvotes reach required number, auto-set `status: approved`
- [ ] Prevent duplicate upvotes

---

## Phase 4: Map Display & Filtering

- [ ] Show all trees on the main map by default
- [ ] Add UI filter to show only trees by `status` (e.g., only `approved`)
- [ ] Display status indicator for each tree

---

## Phase 5: Security Rules

- [ ] Update Firestore security rules:
  - Only allow upvotes from non-submitters
  - Prevent duplicate upvotes
  - Only allow status changes via upvote logic or admin submission

---

## Phase 6: Testing

- [ ] Unit and integration tests for:
  - Submission logic (admin vs. regular user)
  - Upvoting and status transitions
  - Filtering and display logic
  - Security rules

---

**Note:**  
- No admin UI for role assignment will be built.  
- No notifications for approval/rejection.  
- Admins’ trees are approved instantly.  
- Upvotes are the mechanism for approval.

---

Each phase can be merged independently after review and testing.