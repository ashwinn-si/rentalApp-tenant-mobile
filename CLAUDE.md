# tenant-mobile/ - Tenant Mobile App

## Purpose

Expo React Native tenant portal for read-only rent visibility across iOS and Android.

## Rules

1. Keep this package fully independent. No imports from backend, tenant, client-admin, or super-admin packages.
2. API integration only through HTTP calls to backend endpoints.
3. Tenant domain is read-only except auth self-service endpoint for password change.
4. Login uses client code + email + password.
5. Handle both 401 and 403 in API interceptor by clearing auth session and redirecting to login.
6. Store auth token in secure storage. Do not persist token in plain AsyncStorage payloads.
7. Keep screens mobile-first and avoid admin portal UI patterns.
8. Never commit secrets or .env files.

## Initial Scope

- Base app scaffold
- Auth flow skeleton
- Tabs navigation skeleton
- Shared UI primitives
- Store and API infrastructure skeleton
