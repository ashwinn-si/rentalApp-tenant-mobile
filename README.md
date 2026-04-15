# Tenant Mobile

Independent Expo React Native app for tenant users.

## Tech stack

- Expo SDK 51
- Expo Router
- React Native + TypeScript
- Redux Toolkit + redux-persist
- Axios + SecureStore token handling

## Prerequisites

- Node.js 18+ or 20+
- npm 9+
- Xcode (for iOS simulator)
- Android Studio (for Android emulator)

## Setup

1. Open terminal in this folder:

```bash
cd tenant-mobile
```

2. Install dependencies:

```bash
npm install
```

3. Create environment file:

```bash
cp .env.example .env
```

4. Update backend URL in `.env` if needed:

```env
EXPO_PUBLIC_API_URL=http://localhost:5000/api
```

## Run the app

From `tenant-mobile` folder:

```bash
npm run start
```

Then choose a target:

- `i` for iOS simulator
- `a` for Android emulator
- `w` for web

Direct target commands:

```bash
npm run ios
npm run android
npm run web
```

## Quality checks

```bash
npm run typecheck
npm run lint
```

## Auth implementation

Implemented in this step:

- Login form with validation (client code, email, password)
- Change password form with confirmation validation
- Token storage in SecureStore
- Axios interceptor attaches bearer token on requests
- Axios handles `401` and `403` by clearing auth state
- App bootstrap validates token from SecureStore before route guard runs

## Router namespace: `/tenant-mobile`

This app now uses a dedicated route namespace.

Main route entry:

- `/tenant-mobile`

Auth routes:

- `/tenant-mobile/(auth)/login`
- `/tenant-mobile/(auth)/change-password`

App tab routes:

- `/tenant-mobile/(tabs)`
- `/tenant-mobile/(tabs)/history`
- `/tenant-mobile/(tabs)/notifications`
- `/tenant-mobile/(tabs)/documents`
- `/tenant-mobile/(tabs)/profile`

## Project structure (current)

```text
tenant-mobile/
├── app/
│   ├── (auth)/
│   ├── (tabs)/
│   ├── tenant-mobile/
│   │   ├── (auth)/
│   │   └── (tabs)/
│   ├── _layout.tsx
│   ├── +not-found.tsx
│   └── index.tsx
├── api/
├── components/
├── constants/
├── store/
├── types/
└── utils/
```

## Notes

- This package is independent and keeps its own `node_modules`.
- No root workspace or root script dependency is required.
