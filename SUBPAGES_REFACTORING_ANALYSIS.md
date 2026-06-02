# Tenant-Mobile Subpages API Refactoring Analysis

## Overview
Analysis of all tenant-mobile screens and subpages to identify API architectural issues similar to the dashboard/history/notifications refactoring.

---

## Current API Structure

### ✅ Already Refactored (Feature-Scoped)
| Endpoint | Method | Screen | Status |
|---|---|---|---|
| `/tenant-mobile/dashboard/current` | GET | dashboard_screen.dart | ✅ Optimized |
| `/tenant-mobile/history` | GET | history_screen.dart | ✅ Optimized |
| `/tenant-mobile/history/month/:month/:year` | GET | history_screen.dart (detail) | ✅ Optimized |
| `/tenant-mobile/notifications` | GET | notifications_screen.dart | ✅ Optimized |
| `/tenant-mobile/payment-proofs` | GET/POST | payment_proof_screen.dart, add_payment_proof_screen.dart | ✅ Optimized |
| `/tenant-mobile/payment-proofs/rent-detail` | GET | add_payment_proof_screen.dart | ✅ New (just added) |
| `/tenant-mobile/payment-proofs/:id` | GET | proof_detail_screen.dart | ✅ Optimized |
| `/tenant-mobile/maintenance-issues` | GET | report_issue_screen.dart, issue_history_screen.dart | ✅ Optimized |
| `/tenant-mobile/maintenance-issues/create` | POST | report_issue_screen.dart | ✅ Optimized |
| `/tenant-mobile/maintenance-issues/:issueId` | GET | issue_detail_by_id_screen.dart | ✅ Optimized |
| `/tenant-mobile/maintenance-issues/:issueId/images` | PUT | issue_detail_screen.dart | ✅ Optimized |
| `/tenant-mobile/app-version/current` | GET | settings_screen.dart | ✅ Optimized |
| `/auth/tenant-mobile` | POST | login_screen.dart | ✅ Auth-scoped |

### ⚠️ Still Monolithic (Portal Module)
| Endpoint | Method | Screen | Issue |
|---|---|---|---|
| `/tenant-mobile/profile` | GET | profile_screen.dart | Should be feature-scoped |
| `/tenant-mobile/documents` | GET | documents_screen.dart | Should be feature-scoped |
| `/tenant-mobile/flats` | GET | profile_screen.dart, dashboard_screen.dart | Should be feature-scoped |
| `/tenant-mobile/change-password` | POST | change_password_screen.dart | Should be feature-scoped (auth module) |
| `/tenant-mobile/fcm-token` | POST | enable_notifications_screen.dart | Should be feature-scoped (notifications module) |

### 🔴 Dead Code
| Function | Location | Status |
|---|---|---|
| `getTenantRentByMonthYear` | portal.service.js | Duplicate - moved to payment-proofs.service.js |

---

## Screens Needing Refactoring

### 1. Profile Screen (`profile_screen.dart`)
**Current Endpoint:** `GET /tenant-mobile/profile`
**Calling:** `repository.getProfile()`
**Issue:** Mixed with other endpoints in monolithic portal module
**Solution:** Create dedicated `profile` feature module

**Provider Usage:**
```dart
final asyncProfile = ref.watch(profileProvider);
```

**API Call:**
```dart
return _client.get<TenantProfile>(ApiPaths.profile, ...)
```

---

### 2. Documents Screen (`documents_screen.dart`)
**Current Endpoint:** `GET /tenant-mobile/documents`
**Calling:** `repository.getDocuments()`
**Issue:** Mixed with other endpoints in monolithic portal module
**Solution:** Create dedicated `documents` feature module

**Provider Usage:**
```dart
final asyncDocuments = ref.watch(documentsProvider);
```

**API Call:**
```dart
return _client.get<List<TenantDocument>>(ApiPaths.documents, ...)
```

---

