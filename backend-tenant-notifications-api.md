# Backend Tenant Notifications API — Implementation Guide

> Backend service for managing notifications sent by client-admin to tenants.

---

## Overview

### Responsibilities

1. **Receive** notification requests from client-admin portal
2. **Validate** client owns the selected tenants
3. **Store** notification in client's MongoDB
4. **Serve** notifications to tenant app
5. **Track** read status

---

## Architecture

### Data Flow

```
Client Admin Portal
    ↓ POST /client-admin/notifications/send
Backend
    ├─ Authenticate client-admin
    ├─ Validate: client owns these tenants
    ├─ Get client's DB connection
    ├─ Insert notification for each tenant
    └─ Return response
    ↓
Client's MongoDB
    └─ notifications collection
    ↓
Tenant App
    ├─ Logs in
    ├─ GET /tenant/notifications?unreadOnly=true
    ├─ Receives unread notifications
    └─ Displays pop-up toast
```

---

## Database Schema

### Each Client's DB: `notifications` Collection

```typescript
interface TenantNotification {
  _id: ObjectId;
  tenantId: string; // which tenant received it
  tenantName: string; // denormalized for search
  title: string;
  message: string;
  type: 'general' | 'maintenance' | 'payment' | 'urgent';
  isRead: boolean;
  readAt?: Date;
  readBy?: string; // tenant user ID who read it
  createdAt: Date;
  createdBy: string; // client-admin user ID who sent it
  clientCode: string; // redundant, for logging
}

// Indexes:
// - tenantId, isRead, createdAt (composite for queries)
// - createdAt (for sorting)
// - type (for filtering)
```

---

## API Endpoints

### 1. Send Notification (Client Admin Only)

**Route**: `POST /client-admin/notifications/send`

**Middleware**:
- `authenticate` — Verify JWT
- `isClientAdmin` — Check role
- `validateRequest` — Validate schema

**Request Body**:
```json
{
  "tenantIds": ["tenant-id-1", "tenant-id-2"],
  "title": "Rent Due Reminder",
  "message": "Please pay rent by 5th of month",
  "type": "payment"
}
```

**Response (200)**:
```json
{
  "success": true,
  "notificationId": "notif-uuid-12345",
  "sentCount": 2,
  "createdAt": "2026-04-15T10:30:00Z"
}
```

