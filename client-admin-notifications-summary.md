# Client Admin Notifications Feature — Summary

> Client admin can push pop-up notifications to their tenants via the client-admin portal. Tenants see notifications as in-app pop-ups in the tenant app.

---

## What Gets Built

### Client Admin Portal (Frontend)

**New Page**: `Pages/Notifications` with two tabs:

1. **Send Tab** — Form to compose & send notifications
   - Select one or more tenants (multi-select with apartment info)
   - Enter title (5-100 chars) + message (10-300 chars)
   - Pick notification type: General, Maintenance, Payment, Urgent
   - Preview button
   - Send button
   - Success/error feedback

2. **History Tab** — Table of past notifications sent
   - Shows: Date, Tenants count, Title, Type, Status
   - Filter by type, date range
   - Search by title
   - Pagination

**New Components**:
- `TenantMultiSelect` — Multi-select filtered by client's tenants
- `NotificationTypeSelector` — 4 notification types
- `NotificationHistoryTable` — Paginated history table
- `NotificationPreview` — Modal showing pop-up preview

---

### Tenant App (Frontend)

**New Feature**: Pop-up notifications

When tenant logs in and has unread notifications:
1. App calls `GET /tenant/notifications?unreadOnly=true`
2. If unread notifications exist, shows **pop-up banner** at top
3. Displays: Title, Message, Type badge (with color)
4. User can dismiss or auto-dismisses after 5 seconds
5. Can tap to view full history in Notifications page

---

### Backend (Node.js + Express)

**New Endpoints**:

| Method | Route | Purpose | Who |
|--------|-------|---------|-----|
| POST | `/client-admin/notifications/send` | Send to tenants | Client Admin |
| GET | `/client-admin/notifications/history` | View past sends | Client Admin |
| GET | `/tenant/notifications` | Get tenant's notifications | Tenant |
| PATCH | `/tenant/notifications/:id/read` | Mark as read | Tenant |