### 3. Change Password Screen (`change_password_screen.dart`)
**Current Endpoint:** `POST /tenant-mobile/change-password`
**Calling:** `authProvider.notifier.changePassword()`
**Issue:** Scattered across portal + auth modules
**Solution:** Move to feature-scoped `auth` module (already exists)

**Provider Usage:**
```dart
final error = await ref.read(authProvider.notifier).changePassword(...)
```

**Current Backend:** portal.controller.js + portal.service.js
**Should Be:** auth.controller.js + auth.service.js

---

### 4. FCM Token Registration (`enable_notifications_screen.dart`)
**Current Endpoint:** `POST /tenant-mobile/fcm-token`
**Calling:** `authProvider.notifier.registerFcmToken()`
**Issue:** Scattered across portal + auth modules
**Solution:** Move to feature-scoped `notifications` module (already exists)

**Provider Usage:**
```dart
// Currently in auth provider, should be in notifications
await ref.read(authProvider.notifier).registerFcmToken(...)
```

**Current Backend:** portal.controller.js + portal.service.js
**Should Be:** notifications.controller.js + notifications.service.js

---

### 5. Flats Endpoint (`profile_screen.dart`, `dashboard_screen.dart`)
**Current Endpoint:** `GET /tenant-mobile/flats`
**Calling:** `repository.getTenantFlats()`
**Issue:** Mixed with other endpoints in monolithic portal module
**Solution:** Create dedicated `flats` feature module OR keep in profile module

**Provider Usage:** Used implicitly via authProvider for available flats
**Current Backend:** portal.controller.js + portal.service.js

---

## Summary of Changes Needed

### Backend (3 new modules + cleanup)

#### 1. Create `src/modules/tenant-mobile/profile/`
- `profile.controller.js` - Extract `tenantProfileController`
- `profile.service.js` - Extract `getTenantProfile()`
- `profile.validator.js` - Keep validators
- `profile.router.js` - Register `GET /profile` route
- **Delete from portal:** Remove getTenantProfile from portal.service.js

#### 2. Create `src/modules/tenant-mobile/documents/`
- `documents.controller.js` - Extract `tenantDocumentsController`
- `documents.service.js` - Extract `getTenantDocuments()`
- `documents.validator.js` - Keep validators
- `documents.router.js` - Register `GET /documents` route
- **Delete from portal:** Remove getTenantDocuments from portal.service.js

#### 3. Extend `src/modules/tenant-mobile/auth/`
- Move `changeTenantPassword()` from portal.service.js to auth.service.js
- Move `changeTenantPasswordController` from portal.controller.js to auth.controller.js
- Register `POST /change-password` route in auth.router.js
- **Delete from portal:** Remove changeTenantPassword from portal

#### 4. Extend `src/modules/tenant-mobile/notifications/`
- Move `registerTenantFcmToken()` from portal.service.js to notifications.service.js
- Move `registerTenantFcmTokenController` from portal.controller.js to notifications.controller.js
- Register `POST /fcm-token` route in notifications.router.js
- **Delete from portal:** Remove registerTenantFcmToken from portal

#### 5. Clean Up Portal Module
- Delete functions:
  - `getTenantProfile` (moved to profile.service.js)
  - `getTenantDocuments` (moved to documents.service.js)
  - `getTenantFlats` (keep - used by multiple features)
  - `changeTenantPassword` (moved to auth.service.js)
  - `registerTenantFcmToken` (moved to notifications.service.js)
  - `getTenantRentByMonthYear` (duplicate - in payment-proofs.service.js)
- Keep only: `getTenantFlats`
- Update portal router: Remove routes that moved, keep only `/flats`

#### 6. Update Main Router
Register new routes in `/src/modules/tenant-mobile/router.js`:
```js
router.use('/profile', profileRouter);
router.use('/documents', documentsRouter);
```

### Frontend
No changes needed - Flutter code already calls correct endpoints via ApiPaths constants.
Just verify endpoints match new structure (they should).

