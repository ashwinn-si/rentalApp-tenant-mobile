# Tenant Mobile — Maintenance Feature Handoff

**Date:** 2026-06-02  
**Focus Area:** Maintenance issue display + rent deduction clarity  
**Status:** Planning phase → Implementation ready

---

## Problem Statement

Maintenance issue resolution display is incomplete and confusing for tenants:

1. **Resolution type not explicit** — 4 distinct resolution paths exist in backend (refund, admin cost, combined, status-only), but UI shows no clear type label
2. **Rent deduction amounts unclear** — Same amount shown for all resolutions, no distinction between deduction types (refund vs. adjustment)
3. **Card display half-cooked** — Compact list card only shows resolution snippets, not full context
4. **Detail screen inconsistency** — Detail screen skips refund data (only checks adjustment + admin cost), so refund-resolved issues show no banner
5. **No timeline clarity** — Issue creation → admin review → resolution path not visually tracked with actual timestamps

**Goal:** Make each maintenance card display full context: issue raised → admin decision → exact financial impact with clear type labels.

---

## Current Architecture

### Frontend (Flutter)

**Model:** `MaintenanceIssue`  
Location: `lib/features/maintenance_issues/data/models/maintenance_issue.dart`

Key fields:
- `status`: `submitted` | `under_review` | `resolved` | `rejected`
- `tenantRepairCost`: Tenant's cost estimate (informational only)
- `adminRepairCost`: Amount admin deducts from rent
- `refundDetails`: `{ refundedAmount, refundMonth, refundYear }` (explicit refund)
- `adjustmentDetails`: `{ amount, adjustmentMonth, adjustmentYear, addToMaintenance }` (cost added to rent)
- `adminComments`: Admin's response text
- `images`, `category`, `title`, `description`, `scope` (apartment or flat), `createdAt`

**Screens:**
- `screens/issue_history_screen.dart` — list of all issues (uses `maintenance_issue_card.dart`)
- `screens/issue_detail_screen.dart` — full detail view
- `screens/report_issue_screen.dart` — new issue form

**Widgets:**
- `screens/widgets/maintenance_issue_card.dart` — compact card in list (shows resolution snippet only)
- `screens/widgets/issue_timeline.dart` — status timeline (hardcoded placeholders, no real timestamps)
- `widgets/domain/maintenance_detail_widget.dart` — rent history breakdown (used in tenant payments)

**Repository:** `data/maintenance_repository.dart` (API calls)  
**Provider:** `providers/maintenance_provider.dart` (state management)

### Backend (Node.js)

**Core Logic:** `src/utils/maintenanceHelpers.js`  
**Endpoints:**
- Tenant: `GET /api/tenant/maintenance-issues/` | `GET /:issueId` | `POST /create` | `PUT /:issueId/images`
- Client-Admin: `GET /api/admin/maintenance-issues/` | `POST /create` | `POST /admin-create` | `PATCH /:issueId/status` | `POST /:issueId/approve-refund` | `POST /:issueId/approve-admin-cost` | `POST /:issueId/approve-refund-and-adjustment` | `POST /:issueId/reject` | `POST /:issueId/revert`

**Resolution Paths (4 types):**

| Type | Endpoint | Rent Effect | Model Fields |
|------|----------|------------|--------------|
| Refund (reimbursement) | `POST /:issueId/approve-refund` | Subtract from `totalDue` | `refundDetails.refundedAmount` |
| Admin Cost (adjustment) | `POST /:issueId/approve-admin-cost` | Add to `totalDue` | `adjustmentDetails.amount` |
| Refund + Adjustment | `POST /:issueId/approve-refund-and-adjustment` | Both applied | Both fields set |
| Status-only | `PATCH /:issueId/status` | No rent effect | Neither field set |

---

## Bugs Found

### Bug #1: Detail Screen Skips Refund Data
**File:** `screens/issue_detail_screen.dart`, lines 152–163  
**Issue:** Only checks `adjustmentDetails` and `adminRepairCost` for resolution banner — ignores `refundDetails`  
**Impact:** Refund-resolved issues show no banner on detail screen (card widget displays correctly)  
**Fix:** Add `refundDetails` check in banner logic

### Bug #2: Card Widget Uses Inconsistent Month Format
**File:** `screens/widgets/maintenance_issue_card.dart` vs `screens/issue_detail_screen.dart`  
**Issue:** Card uses abbreviated month names (`Jan`, `Feb`), detail screen uses full (`January`, `February`)  
**Fix:** Standardize to one format

### Bug #3: Timeline Hardcoded, No Real Timestamps
**File:** `screens/widgets/issue_timeline.dart`  
**Issue:** Shows placeholder text (`"Assigned to admin"`, `"Work completed"`) — backend doesn't store `under_review` or `resolved` timestamps  
**Impact:** Timeline is cosmetic, not informative  
**Fix:** Backend needs to add `reviewedAt` and `resolvedAt` timestamps; Flutter displays them

### Bug #4: No Resolution Type Enum or Label
**Issue:** 4 distinct resolution paths but no explicit type field in schema or enum constant  
**Impact:** UI cannot cleanly distinguish "This is a refund" vs. "This is an adjustment"  
**Fix:** Add explicit `resolutionType` field to schema: `refund` | `adjustment` | `refund_and_adjustment` | `status_only`

---

## What Needs to Be Done

### Phase 1: Data Model (Backend)