**New Database Collection**: `notifications` (in each client's DB)

---

## Notification Types & Colors

| Type | Purpose | Color | Use Case |
|------|---------|-------|----------|
| **General** | Announcements, updates | Blue | New features, info |
| **Maintenance** | Maintenance schedules | Amber | Repairs, maintenance |
| **Payment** | Payment-related | Green | Rent reminders, dues |
| **Urgent** | Critical alerts | Red | Time-sensitive issues |

---

## Data Flow

```
Client Admin Portal
    ↓ [Form: select tenants, enter message]
    ↓ Click "Send"
    ↓
POST /client-admin/notifications/send
    ↓ [Backend validates client owns tenants]
    ↓
Insert notification in client's DB
    ├─ One record per tenant
    └─ Track: title, message, type, isRead
    ↓
Tenant App
    ↓ [Tenant logs in]
    ↓
GET /tenant/notifications?unreadOnly=true
    ↓
Show pop-up banner if unread exist
    ├─ Title + Message + Type badge
    └─ Dismiss button
    ↓
[Optional] Tenant taps → full history
```

---

## Key Implementation Points

### Frontend (Client Admin)

1. Create `/pages/notifications/` page with tabs
2. Build components: TenantMultiSelect, NotificationTypeSelector
3. Create form with validation
4. Add API service functions
5. Add Redux slice for state
6. Add route to sidebar

### Frontend (Tenant App)

1. On app launch/login, fetch unread notifications
2. If notifications exist, show pop-up banner component
3. Display title, message, type badge
4. Auto-dismiss after 5s or tap to dismiss
5. Tap → mark as read + go to Notifications page

### Backend

1. Create `notifications` collection schema in client DB
2. Add indexes: `tenantId, isRead, createdAt`
3. Implement 4 endpoints:
   - Send: validate client owns tenants → insert notifications
   - History: fetch notifications sent by this client
   - Get: fetch tenant's notifications (unread by default)
   - Read: mark notification as read
4. Add middleware: `isClientAdmin`, `getClientDB`
5. Add error handling for missing tenants

---

## Validation Rules

### Notification Content
- **Title**: 5-100 chars, no HTML
- **Message**: 10-300 chars, no HTML
- **Type**: Must be: general, maintenance, payment, urgent
- **TenantIds**: Non-empty array of valid UUID strings

### Authorization
- Client admin can only send to own tenants
- Tenant can only see their own notifications
- All endpoints require Bearer token

---

## Error Scenarios

| Scenario | Response |
|----------|----------|
| No tenants selected | Form validation error |
| Tenant not found | 404 error (tenant doesn't exist) |
| Tenant doesn't belong to client | 403 error (not authorized) |
| Already marked as read | 409 error (conflict) |
| Missing token | 401 error (unauthorized) |

---

## Testing Strategy

### Client Admin Send Flow
- [ ] Select single tenant → send succeeds
- [ ] Select multiple tenants → send succeeds
- [ ] Form validation on all fields
- [ ] Success toast appears
- [ ] History table updates
- [ ] Error handling (API fails)

### Tenant Pop-up Flow
- [ ] Tenant logs in with unread notifications
- [ ] Pop-up banner appears with message
- [ ] Auto-dismisses after 5s
- [ ] Tap dismiss → marked as read
- [ ] Tap title → goes to Notifications page
- [ ] History shows all notifications (read + unread)
- [ ] Can filter by type

### Backend Tests
- [ ] Send succeeds with valid input
- [ ] Send fails if tenant doesn't belong to client
- [ ] History endpoint returns paginated data
- [ ] Get notifications filters by tenantId
- [ ] Mark as read updates database

---

## Deployment Checklist

- [ ] Add `notifications` collection to client DB schema
- [ ] Create database indexes
- [ ] Deploy backend endpoints
- [ ] Deploy client-admin components
- [ ] Deploy tenant-app pop-up feature
- [ ] E2E test: client-admin sends → tenant receives pop-up
- [ ] Configure monitoring & error tracking

---

## Implementation Order (Recommended)

### Week 1: Backend
1. Create `notifications` collection schema
2. Implement send endpoint
3. Implement history endpoint
4. Unit test

### Week 2: Backend (continued)
1. Implement get notifications endpoint
2. Implement mark as read endpoint
3. Add validation & error handling
4. Integration testing

### Week 3: Client Admin Frontend
1. Build components
2. Create page & form
3. API integration
4. Testing

### Week 4: Tenant App Frontend
1. Add pop-up notification component
2. Fetch notifications on login
3. Mark as read functionality
4. E2E testing

---

## API Request Examples

### Send Notification

```bash
curl -X POST https://api.app.com/client-admin/notifications/send \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "tenantIds": ["tenant-uuid-1", "tenant-uuid-2"],
    "title": "Rent Payment Due",
    "message": "Please pay rent by 5th of month",
    "type": "payment"
  }'
```

### Get Tenant Notifications

```bash
curl -X GET "https://api.app.com/tenant/notifications?unreadOnly=true" \
  -H "Authorization: Bearer <token>"
```

### Mark as Read

```bash
curl -X PATCH https://api.app.com/tenant/notifications/notif-uuid/read \
  -H "Authorization: Bearer <token>"
```

---

## Related Documentation

- [Client Admin Implementation Guide](./client-admin-notifications-implementation.md)
- [Backend API Guide](./backend-tenant-notifications-api.md)
- [Tenant App Idea (existing)](./tenant-app/idea.md)
- [Implementation Requirements (main)](./implementation_requirements.md)

---

## Questions & Clarifications

**Q: Should notifications be stored in master DB or client DB?**
A: Client DB only. Each client sees their own notifications.

**Q: Can client-admin schedule notifications?**
A: Not in v1. Send immediately only.

**Q: Should tenants get email/SMS notifications?**
A: Not in v1. In-app pop-ups only. Add push notifications in v2.

**Q: Can client-admin see if tenant read the notification?**
A: Not in v1. Can add read receipts in v2.

**Q: Should notifications expire?**
A: Not automatic. Keep all notifications permanently (or archive after 90 days if needed).