---

## Implementation Order

1. **Cleanup (lowest risk):**
   - Remove duplicate `getTenantRentByMonthYear` from portal.service.js
   - Remove stale controllers from portal.controller.js

2. **Create new feature modules:**
   - Create profile module (simplest - single function)
   - Create documents module (simplest - single function)

3. **Extend existing modules:**
   - Add changePassword to auth module
   - Add registerFcmToken to notifications module

4. **Update portal module:**
   - Remove all functions that moved
   - Keep getTenantFlats

5. **Update main router:**
   - Register new routes

6. **Validation:**
   - Build backend (npm run build)
   - Test endpoints via curl/Postman

---

## Benefits

1. **Separation of Concerns:** Each screen has dedicated API endpoint
2. **Reduced Payload:** Each endpoint returns only needed data
3. **Better Caching:** Providers can cache independently
4. **Easier Testing:** Feature-specific endpoints easier to test
5. **Future Extensibility:** Adding new profile/document fields won't bloat other endpoints
6. **Clear Ownership:** Clear which module owns which data

---

## Zero-Downtime Migration Strategy

Since Flutter apps are already using `/tenant-mobile/profile`, `/tenant-mobile/documents`, etc. directly:

1. **Phase 1 (Parallel):**
   - Create new feature modules alongside portal module
   - Register both old (portal) and new (feature) routes temporarily
   - Monitor to ensure new routes work

2. **Phase 2 (Cleanup):**
   - Once verified, remove old routes from portal
   - Update portal router to only export `/flats`

No client-side changes needed since endpoints remain the same path.

---

## Files to Create/Modify

### Create (8 files)
- `backend/src/modules/tenant-mobile/profile/profile.controller.js`
- `backend/src/modules/tenant-mobile/profile/profile.service.js`
- `backend/src/modules/tenant-mobile/profile/profile.validator.js`
- `backend/src/modules/tenant-mobile/profile/profile.router.js`
- `backend/src/modules/tenant-mobile/documents/documents.controller.js`
- `backend/src/modules/tenant-mobile/documents/documents.service.js`
- `backend/src/modules/tenant-mobile/documents/documents.validator.js`
- `backend/src/modules/tenant-mobile/documents/documents.router.js`

### Modify (6 files)
- `backend/src/modules/tenant-mobile/auth/auth.service.js` - Add changePassword
- `backend/src/modules/tenant-mobile/auth/auth.controller.js` - Add changePasswordController
- `backend/src/modules/tenant-mobile/auth/auth.router.js` - Add /change-password route
- `backend/src/modules/tenant-mobile/notifications/notifications.service.js` - Add registerFcmToken
- `backend/src/modules/tenant-mobile/notifications/notifications.controller.js` - Add registerFcmTokenController
- `backend/src/modules/tenant-mobile/notifications/notifications.router.js` - Add /fcm-token route
- `backend/src/modules/tenant-mobile/portal/portal.service.js` - Remove moved functions & duplicate
- `backend/src/modules/tenant-mobile/portal/portal.controller.js` - Remove moved functions
- `backend/src/modules/tenant-mobile/portal/portal.router.js` - Remove moved routes, keep /flats
- `backend/src/modules/tenant-mobile/router.js` - Register new routes

---

## Testing Checklist

- [ ] Backend builds with `npm run build`
- [ ] All 312 imports valid
- [ ] Test `/tenant-mobile/profile` returns 200
- [ ] Test `/tenant-mobile/documents` returns 200
- [ ] Test `POST /tenant-mobile/change-password` returns 200
- [ ] Test `POST /tenant-mobile/fcm-token` returns 200
- [ ] Flutter app works with existing endpoint paths (should be no-op)
- [ ] Verify profile data in settings screen loads
- [ ] Verify documents screen loads
- [ ] Verify password change works
- [ ] Verify FCM token registration works