1. **Add `resolutionType` field** to `maintenanceIssue` schema  
   - Enum: `refund` | `adjustment` | `refund_and_adjustment` | `status_only`  
   - Set when issue resolved via any approval endpoint  
   - Default: `status_only` (for status-only updates)

2. **Add timestamp fields** to `maintenanceIssue` schema  
   - `reviewedAt`: Date (set when admin moves to `under_review`)  
   - `resolvedAt`: Date (set when admin resolves/rejects)

3. **Update `maintenanceHelpers.js`** to set `resolutionType` in all approval functions

4. **Update all approval endpoints** to set timestamps

### Phase 2: Frontend — Card Widget

**File:** `lib/features/maintenance_issues/screens/widgets/maintenance_issue_card.dart`

Current: Shows only resolution snippet + tenant payment  
Needed:
- **Header section:** `[Status Badge]` `[Category Badge]` `[IssueId]`
- **Issue summary:** Title (1 line, truncated) + brief description (1 line, truncated)
- **Admin response:** If `adminComments` exists, show truncated (2 lines max) with "See more" indicator
- **Resolution type badge:** Only when `status == resolved`
  - Green badge: `[Resolution Type Icon] [Type Label] ₹[Amount] from [Month YYYY]`
  - Show `refundDetails` OR `adjustmentDetails` OR both (based on `resolutionType`)
- **Tenant payment:** Show only if `tenantRepairCost > 0`
- **Timeline:** Collapsed timestamp row (created date + resolved date if available)

### Phase 3: Frontend — Detail Screen

**File:** `lib/features/maintenance_issues/screens/issue_detail_screen.dart`

Current: Full details + resolution banner  
Needed:
- **Full issue context** at top:
  - Title, description, category, scope
  - All images (carousel)
  - Created date + time
- **Tenant's submission** section:
  - Estimated repair cost (`tenantRepairCost`)
- **Admin response** section:
  - Status timeline with real timestamps (`reviewedAt`, `resolvedAt`)
  - Admin comments (full text, no truncation)
- **Resolution details** section (only when `status == resolved`):
  - Clear type label: "**Refund Applied**" | "**Maintenance Charge Applied**" | "**Refund + Charge Applied**"
  - Amount breakdown:
    - If refund: `"₹X refunded to [Month YYYY] rent"`
    - If adjustment: `"₹X added to [Month YYYY] rent [via maintenance]"`
    - If both: Show both clearly
- **Fix existing bug:** Add `refundDetails` check to banner logic

### Phase 4: Frontend — Timeline Widget

**File:** `lib/features/maintenance_issues/screens/widgets/issue_timeline.dart`

Current: Hardcoded placeholder timestamps  
Needed:
- Update to use real `createdAt`, `reviewedAt`, `resolvedAt` from model
- Show actual dates/times (not placeholder text)
- Status order: `submitted` → `under_review` → `resolved/rejected`

---

## File Changes Summary

### Backend

- `src/models/tenant/maintenanceIssue.model.js` — Add `resolutionType`, `reviewedAt`, `resolvedAt`
- `src/utils/maintenanceHelpers.js` — Set `resolutionType` and timestamps in all approval functions
- `src/modules/client-admin/maintenance/maintenance.service.js` — Update all approval endpoints

### Frontend (Flutter)

- `lib/features/maintenance_issues/data/models/maintenance_issue.dart` — Add `resolutionType`, `reviewedAt`, `resolvedAt` (deserialize from API)
- `lib/features/maintenance_issues/screens/widgets/maintenance_issue_card.dart` — Redesign: add header, issue summary, admin response snippet, resolution badge, timeline
- `lib/features/maintenance_issues/screens/issue_detail_screen.dart` — Add full context sections, fix refund data bug, use real timestamps
- `lib/features/maintenance_issues/screens/widgets/issue_timeline.dart` — Replace hardcoded placeholders with real timestamps

---

## Testing Checklist

- [ ] Create issue → status `submitted` → timeline shows creation date
- [ ] Move to `under_review` → `reviewedAt` timestamp appears in timeline
- [ ] Resolve with **refund only** → shows correct amount, month, type label
- [ ] Resolve with **admin cost only** → shows correct amount, month, type label  
- [ ] Resolve with **both** → shows both clearly separated
- [ ] Resolve with **status-only** (no rent effect) → no amount shown
- [ ] Card widget displays all sections correctly (header, issue, admin response, resolution, timeline)
- [ ] Detail screen shows full context without truncation
- [ ] Refund data displays in both card AND detail screen
- [ ] Month format consistent across card and detail (pick one format)
- [ ] Timeline shows actual timestamps (not placeholders)

---

## Implementation Order

1. **Backend first** (add schema fields + set them in approval functions)
2. **Model** (update Flutter model to deserialize new fields)
3. **Card widget** (redesign for full context)
4. **Detail screen** (add sections + fix refund bug + use real data)
5. **Timeline widget** (replace hardcoded placeholders)
6. **Test end-to-end** (create issues → resolve with all 4 types → verify display)

---

## Notes

- No TODO/FIXME comments exist in current code — make sure to document any workarounds you add
- `services/` directory under `maintenance_issues/` is empty; business logic lives in repository
- `MaintenanceTemplate` adjustment path (`addToMaintenance=true`) spreads cost equally across apartment flats — keep working as-is, just display clearly
- Rent history widget (`maintenance_detail_widget.dart`) uses separate `MaintenanceBreakdownItem` model — does not consume `MaintenanceIssue` directly (no changes needed there)