**Error Cases**:
- `400` — Invalid schema
- `401` — Not authenticated
- `403` — Not a client-admin
- `404` — One or more tenants not found (or don't belong to this client)
- `500` — Database error

---

### 2. Get Notification History (Client Admin)

**Route**: `GET /client-admin/notifications/history`

**Query Params**:
```
skip=0&limit=20&type=payment&search=rent
```

**Response (200)**:
```json
{
  "success": true,
  "data": [
    {
      "id": "notif-uuid-12345",
      "title": "Rent Due Reminder",
      "message": "Please pay rent by 5th...",
      "type": "payment",
      "sentTo": { "count": 2 },
      "createdAt": "2026-04-15T10:30:00Z"
    }
  ],
  "pagination": {
    "total": 25,
    "skip": 0,
    "limit": 20,
    "page": 1
  }
}
```

---

### 3. Get Notifications (Tenant App)

**Route**: `GET /tenant/notifications`

**Query Params**:
```
skip=0&limit=10&unreadOnly=true
```

**Response (200)**:
```json
{
  "success": true,
  "data": [
    {
      "id": "notif-uuid-12345",
      "title": "Rent Due Reminder",
      "message": "Please pay rent by 5th...",
      "type": "payment",
      "isRead": false,
      "createdAt": "2026-04-15T10:30:00Z"
    }
  ],
  "unreadCount": 1
}
```

---

### 4. Mark Notification as Read (Tenant)

**Route**: `PATCH /tenant/notifications/:id/read`

**Response (200)**:
```json
{
  "success": true,
  "isRead": true,
  "readAt": "2026-04-15T10:35:00Z"
}
```

**Error Cases**:
- `401` — Not authenticated
- `404` — Notification not found
- `403` — Tenant cannot read this notification (not theirs)
- `500` — Database error

---

## Validation Schemas

**SendNotificationPayload**:
```typescript
type NotificationType = 'general' | 'maintenance' | 'payment' | 'urgent';

interface SendNotificationPayload {
  tenantIds: string[]; // non-empty array, valid UUIDs
  title: string; // 5-100 chars
  message: string; // 10-300 chars
  type: NotificationType;
}

// Zod schema
const schema = z.object({
  tenantIds: z.array(z.string().uuid()).min(1, 'Select at least one tenant'),
  title: z.string().min(5).max(100).trim(),
  message: z.string().min(10).max(300).trim(),
  type: z.enum(['general', 'maintenance', 'payment', 'urgent']),
});
```

---

## Business Logic

### 1. Send Notification

**Pseudocode**:
```
function sendNotification(payload, clientCode, clientAdminId) {
  // Validate schema
  validate(payload)
  
  // Get client's DB connection
  clientDB = getTenantConnection(clientCode)
  
  // Get tenants from client DB
  tenants = clientDB.collection('tenants')
    .find({ _id: { $in: payload.tenantIds } })
  
  // Verify all tenants exist
  if tenants.length !== payload.tenantIds.length:
    throw 404: "Some tenants not found"
  
  notificationId = generateUUID()
  now = new Date()
  
  // Insert notification for each tenant
  notifications = payload.tenantIds.map(tenantId => ({
    tenantId,
    tenantName: tenants.find(t => t._id === tenantId).name,
    title: payload.title,
    message: payload.message,
    type: payload.type,
    isRead: false,
    createdAt: now,
    createdBy: clientAdminId,
    clientCode
  }))
  
  clientDB.collection('notifications').insertMany(notifications)
  
  return {
    success: true,
    notificationId,
    sentCount: notifications.length,
    createdAt: now
  }
}
```

---

### 2. Get Notifications (Tenant)

**Pseudocode**:
```
function getTenantNotifications(clientDB, tenantId, skip, limit, unreadOnly) {
  query = { tenantId }
  
  if unreadOnly:
    query.isRead = false
  
  notifications = clientDB
    .collection('notifications')
    .find(query)
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(limit)
    .toArray()
  
  total = clientDB
    .collection('notifications')
    .countDocuments(query)
  
  unreadCount = clientDB
    .collection('notifications')
    .countDocuments({ tenantId, isRead: false })
  
  return {
    data: notifications,
    unreadCount,
    total
  }
}
```

---

### 3. Mark as Read

**Pseudocode**:
```
function markAsRead(clientDB, notificationId, tenantId) {
  notif = clientDB
    .collection('notifications')
    .findOne({ _id: notificationId })
  
  if !notif:
    throw 404: "Notification not found"
  
  // Verify tenant owns this notification
  if notif.tenantId !== tenantId:
    throw 403: "Cannot read this notification"
  
  if notif.isRead:
    throw 409: "Already read"
  
  clientDB
    .collection('notifications')
    .updateOne(
      { _id: notificationId },
      { $set: { isRead: true, readAt: now(), readBy: tenantId } }
    )
  
  return { success: true, isRead: true }
}
```

---

## Middleware

### 1. `authenticate`

Verify JWT token from Authorization header.

```typescript
function authenticate(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Missing token' });
  
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded; // { id, email, role, clientCode, tenantId? }
    next();
  } catch {
    res.status(401).json({ error: 'Invalid token' });
  }
}
```

### 2. `isClientAdmin`

Check that user has client-admin role.

```typescript
function isClientAdmin(req, res, next) {
  if (req.user.role !== 'client-admin') {
    return res.status(403).json({ error: 'Client admin access required' });
  }
  next();
}
```

### 3. `getClientDB`

Get client's MongoDB connection (for `/client-admin/*` and `/tenant/*` routes).

```typescript
async function getClientDB(req, res, next) {
  const clientCode = req.user.clientCode;
  try {
    req.clientDB = await getTenantConnection(clientCode);
    next();
  } catch (error) {
    res.status(500).json({ error: 'Failed to connect to client database' });
  }
}
```

---

## Error Handling

### Error Response Format

```json
{
  "success": false,
  "error": "Descriptive error message",
  "code": "ERROR_CODE",
  "details": {}
}
```

### HTTP Status Codes

| Code | Scenario |
|------|----------|
| 200 | Success |
| 400 | Validation error |
| 401 | Not authenticated |
| 403 | Not authorized (wrong role) |
| 404 | Resource not found |
| 409 | Conflict (already read) |
| 500 | Server error |

---

## Implementation Checklist

### Phase 1: Database & Middleware

- [ ] Add `notifications` collection to client DB schema
- [ ] Create indexes: tenantId, isRead, createdAt
- [ ] Implement `authenticate` middleware
- [ ] Implement `isClientAdmin` middleware
- [ ] Implement `getClientDB` middleware

---

### Phase 2: API Endpoints

- [ ] `POST /client-admin/notifications/send`
  - [ ] Validate schema
  - [ ] Get tenants from client DB
  - [ ] Check tenants exist
  - [ ] Insert notifications
  - [ ] Return response
  
- [ ] `GET /client-admin/notifications/history`
  - [ ] Query notifications collection
  - [ ] Support filtering & pagination
  - [ ] Return results

- [ ] `GET /tenant/notifications`
  - [ ] Filter by tenantId
  - [ ] Support unreadOnly param
  - [ ] Return with unreadCount

- [ ] `PATCH /tenant/notifications/:id/read`
  - [ ] Validate notification exists
  - [ ] Verify tenant owns it
  - [ ] Update isRead flag
  - [ ] Return response

---

### Phase 3: Testing

- [ ] Unit tests for send logic
- [ ] Unit tests for mark as read
- [ ] Integration test: send → receive → read
- [ ] Test tenant can't read others' notifications
- [ ] Test client-admin can't send to other's tenants
- [ ] Test error cases (invalid schema, missing tenant, etc.)

---

### Phase 4: Deployment

- [ ] Deploy migrations
- [ ] Deploy API endpoints
- [ ] Test in staging
- [ ] Monitor logs
- [ ] Deploy to production

---

## Security Considerations

- **Authorization**: Always verify client-admin owns the tenants they're sending to
- **Data Isolation**: Tenants can only see their own notifications
- **Input Sanitization**: No HTML in title/message (strip tags)
- **Rate Limiting**: Limit sends per client-admin (e.g., 100/hour)
- **Audit**: Log who sent what notification and when

---

## Performance Considerations

- Use indexes on `tenantId, isRead, createdAt` for quick queries
- Batch inserts when sending to multiple tenants
- Limit pagination (max 50 per request)
- Consider archiving old notifications after 90 days
