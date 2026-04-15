# Client Admin Notifications Implementation Guide

> Feature: Client admin can push pop-up notifications to their tenants via the client-admin portal.

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Frontend Components](#frontend-components)
4. [Page: Send Notifications](#page-send-notifications)
5. [API Integration](#api-integration)
6. [State Management](#state-management)
7. [UI/UX Flow](#uiux-flow)
8. [Database Schema](#database-schema)
9. [Testing Checklist](#testing-checklist)

---

## Overview

### What Users Can Do

**Client Admin**:
- Select one or more tenants from their properties
- Enter notification title and message
- Select notification type (General, Maintenance, Payment, Urgent)
- Send notification immediately
- View notification delivery history

**Tenants** (via tenant app):
- Receive **pop-up notification** when logged in
- See notification content in banner/toast
- Mark as read
- View in notifications history

### Notification Types

| Type | Color | Use Case |
|------|-------|----------|
| **General** | Blue | Updates, announcements |
| **Maintenance** | Amber | Maintenance schedules |
| **Payment** | Green | Payment reminders |
| **Urgent** | Red | Critical alerts |

---

## Architecture

### High-Level Flow

```
Client Admin Portal (React)
    ↓
[Send Notification Form]
    ↓
POST /client-admin/notifications/send
    ↓
Backend (Node + Express)
    ├─ Validate: client owns these tenants
    ├─ Create Notification record
    ├─ Store in that client's DB
    └─ Return success
    ↓
Tenant App (React Native / Web)
    ├─ User logs in
    ├─ GET /tenant/notifications (unread only)
    ├─ Display pop-up banner/toast
    └─ Auto-dismiss or tap to dismiss
```

### System Boundaries

- **Client Admin**: Owns sending interface, can only send to own tenants
- **Tenant Portal**: Displays pop-up notifications
- **Backend**: Stores and serves notifications

---

## Frontend Components

### 1. **TenantMultiSelect** (New)

**Location**: `client-admin/src/components/form/TenantMultiSelect.tsx`

- Filter by tenant name, apartment, status
- Search debounced
- Show selected count
- Show tenant apartment/flat info

```tsx
interface TenantMultiSelectProps {
  value: string[]; // tenant IDs
  onChange: (tenantIds: string[]) => void;
  clientId: string; // to fetch own tenants only
}
```

---

### 2. **NotificationTypeSelector** (New)

**Location**: `client-admin/src/components/form/NotificationTypeSelector.tsx`

Radio/dropdown with 4 notification types.

```tsx
type NotificationType = 'general' | 'maintenance' | 'payment' | 'urgent';
```

---

### 3. **NotificationHistoryTable** (New)

**Location**: `client-admin/src/components/notifications/NotificationHistoryTable.tsx`

Data table showing sent notifications.

**Columns**:
- Sent Date/Time
- Tenants count
- Title
- Type (badge)
- Status (Sent / Pending)

**Features**:
- Pagination
- Filter by type, date
- Search by title
- Sort by date (desc)

---

### 4. **NotificationPreview** (New)

**Location**: `client-admin/src/components/notifications/NotificationPreview.tsx`

Modal showing how pop-up will appear to tenant.

---

## Page: Send Notifications

**Location**: `client-admin/src/pages/notifications/sendNotification.tsx`

### Layout

```
┌─────────────────────────────────────┐
│ Send Notification to Tenants        │
├─────────────────────────────────────┤
│                                     │
│  [Step 1] Select Recipients         │
│  ├─ TenantMultiSelect               │
│  │  (show: apartment, tenant name)  │
│  └─ "X tenants selected"            │
│                                     │
│  [Step 2] Notification Details      │
│  ├─ Title (input, max 100 chars)    │
│  ├─ Message (textarea, max 300)     │
│  └─ Type (NotificationTypeSelector) │
│                                     │
│  [Step 3] Review & Send             │
│  ├─ NotificationPreview (read-only) │
│  └─ [Preview] [Send] buttons        │
│                                     │
└─────────────────────────────────────┘
```

### Form Structure

```typescript
interface SendNotificationForm {
  tenantIds: string[]; // non-empty array
  title: string; // 5-100 chars
  message: string; // 10-300 chars
  type: 'general' | 'maintenance' | 'payment' | 'urgent';
}

const sendNotificationSchema = z.object({
  tenantIds: z.array(z.string()).min(1, 'Select at least one tenant'),
  title: z.string().min(5).max(100),
  message: z.string().min(10).max(300),
  type: z.enum(['general', 'maintenance', 'payment', 'urgent']),
});
```

### Form Behavior

1. **Step 1**: Select tenants from your properties
2. **Step 2**: Fill title, message, type
3. **Step 3**: Preview + confirm

---

## API Integration

### Endpoint: Send Notification

**Endpoint**: `POST /client-admin/notifications/send`

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
  "notificationId": "notif-123-uuid",
  "sentCount": 2,
  "createdAt": "2026-04-15T10:30:00Z"
}
```

---

### Endpoint: Get Notification History

**Endpoint**: `GET /client-admin/notifications/history`

**Query Params**:
- `skip`, `limit`, `type`, `startDate`, `endDate`, `search`

**Response**:
```json
{
  "data": [
    {
      "id": "notif-123",
      "title": "Rent Due Reminder",
      "message": "...",
      "type": "payment",
      "sentTo": { "count": 2 },
      "createdAt": "2026-04-15T10:30:00Z"
    }
  ],
  "total": 15,
  "page": 1
}
```

---

### Endpoint: Get Notifications (Tenant App)

**Endpoint**: `GET /tenant/notifications`

**Query Params**:
- `unreadOnly`: true (pop-ups show unread only)

**Response**:
```json
{
  "data": [
    {
      "id": "notif-123",
      "title": "Rent Due Reminder",
      "message": "...",
      "type": "payment",
      "isRead": false,
      "createdAt": "2026-04-15T10:30:00Z"
    }
  ]
}
```

---

### Endpoint: Mark as Read (Tenant)

**Endpoint**: `PATCH /tenant/notifications/:id/read`

**Response**:
```json
{
  "success": true,
  "isRead": true
}
```

---

## State Management

### Redux Slice: notificationsSlice (Client Admin)

**Location**: `client-admin/src/store/slices/notificationsSlice.ts`

```typescript
interface NotificationsState {
  history: Notification[];
  total: number;
  loading: boolean;
  error: string | null;
  filters: {
    type?: string;
    startDate?: string;
  };
}

// Actions:
// - fetchNotificationHistory(page, filters)
// - sendNotification(payload)
// - setFilters(filters)
```

---

## UI/UX Flow

### Client Admin: Send Flow

```
Client Admin Portal
    ↓
Sidebar → "Notifications" (NEW)
    ↓
Notifications Hub
├─ Tab 1: "Send"
│   ├─ Select tenants
│   ├─ Enter title, message, type
│   ├─ Preview
│   └─ Send
│
└─ Tab 2: "History"
    ├─ View past sends
    └─ Filter & search
```

### Tenant App: Pop-up Display

```
Tenant logs in
    ↓
App checks: GET /tenant/notifications?unreadOnly=true
    ↓
If unread notifications exist:
    ├─ Show pop-up banner at top of screen
    ├─ Title + Message + Type badge
    ├─ [Dismiss] button
    └─ Auto-dismiss after 5 seconds OR tap to dismiss
```

---

## Database Schema

### Each Client's DB: `notifications` Collection

```typescript
interface TenantNotification {
  _id: ObjectId;
  tenantId: string; // which tenant received it
  title: string;
  message: string;
  type: 'general' | 'maintenance' | 'payment' | 'urgent';
  isRead: boolean;
  readAt?: Date;
  createdAt: Date;
  createdBy: string; // client-admin user ID
}

// Indexes:
// - tenantId, isRead, createdAt (for quick queries)
// - createdAt (for listing)
```

---

## Testing Checklist

### Component Tests
- [ ] TenantMultiSelect filters by apartment
- [ ] NotificationTypeSelector shows 4 types
- [ ] Form validates required fields
- [ ] Character count updates
- [ ] Preview shows correct styling

### Integration Tests
- [ ] Send to single tenant succeeds
- [ ] Send to multiple tenants succeeds
- [ ] Form resets after send
- [ ] History table updates
- [ ] Filter & search work

### API Tests
- [ ] POST /client-admin/notifications/send validates client owns tenants
- [ ] GET /client-admin/notifications/history returns paginated data
- [ ] GET /tenant/notifications returns unread only
- [ ] PATCH /tenant/notifications/:id/read marks as read

### E2E Tests
- [ ] Client admin logs in
- [ ] Navigates to Notifications
- [ ] Selects 2 tenants
- [ ] Fills form and sends
- [ ] Success toast appears
- [ ] Tenant logs in → sees pop-up
- [ ] Tenant taps dismiss → notification marked read

---

## Future Enhancements

1. **Bulk Send**: Send to all tenants with one click
2. **Scheduling**: Schedule notification for specific time
3. **Templates**: Pre-built notification templates
4. **Rich Content**: Images, buttons in notifications
5. **Push Notifications**: Mobile push via Expo SDK
