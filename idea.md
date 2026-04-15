# Tenant Portal — React Native (Expo) Implementation Guide

> Cross-platform (iOS + Android) rebuild of `tenant.app.com` with OTA updates via Expo EAS.

---

## Table of Contents

1. [Tech Stack & Rationale](#1-tech-stack--rationale)
2. [Project Setup & OTA Updates](#2-project-setup--ota-updates)
3. [Project Structure](#3-project-structure)
4. [Design System & Tokens](#4-design-system--tokens)
5. [Generic API Helper](#5-generic-api-helper)
6. [State Management (Redux)](#6-state-management-redux)
7. [Reusable Components](#7-reusable-components)
    - 7.1 [AppLoader (Full-screen + Inline)](#71-apploader)
    - 7.2 [AppToast](#72-apptoast)
    - 7.3 [AppModal](#73-appmodal)
    - 7.4 [BottomSheet](#74-bottomsheet)
    - 7.5 [DataTable](#75-datatable)
    - 7.6 [Charts (Bar + Line)](#76-charts)
    - 7.7 [StatusChip](#77-statuschip)
    - 7.8 [InfoField](#78-infofield)
    - 7.9 [StateCard](#79-statecard)
    - 7.10 [Button](#710-button)
    - 7.11 [FormField + CustomInput](#711-formfield--custominput)
    - 7.12 [SkeletonCard](#712-skeletoncard)
    - 7.13 [FlatSelector](#713-flatselector)
    - 7.14 [RentBreakdownCard](#714-rentbreakdowncard)
    - 7.15 [NotificationCard](#715-notificationcard)
    - 7.16 [SimplePaginator](#716-simplepaginator)
8. [Navigation Structure](#8-navigation-structure)
9. [Authentication Flow](#9-authentication-flow)
10. [Pages](#10-pages)
    - 10.1 [Login](#101-login-page)
    - 10.2 [Change Password](#102-change-password-page)
    - 10.3 [Dashboard](#103-dashboard-page)
    - 10.4 [History](#104-history-page)
    - 10.5 [Notifications](#105-notifications-page)
    - 10.6 [Documents](#106-documents-page)
    - 10.7 [Profile](#107-profile-page)
11. [Backend API Contracts](#11-backend-api-contracts)
12. [OTA Update Strategy](#12-ota-update-strategy)
13. [Environment & Config](#13-environment--config)
14. [Testing Checklist](#14-testing-checklist)

---

## 1. Tech Stack & Rationale

| Concern       | Library                                                          | Why                                              |
| ------------- | ---------------------------------------------------------------- | ------------------------------------------------ |
| Framework     | **Expo SDK 51** (managed workflow)                               | OTA via EAS Update, no native code needed        |
| Language      | **TypeScript** (strict)                                          | Matches web codebase, type safety                |
| Navigation    | **Expo Router v3** (file-based)                                  | Same mental model as Next.js, deep-link friendly |
| State         | **Redux Toolkit + redux-persist**                                | Direct port from web; AsyncStorage backend       |
| HTTP          | **Axios**                                                        | Identical interceptor pattern as web             |
| Forms         | **react-hook-form + zod**                                        | Same validation schemas as web                   |
| Charts        | **Victory Native XL**                                            | Skia-based, performant on mobile                 |
| UI Primitives | **NativeWind v4** (Tailwind for RN)                              | Near-identical class names to web                |
| Icons         | **@expo/vector-icons (Lucide)**                                  | Same icon names as web                           |
| Toast         | **react-native-toast-message**                                   | iOS/Android safe, customizable                   |
| Bottom Sheet  | **@gorhom/bottom-sheet**                                         | For flat selector & modals                       |
| Documents     | **expo-file-system + expo-sharing**                              | Download + open PDFs                             |
| OTA Updates   | **expo-updates + EAS Update**                                    | Push JS bundle updates without app store         |
| Storage       | **expo-secure-store** (token) + **AsyncStorage** (redux-persist) | Secure token, persistent state                   |
| Notifications | **expo-notifications**                                           | Push support (future-ready)                      |
| Animations    | **react-native-reanimated v3**                                   | Required by bottom-sheet and skeletons           |
| Skeleton      | **moti**                                                         | Reanimated-based skeleton animations             |

---

## 2. Project Setup & OTA Updates

### 2.1 Initialize Project

```bash
# Create Expo project with TypeScript template
npx create-expo-app@latest tenant-portal --template expo-template-blank-typescript
cd tenant-portal

# Install Expo Router
npx expo install expo-router react-native-safe-area-context react-native-screens \
  expo-linking expo-constants expo-status-bar

# Core dependencies
npx expo install @reduxjs/toolkit react-redux redux-persist \
  @react-native-async-storage/async-storage \
  axios \
  react-hook-form @hookform/resolvers zod \
  react-native-toast-message \
  @gorhom/bottom-sheet react-native-reanimated react-native-gesture-handler \
  expo-file-system expo-sharing expo-web-browser \
  expo-secure-store \
  victory-native react-native-svg \
  moti

# NativeWind
npm install nativewind
npm install --save-dev tailwindcss

# EAS CLI
npm install -g eas-cli
eas login
eas build:configure
```

### 2.2 Configure `app.json`

```json
{
    "expo": {
        "name": "Tenant Portal",
        "slug": "tenant-portal",
        "scheme": "tenantportal",
        "version": "1.0.0",
        "runtimeVersion": {
            "policy": "sdkVersion"
        },
        "updates": {
            "url": "https://u.expo.dev/<YOUR_PROJECT_ID>",
            "enabled": true,
            "checkAutomatically": "ON_LOAD",
            "fallbackToCacheTimeout": 0
        },
        "android": {
            "package": "com.yourcompany.tenantportal",
            "adaptiveIcon": { "foregroundImage": "./assets/icon.png" }
        },
        "ios": {
            "bundleIdentifier": "com.yourcompany.tenantportal",
            "supportsTablet": true
        },
        "plugins": [
            "expo-router",
            "expo-secure-store",
            ["expo-notifications", { "icon": "./assets/notification-icon.png" }]
        ]
    }
}
```

### 2.3 `tailwind.config.js`

```js
/** @type {import('tailwindcss').Config} */
module.exports = {
    content: ['./app/**/*.{js,jsx,ts,tsx}', './components/**/*.{js,jsx,ts,tsx}'],
    presets: [require('nativewind/preset')],
    theme: {
        extend: {
            colors: {
                brand: {
                    violet: '#7c3aed',
                    fuchsia: '#a21caf',
                    rose: '#e11d48',
                },
            },
        },
    },
    plugins: [],
};
```

### 2.4 `babel.config.js`

```js
module.exports = function (api) {
    api.cache(true);
    return {
        presets: [['babel-preset-expo', { jsxImportSource: 'nativewind' }], 'nativewind/babel'],
        plugins: ['react-native-reanimated/plugin'],
    };
};
```

---

## 3. Project Structure

```
tenant-portal/
├── app/                          # Expo Router — all screens live here
│   ├── (auth)/                   # Public routes group
│   │   ├── login.tsx
│   │   └── change-password.tsx
│   ├── (tabs)/                   # Authenticated tab routes group
│   │   ├── _layout.tsx           # Tab bar config
│   │   ├── index.tsx             # Dashboard
│   │   ├── history.tsx
│   │   ├── notifications.tsx
│   │   ├── documents.tsx
│   │   └── profile.tsx
│   ├── _layout.tsx               # Root layout (providers, OTA check)
│   └── +not-found.tsx
├── components/
│   ├── ui/                       # Generic reusable components
│   │   ├── AppLoader.tsx
│   │   ├── AppToast.tsx
│   │   ├── AppModal.tsx
│   │   ├── BottomSheetWrapper.tsx
│   │   ├── Button.tsx
│   │   ├── DataTable.tsx
│   │   ├── Charts.tsx
│   │   ├── StatusChip.tsx
│   │   ├── InfoField.tsx
│   │   ├── StateCard.tsx
│   │   ├── SkeletonCard.tsx
│   │   ├── FormField.tsx
│   │   └── CustomInput.tsx
│   ├── domain/                   # Feature-specific components
│   │   ├── FlatSelector.tsx
│   │   ├── RentBreakdownCard.tsx
│   │   ├── NotificationCard.tsx
│   │   ├── SimplePaginator.tsx
│   │   └── PaymentSplitGrid.tsx
│   └── layout/
│       └── ScreenWrapper.tsx
├── api/
│   ├── axiosInstance.ts          # Generic API helper
│   └── endpoints/
│       ├── auth.api.ts
│       ├── dashboard.api.ts
│       ├── history.api.ts
│       ├── profile.api.ts
│       └── documents.api.ts
├── store/
│   ├── index.ts
│   └── slices/
│       └── authSlice.ts
├── hooks/
│   ├── useAuth.ts
│   ├── useDashboard.ts
│   ├── useHistory.ts
│   └── useDocuments.ts
├── constants/
│   └── tokens.ts                 # Design tokens
├── utils/
│   ├── formatCurrency.ts
│   ├── formatDate.ts
│   └── maskPII.ts
├── types/
│   └── api.types.ts
├── assets/
├── app.json
├── babel.config.js
├── tailwind.config.js
└── tsconfig.json
```

---

## 4. Design System & Tokens

```typescript
// constants/tokens.ts

export const Colors = {
    brand: {
        violet: '#7c3aed',
        fuchsia: '#a21caf',
        rose: '#e11d48',
    },
    status: {
        paid: '#16a34a', // green-600
        partial: '#d97706', // amber-600
        pending: '#dc2626', // red-600
    },
    notification: {
        personal: { from: '#7c3aed', to: '#a21caf' }, // violet→fuchsia
        apartment: { from: '#d97706', to: '#b45309' }, // amber→amber-dark
        expired: { from: '#6b7280', to: '#4b5563' }, // gray
    },
    background: {
        screen: '#f5f3ff', // violet-50
        card: '#ffffff',
        skeleton: '#e5e7eb',
    },
    text: {
        primary: '#111827',
        secondary: '#6b7280',
        inverse: '#ffffff',
    },
} as const;

export const Spacing = {
    xs: 4,
    sm: 8,
    md: 16,
    lg: 24,
    xl: 32,
    xxl: 48,
} as const;

export const Radius = {
    sm: 8,
    md: 12,
    lg: 16,
    xl: 24,
    full: 9999,
} as const;

export const FontSize = {
    xs: 12,
    sm: 14,
    base: 16,
    lg: 18,
    xl: 20,
    '2xl': 24,
    '3xl': 30,
} as const;

export const Shadow = {
    card: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.06,
        shadowRadius: 8,
        elevation: 3,
    },
} as const;
```

---

## 5. Generic API Helper

```typescript
// api/axiosInstance.ts

import axios, { AxiosInstance, AxiosRequestConfig, AxiosResponse } from 'axios';
import * as SecureStore from 'expo-secure-store';
import { router } from 'expo-router';
import Toast from 'react-native-toast-message';

const BASE_URL = process.env.EXPO_PUBLIC_API_URL ?? 'https://api.tenant.app.com';

// ─── Axios Instance ───────────────────────────────────────────────────────────

const api: AxiosInstance = axios.create({
    baseURL: BASE_URL,
    timeout: 15000,
    headers: { 'Content-Type': 'application/json' },
});

// ─── Request Interceptor — Attach Token ──────────────────────────────────────

api.interceptors.request.use(async (config) => {
    const token = await SecureStore.getItemAsync('auth_token');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});

// ─── Response Interceptor — Handle 401 ───────────────────────────────────────

api.interceptors.response.use(
    (response) => response,
    async (error) => {
        const status = error?.response?.status;

        if (status === 401) {
            await SecureStore.deleteItemAsync('auth_token');
            router.replace('/(auth)/login');
            Toast.show({
                type: 'error',
                text1: 'Session expired',
                text2: 'Please log in again.',
            });
        }

        return Promise.reject(error);
    }
);

// ─── Generic Request Wrapper ─────────────────────────────────────────────────

interface ApiResponse<T> {
    data: T | null;
    error: string | null;
    status: number | null;
}

export async function apiRequest<T>(config: AxiosRequestConfig): Promise<ApiResponse<T>> {
    try {
        const response: AxiosResponse<T> = await api(config);
        return { data: response.data, error: null, status: response.status };
    } catch (err: any) {
        const message =
            err?.response?.data?.message ?? err?.message ?? 'An unexpected error occurred';
        const status = err?.response?.status ?? null;
        return { data: null, error: message, status };
    }
}

export default api;

// ─── Usage Example ────────────────────────────────────────────────────────────
// const { data, error } = await apiRequest<DashboardResponse>({
//   method: "GET",
//   url: "/tenant/dashboard",
//   params: { flatId: "uuid" },
// });
```

### Endpoint Modules

```typescript
// api/endpoints/auth.api.ts
import { apiRequest } from '../axiosInstance';

export interface LoginPayload {
    clientCode: string;
    email: string;
    password: string;
}
export interface LoginResponse {
    accessToken: string;
    user: { id: string; tenantKey: string; needsPasswordChange: boolean };
}

export const loginApi = (payload: LoginPayload) =>
    apiRequest<LoginResponse>({ method: 'POST', url: '/tenant/auth/login', data: payload });

export const changePasswordApi = (payload: { currentPassword: string; newPassword: string }) =>
    apiRequest<{ success: boolean }>({
        method: 'POST',
        url: '/tenant/change-password',
        data: payload,
    });
```

```typescript
// api/endpoints/dashboard.api.ts
import { apiRequest } from '../axiosInstance';
import type { DashboardResponse } from '../../types/api.types';

export const getDashboard = (flatId?: string) =>
    apiRequest<DashboardResponse>({
        method: 'GET',
        url: '/tenant/dashboard',
        params: flatId && flatId !== 'all' ? { flatId } : undefined,
    });
```

---

## 6. State Management (Redux)

```typescript
// store/slices/authSlice.ts
import { createSlice, PayloadAction } from '@reduxjs/toolkit';

interface AuthState {
    token: string | null;
    userId: string | null;
    tenantKey: string | null;
    activeFlatId: string | null;
    mustChangePassword: boolean;
}

const initialState: AuthState = {
    token: null,
    userId: null,
    tenantKey: null,
    activeFlatId: null,
    mustChangePassword: false,
};

const authSlice = createSlice({
    name: 'auth',
    initialState,
    reducers: {
        setCredentials(state, action: PayloadAction<Omit<AuthState, never>>) {
            Object.assign(state, action.payload);
        },
        setActiveFlatId(state, action: PayloadAction<string>) {
            state.activeFlatId = action.payload;
        },
        clearMustChangePassword(state) {
            state.mustChangePassword = false;
        },
        clearCredentials() {
            return initialState;
        },
    },
});

export const { setCredentials, setActiveFlatId, clearMustChangePassword, clearCredentials } =
    authSlice.actions;
export default authSlice.reducer;
```

```typescript
// store/index.ts
import { configureStore } from '@reduxjs/toolkit';
import {
    persistStore,
    persistReducer,
    FLUSH,
    REHYDRATE,
    PAUSE,
    PERSIST,
    PURGE,
    REGISTER,
} from 'redux-persist';
import AsyncStorage from '@react-native-async-storage/async-storage';
import authReducer from './slices/authSlice';

const persistConfig = { key: 'tenant-root', storage: AsyncStorage, whitelist: ['auth'] };

export const store = configureStore({
    reducer: { auth: persistReducer(persistConfig, authReducer) },
    middleware: (getDefaultMiddleware) =>
        getDefaultMiddleware({
            serializableCheck: {
                ignoredActions: [FLUSH, REHYDRATE, PAUSE, PERSIST, PURGE, REGISTER],
            },
        }),
});

export const persistor = persistStore(store);
export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
```

---

## 7. Reusable Components

### 7.1 AppLoader

Handles both **full-screen overlay** loading and **inline** spinner.

```tsx
// components/ui/AppLoader.tsx
import React from 'react';
import { View, ActivityIndicator, Modal, StyleSheet } from 'react-native';
import { Colors } from '../../constants/tokens';

interface Props {
    visible: boolean;
    fullScreen?: boolean; // true = modal overlay, false = inline
    size?: 'small' | 'large';
    color?: string;
}

export function AppLoader({
    visible,
    fullScreen = true,
    size = 'large',
    color = Colors.brand.violet,
}: Props) {
    if (!visible) return null;

    if (fullScreen) {
        return (
            <Modal transparent animationType="none" visible={visible}>
                <View style={styles.overlay}>
                    <View style={styles.box}>
                        <ActivityIndicator size={size} color={color} />
                    </View>
                </View>
            </Modal>
        );
    }

    return <ActivityIndicator size={size} color={color} style={styles.inline} />;
}

const styles = StyleSheet.create({
    overlay: {
        flex: 1,
        backgroundColor: 'rgba(0,0,0,0.4)',
        justifyContent: 'center',
        alignItems: 'center',
    },
    box: {
        backgroundColor: '#fff',
        borderRadius: 16,
        padding: 24,
        shadowColor: '#000',
        shadowOpacity: 0.15,
        shadowRadius: 12,
        elevation: 8,
    },
    inline: { marginVertical: 16 },
});
```

### 7.2 AppToast

Wrapper that configures `react-native-toast-message` globally with branded styles.

```tsx
// components/ui/AppToast.tsx
import Toast, { BaseToast, ErrorToast, ToastConfig } from 'react-native-toast-message';
import { Colors } from '../../constants/tokens';

export const toastConfig: ToastConfig = {
    success: (props) => (
        <BaseToast
            {...props}
            style={{ borderLeftColor: Colors.status.paid, borderRadius: 12 }}
            contentContainerStyle={{ paddingHorizontal: 16 }}
            text1Style={{ fontSize: 14, fontWeight: '600' }}
            text2Style={{ fontSize: 12 }}
        />
    ),
    error: (props) => (
        <ErrorToast
            {...props}
            style={{ borderLeftColor: Colors.status.pending, borderRadius: 12 }}
            contentContainerStyle={{ paddingHorizontal: 16 }}
            text1Style={{ fontSize: 14, fontWeight: '600' }}
            text2Style={{ fontSize: 12 }}
        />
    ),
};

// ─── Helper functions ──────────────────────────────────────────────────────────

export const showToast = {
    success: (text1: string, text2?: string) =>
        Toast.show({ type: 'success', text1, text2, visibilityTime: 3000, position: 'bottom' }),
    error: (text1: string, text2?: string) =>
        Toast.show({ type: 'error', text1, text2, visibilityTime: 3000, position: 'bottom' }),
};

// ─── Usage ─────────────────────────────────────────────────────────────────────
// In root _layout.tsx: <Toast config={toastConfig} />
// Anywhere:           showToast.success("Logged in!", "Welcome back");
//                     showToast.error("Invalid credentials");
```

### 7.3 AppModal

Generic, reusable modal with title, content slot, and action buttons.

```tsx
// components/ui/AppModal.tsx
import React from 'react';
import { Modal, View, Text, Pressable, StyleSheet, ScrollView } from 'react-native';
import { Colors, Radius, Spacing, FontSize } from '../../constants/tokens';

interface Action {
    label: string;
    onPress: () => void;
    variant?: 'primary' | 'secondary' | 'danger';
}

interface Props {
    visible: boolean;
    title: string;
    onClose: () => void;
    actions?: Action[];
    children: React.ReactNode;
}

export function AppModal({ visible, title, onClose, actions = [], children }: Props) {
    return (
        <Modal visible={visible} transparent animationType="fade" onRequestClose={onClose}>
            <Pressable style={styles.overlay} onPress={onClose}>
                <Pressable style={styles.sheet} onPress={(e) => e.stopPropagation()}>
                    {/* Header */}
                    <View style={styles.header}>
                        <Text style={styles.title}>{title}</Text>
                        <Pressable onPress={onClose} hitSlop={12}>
                            <Text style={styles.closeBtn}>✕</Text>
                        </Pressable>
                    </View>

                    {/* Body */}
                    <ScrollView style={styles.body} showsVerticalScrollIndicator={false}>
                        {children}
                    </ScrollView>

                    {/* Actions */}
                    {actions.length > 0 && (
                        <View style={styles.actions}>
                            {actions.map((action) => (
                                <Pressable
                                    key={action.label}
                                    style={[
                                        styles.actionBtn,
                                        styles[action.variant ?? 'secondary'],
                                    ]}
                                    onPress={action.onPress}
                                >
                                    <Text style={styles.actionText}>{action.label}</Text>
                                </Pressable>
                            ))}
                        </View>
                    )}
                </Pressable>
            </Pressable>
        </Modal>
    );
}

const styles = StyleSheet.create({
    overlay: {
        flex: 1,
        backgroundColor: 'rgba(0,0,0,0.5)',
        justifyContent: 'center',
        alignItems: 'center',
        padding: Spacing.lg,
    },
    sheet: {
        backgroundColor: '#fff',
        borderRadius: Radius.lg,
        width: '100%',
        maxHeight: '80%',
        overflow: 'hidden',
    },
    header: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        padding: Spacing.md,
        borderBottomWidth: 1,
        borderBottomColor: '#f3f4f6',
    },
    title: { fontSize: FontSize.lg, fontWeight: '700', color: Colors.text.primary },
    closeBtn: { fontSize: 18, color: Colors.text.secondary },
    body: { padding: Spacing.md },
    actions: {
        flexDirection: 'row',
        gap: Spacing.sm,
        padding: Spacing.md,
        borderTopWidth: 1,
        borderTopColor: '#f3f4f6',
    },
    actionBtn: { flex: 1, paddingVertical: 12, borderRadius: Radius.md, alignItems: 'center' },
    primary: { backgroundColor: Colors.brand.violet },
    secondary: { backgroundColor: '#f3f4f6' },
    danger: { backgroundColor: Colors.status.pending },
    actionText: { fontWeight: '600', color: Colors.text.primary },
});
```

### 7.4 BottomSheet

Wraps `@gorhom/bottom-sheet` as a reusable snap-panel (used for FlatSelector and document previews).

```tsx
// components/ui/BottomSheetWrapper.tsx
import React, { forwardRef, useCallback } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import RNBottomSheet, { BottomSheetBackdrop, BottomSheetScrollView } from '@gorhom/bottom-sheet';
import { Colors, Spacing, FontSize, Radius } from '../../constants/tokens';

interface Props {
    title?: string;
    snapPoints?: string[];
    children: React.ReactNode;
    onClose?: () => void;
}

export const BottomSheetWrapper = forwardRef<RNBottomSheet, Props>(
    ({ title, snapPoints = ['40%', '75%'], children, onClose }, ref) => {
        const renderBackdrop = useCallback(
            (props: any) => (
                <BottomSheetBackdrop {...props} disappearsOnIndex={-1} appearsOnIndex={0} />
            ),
            []
        );

        return (
            <RNBottomSheet
                ref={ref}
                index={-1}
                snapPoints={snapPoints}
                enablePanDownToClose
                backdropComponent={renderBackdrop}
                onClose={onClose}
                handleIndicatorStyle={styles.handle}
                backgroundStyle={styles.bg}
            >
                {title && (
                    <View style={styles.header}>
                        <Text style={styles.title}>{title}</Text>
                    </View>
                )}
                <BottomSheetScrollView contentContainerStyle={styles.content}>
                    {children}
                </BottomSheetScrollView>
            </RNBottomSheet>
        );
    }
);

const styles = StyleSheet.create({
    bg: { borderTopLeftRadius: Radius.xl, borderTopRightRadius: Radius.xl },
    handle: { backgroundColor: '#d1d5db', width: 40 },
    header: {
        paddingHorizontal: Spacing.md,
        paddingBottom: Spacing.sm,
        borderBottomWidth: 1,
        borderBottomColor: '#f3f4f6',
    },
    title: { fontSize: FontSize.lg, fontWeight: '700', color: Colors.text.primary },
    content: { padding: Spacing.md },
});
```

### 7.5 DataTable

Generic, scrollable table with typed columns and rows.

```tsx
// components/ui/DataTable.tsx
import React from 'react';
import { View, Text, ScrollView, StyleSheet } from 'react-native';
import { Colors, Spacing, FontSize } from '../../constants/tokens';

export interface Column<T> {
    key: keyof T | string;
    header: string;
    width?: number;
    align?: 'left' | 'right' | 'center';
    render?: (value: any, row: T) => React.ReactNode;
}

interface Props<T> {
    columns: Column<T>[];
    data: T[];
    keyExtractor: (item: T) => string;
    emptyText?: string;
}

export function DataTable<T>({ columns, data, keyExtractor, emptyText = 'No data' }: Props<T>) {
    if (data.length === 0) {
        return (
            <View style={styles.empty}>
                <Text style={styles.emptyText}>{emptyText}</Text>
            </View>
        );
    }

    return (
        <ScrollView horizontal showsHorizontalScrollIndicator={false}>
            <View>
                {/* Header Row */}
                <View style={[styles.row, styles.headerRow]}>
                    {columns.map((col) => (
                        <Text
                            key={String(col.key)}
                            style={[
                                styles.headerCell,
                                { width: col.width ?? 120, textAlign: col.align ?? 'left' },
                            ]}
                        >
                            {col.header}
                        </Text>
                    ))}
                </View>

                {/* Data Rows */}
                {data.map((item, index) => (
                    <View
                        key={keyExtractor(item)}
                        style={[styles.row, index % 2 === 1 && styles.altRow]}
                    >
                        {columns.map((col) => {
                            const value = (item as any)[col.key];
                            return (
                                <View key={String(col.key)} style={{ width: col.width ?? 120 }}>
                                    {col.render ? (
                                        col.render(value, item)
                                    ) : (
                                        <Text
                                            style={[
                                                styles.cell,
                                                { textAlign: col.align ?? 'left' },
                                            ]}
                                        >
                                            {String(value ?? '-')}
                                        </Text>
                                    )}
                                </View>
                            );
                        })}
                    </View>
                ))}
            </View>
        </ScrollView>
    );
}

const styles = StyleSheet.create({
    row: { flexDirection: 'row', paddingVertical: 10, paddingHorizontal: Spacing.sm },
    headerRow: { backgroundColor: '#f5f3ff', borderBottomWidth: 1, borderBottomColor: '#ede9fe' },
    altRow: { backgroundColor: '#fafafa' },
    headerCell: { fontSize: FontSize.sm, fontWeight: '700', color: Colors.brand.violet },
    cell: { fontSize: FontSize.sm, color: Colors.text.primary },
    empty: { padding: Spacing.lg, alignItems: 'center' },
    emptyText: { color: Colors.text.secondary, fontSize: FontSize.sm },
});
```

### 7.6 Charts

Wraps **Victory Native XL** into two reusable charts that mirror the web Recharts versions.

```tsx
// components/ui/Charts.tsx
import React from 'react';
import { View, Text, ScrollView, StyleSheet, Dimensions } from 'react-native';
import {
    VictoryBar,
    VictoryLine,
    VictoryChart,
    VictoryAxis,
    VictoryStack,
    VictoryTooltip,
    VictoryLegend,
    VictoryTheme,
} from 'victory-native';
import { Colors, FontSize, Spacing } from '../../constants/tokens';

const SCREEN_W = Dimensions.get('window').width;

// ─── Stacked Bar Chart ────────────────────────────────────────────────────────

interface BarDataItem {
    monthLabel: string;
    baseRent: number;
    utility: number;
    maintenance: number;
    previousDues: number;
}

export function RentStackedBarChart({ data }: { data: BarDataItem[] }) {
    const chartWidth = Math.max(SCREEN_W - 32, data.length * 72);
    const categories = data.map((d) => d.monthLabel);

    const toVictory = (key: keyof BarDataItem) =>
        data.map((d, i) => ({ x: i + 1, y: Number(d[key]) }));

    return (
        <View>
            <Text style={styles.chartTitle}>Monthly Rent Breakdown</Text>
            <ScrollView horizontal showsHorizontalScrollIndicator={false}>
                <VictoryChart
                    width={chartWidth}
                    height={260}
                    theme={VictoryTheme.grayscale}
                    domainPadding={{ x: 20 }}
                >
                    <VictoryAxis
                        tickValues={data.map((_, i) => i + 1)}
                        tickFormat={categories}
                        style={{ tickLabels: { fontSize: 10, angle: -30 } }}
                    />
                    <VictoryAxis dependentAxis tickFormat={(v) => `₹${(v / 1000).toFixed(0)}k`} />
                    <VictoryStack colorScale={['#7c3aed', '#06b6d4', '#f59e0b', '#ef4444']}>
                        <VictoryBar data={toVictory('baseRent')} />
                        <VictoryBar data={toVictory('utility')} />
                        <VictoryBar data={toVictory('maintenance')} />
                        <VictoryBar data={toVictory('previousDues')} />
                    </VictoryStack>
                </VictoryChart>
            </ScrollView>
            <View style={styles.legend}>
                {[
                    { label: 'Base Rent', color: '#7c3aed' },
                    { label: 'Utility', color: '#06b6d4' },
                    { label: 'Maintenance', color: '#f59e0b' },
                    { label: 'Previous Dues', color: '#ef4444' },
                ].map((item) => (
                    <View key={item.label} style={styles.legendItem}>
                        <View style={[styles.legendDot, { backgroundColor: item.color }]} />
                        <Text style={styles.legendText}>{item.label}</Text>
                    </View>
                ))}
            </View>
        </View>
    );
}

// ─── Line Chart ───────────────────────────────────────────────────────────────

interface LineDataItem {
    monthLabel: string;
    totalDue: number;
    paid: number;
    pending: number;
}

export function RentTrendLineChart({ data }: { data: LineDataItem[] }) {
    const chartWidth = Math.max(SCREEN_W - 32, data.length * 72);

    const toLine = (key: keyof LineDataItem) =>
        data.map((d, i) => ({ x: i + 1, y: Number(d[key]) }));

    return (
        <View>
            <Text style={styles.chartTitle}>Due vs Paid Trend</Text>
            <ScrollView horizontal showsHorizontalScrollIndicator={false}>
                <VictoryChart width={chartWidth} height={260} theme={VictoryTheme.grayscale}>
                    <VictoryAxis
                        tickValues={data.map((_, i) => i + 1)}
                        tickFormat={data.map((d) => d.monthLabel)}
                        style={{ tickLabels: { fontSize: 10, angle: -30 } }}
                    />
                    <VictoryAxis dependentAxis tickFormat={(v) => `₹${(v / 1000).toFixed(0)}k`} />
                    <VictoryLine
                        data={toLine('totalDue')}
                        style={{ data: { stroke: '#7c3aed', strokeWidth: 2 } }}
                    />
                    <VictoryLine
                        data={toLine('paid')}
                        style={{ data: { stroke: '#16a34a', strokeWidth: 2 } }}
                    />
                    <VictoryLine
                        data={toLine('pending')}
                        style={{
                            data: { stroke: '#dc2626', strokeWidth: 2, strokeDasharray: '4' },
                        }}
                    />
                </VictoryChart>
            </ScrollView>
            <View style={styles.legend}>
                {[
                    { label: 'Total Due', color: '#7c3aed' },
                    { label: 'Paid', color: '#16a34a' },
                    { label: 'Pending', color: '#dc2626' },
                ].map((item) => (
                    <View key={item.label} style={styles.legendItem}>
                        <View style={[styles.legendDot, { backgroundColor: item.color }]} />
                        <Text style={styles.legendText}>{item.label}</Text>
                    </View>
                ))}
            </View>
        </View>
    );
}

const styles = StyleSheet.create({
    chartTitle: {
        fontSize: FontSize.base,
        fontWeight: '700',
        color: Colors.text.primary,
        marginBottom: 8,
    },
    legend: { flexDirection: 'row', flexWrap: 'wrap', gap: 12, marginTop: 8 },
    legendItem: { flexDirection: 'row', alignItems: 'center', gap: 4 },
    legendDot: { width: 10, height: 10, borderRadius: 5 },
    legendText: { fontSize: FontSize.xs, color: Colors.text.secondary },
});
```

### 7.7 StatusChip

```tsx
// components/ui/StatusChip.tsx
import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Colors } from '../../constants/tokens';

type Status = 'Paid' | 'Partial' | 'Pending';

const config: Record<Status, { bg: string; text: string }> = {
    Paid: { bg: '#dcfce7', text: Colors.status.paid },
    Partial: { bg: '#fef3c7', text: Colors.status.partial },
    Pending: { bg: '#fee2e2', text: Colors.status.pending },
};

export function StatusChip({ status }: { status: Status }) {
    const { bg, text } = config[status] ?? config.Pending;
    return (
        <View style={[styles.chip, { backgroundColor: bg }]}>
            <Text style={[styles.label, { color: text }]}>{status}</Text>
        </View>
    );
}

const styles = StyleSheet.create({
    chip: {
        paddingHorizontal: 10,
        paddingVertical: 4,
        borderRadius: 9999,
        alignSelf: 'flex-start',
    },
    label: { fontSize: 12, fontWeight: '700' },
});
```

### 7.8 InfoField

```tsx
// components/ui/InfoField.tsx
import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Colors, Spacing, FontSize, Radius } from '../../constants/tokens';

interface Props {
    label: string;
    value?: string | null;
}

export function InfoField({ label, value }: Props) {
    return (
        <View style={styles.container}>
            <Text style={styles.label}>{label}</Text>
            <Text style={styles.value}>{value?.trim() || '-'}</Text>
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        backgroundColor: '#f9fafb',
        borderRadius: Radius.md,
        padding: Spacing.md,
        marginBottom: Spacing.sm,
    },
    label: { fontSize: FontSize.xs, color: Colors.text.secondary, marginBottom: 4 },
    value: { fontSize: FontSize.base, color: Colors.text.primary, fontWeight: '500' },
});
```

### 7.9 StateCard

```tsx
// components/ui/StateCard.tsx
import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Colors, Spacing, Radius, FontSize } from '../../constants/tokens';

interface Props {
    message: string;
    icon?: React.ReactNode;
    variant?: 'info' | 'error' | 'empty';
}

const variantColors = {
    info: { bg: '#ede9fe', border: '#c4b5fd' },
    error: { bg: '#fee2e2', border: '#fca5a5' },
    empty: { bg: '#f5f3ff', border: '#ddd6fe' },
};

export function StateCard({ message, icon, variant = 'info' }: Props) {
    const { bg, border } = variantColors[variant];
    return (
        <View style={[styles.card, { backgroundColor: bg, borderColor: border }]}>
            {icon}
            <Text style={styles.text}>{message}</Text>
        </View>
    );
}

const styles = StyleSheet.create({
    card: {
        borderRadius: Radius.lg,
        borderWidth: 1,
        padding: Spacing.lg,
        alignItems: 'center',
        gap: Spacing.sm,
        marginVertical: Spacing.md,
    },
    text: { fontSize: FontSize.sm, color: Colors.text.secondary, textAlign: 'center' },
});
```

### 7.10 Button

```tsx
// components/ui/Button.tsx
import React from 'react';
import { Pressable, Text, ActivityIndicator, StyleSheet, ViewStyle } from 'react-native';
import { Colors, Radius, FontSize } from '../../constants/tokens';

type Variant = 'primary' | 'secondary' | 'ghost' | 'outline';
type Size = 'sm' | 'md' | 'lg';

interface Props {
    label: string;
    onPress: () => void;
    variant?: Variant;
    size?: Size;
    isLoading?: boolean;
    disabled?: boolean;
    fullWidth?: boolean;
    leftIcon?: React.ReactNode;
}

const variantStyle: Record<Variant, ViewStyle> = {
    primary: { backgroundColor: Colors.brand.violet },
    secondary: { backgroundColor: '#f3f4f6' },
    ghost: { backgroundColor: 'transparent' },
    outline: { backgroundColor: 'transparent', borderWidth: 1.5, borderColor: Colors.brand.violet },
};

const sizeStyle = {
    sm: { paddingVertical: 8, paddingHorizontal: 14 },
    md: { paddingVertical: 12, paddingHorizontal: 20 },
    lg: { paddingVertical: 16, paddingHorizontal: 28 },
};

const textColor: Record<Variant, string> = {
    primary: '#fff',
    secondary: Colors.text.primary,
    ghost: Colors.brand.violet,
    outline: Colors.brand.violet,
};

export function Button({
    label,
    onPress,
    variant = 'primary',
    size = 'md',
    isLoading = false,
    disabled = false,
    fullWidth = false,
    leftIcon,
}: Props) {
    return (
        <Pressable
            onPress={onPress}
            disabled={disabled || isLoading}
            style={[
                styles.base,
                variantStyle[variant],
                sizeStyle[size],
                fullWidth && { width: '100%' },
                (disabled || isLoading) && styles.disabled,
            ]}
        >
            {isLoading ? (
                <ActivityIndicator size="small" color={textColor[variant]} />
            ) : (
                <>
                    {leftIcon}
                    <Text
                        style={[
                            styles.text,
                            {
                                color: textColor[variant],
                                fontSize:
                                    FontSize[size === 'sm' ? 'sm' : size === 'lg' ? 'lg' : 'base'],
                            },
                        ]}
                    >
                        {label}
                    </Text>
                </>
            )}
        </Pressable>
    );
}

const styles = StyleSheet.create({
    base: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        borderRadius: Radius.md,
        gap: 8,
    },
    text: { fontWeight: '600' },
    disabled: { opacity: 0.5 },
});
```

### 7.11 FormField + CustomInput

```tsx
// components/ui/FormField.tsx
import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Controller, Control, FieldValues, Path } from 'react-hook-form';
import { CustomInput } from './CustomInput';
import { Colors, FontSize, Spacing } from '../../constants/tokens';

interface Props<T extends FieldValues> {
    control: Control<T>;
    name: Path<T>;
    label: string;
    placeholder?: string;
    secureTextEntry?: boolean;
    keyboardType?: 'default' | 'email-address' | 'phone-pad' | 'numeric';
}

export function FormField<T extends FieldValues>({
    control,
    name,
    label,
    placeholder,
    secureTextEntry,
    keyboardType,
}: Props<T>) {
    return (
        <Controller
            control={control}
            name={name}
            render={({ field: { value, onChange, onBlur }, fieldState: { error } }) => (
                <View style={styles.wrapper}>
                    <Text style={styles.label}>{label}</Text>
                    <CustomInput
                        value={value}
                        onChangeText={onChange}
                        onBlur={onBlur}
                        placeholder={placeholder}
                        secureTextEntry={secureTextEntry}
                        keyboardType={keyboardType}
                        hasError={!!error}
                    />
                    {error && <Text style={styles.error}>{error.message}</Text>}
                </View>
            )}
        />
    );
}

const styles = StyleSheet.create({
    wrapper: { marginBottom: Spacing.md },
    label: {
        fontSize: FontSize.sm,
        fontWeight: '600',
        color: Colors.text.primary,
        marginBottom: 6,
    },
    error: { fontSize: FontSize.xs, color: Colors.status.pending, marginTop: 4 },
});
```

```tsx
// components/ui/CustomInput.tsx
import React, { useState } from 'react';
import { TextInput, View, Pressable, StyleSheet, TextInputProps } from 'react-native';
import { Colors, Radius, Spacing, FontSize } from '../../constants/tokens';

interface Props extends TextInputProps {
    hasError?: boolean;
}

export function CustomInput({ hasError, secureTextEntry, style, ...props }: Props) {
    const [showPassword, setShowPassword] = useState(false);

    return (
        <View style={[styles.container, hasError && styles.errorBorder]}>
            <TextInput
                {...props}
                secureTextEntry={secureTextEntry && !showPassword}
                style={[styles.input, style]}
                placeholderTextColor="#9ca3af"
            />
            {secureTextEntry && (
                <Pressable onPress={() => setShowPassword(!showPassword)} hitSlop={8}>
                    <Text style={styles.toggleText}>{showPassword ? 'Hide' : 'Show'}</Text>
                </Pressable>
            )}
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flexDirection: 'row',
        alignItems: 'center',
        borderWidth: 1.5,
        borderColor: '#e5e7eb',
        borderRadius: Radius.md,
        paddingHorizontal: Spacing.md,
        backgroundColor: '#fff',
    },
    input: { flex: 1, paddingVertical: 12, fontSize: FontSize.base, color: Colors.text.primary },
    errorBorder: { borderColor: Colors.status.pending },
    toggleText: { fontSize: FontSize.sm, color: Colors.brand.violet, paddingLeft: 8 },
});
```

### 7.12 SkeletonCard

```tsx
// components/ui/SkeletonCard.tsx
import React from 'react';
import { View, StyleSheet } from 'react-native';
import { MotiView } from 'moti';
import { Skeleton } from 'moti/skeleton';
import { Radius, Spacing } from '../../constants/tokens';

export function SkeletonCard({ lines = 3 }: { lines?: number }) {
    return (
        <MotiView
            style={styles.card}
            from={{ opacity: 0.5 }}
            animate={{ opacity: 1 }}
            transition={{ type: 'timing', duration: 800, loop: true }}
        >
            {Array.from({ length: lines }).map((_, i) => (
                <Skeleton
                    key={i}
                    colorMode="light"
                    width={i === 0 ? '60%' : '100%'}
                    height={16}
                    radius={8}
                />
            ))}
        </MotiView>
    );
}

const styles = StyleSheet.create({
    card: {
        backgroundColor: '#fff',
        borderRadius: Radius.lg,
        padding: Spacing.md,
        gap: Spacing.sm,
        marginBottom: Spacing.md,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.05,
        shadowRadius: 8,
        elevation: 2,
    },
});
```

### 7.13 FlatSelector

```tsx
// components/domain/FlatSelector.tsx
import React, { useRef, useCallback } from 'react';
import { View, Text, Pressable, StyleSheet } from 'react-native';
import RNBottomSheet from '@gorhom/bottom-sheet';
import { useDispatch, useSelector } from 'react-redux';
import { setActiveFlatId } from '../../store/slices/authSlice';
import { RootState } from '../../store';
import { BottomSheetWrapper } from '../ui/BottomSheetWrapper';
import { Colors, Spacing, FontSize, Radius } from '../../constants/tokens';

interface Flat {
    id: string;
    label: string;
    apartmentName: string;
    flatNumber: string;
}
interface Props {
    flats: Flat[];
}

export function FlatSelector({ flats }: Props) {
    const dispatch = useDispatch();
    const activeFlatId = useSelector((s: RootState) => s.auth.activeFlatId);
    const sheetRef = useRef<RNBottomSheet>(null);

    const activeFlat = flats.find((f) => f.id === activeFlatId);
    const displayLabel =
        activeFlatId === 'all' ? 'All Flats' : (activeFlat?.label ?? 'Select Flat');

    const options =
        flats.length >= 2
            ? [{ id: 'all', label: 'All Flats', apartmentName: '', flatNumber: '' }, ...flats]
            : flats;

    const onSelect = useCallback(
        (id: string) => {
            dispatch(setActiveFlatId(id));
            sheetRef.current?.close();
        },
        [dispatch]
    );

    return (
        <>
            <Pressable style={styles.selector} onPress={() => sheetRef.current?.expand()}>
                <Text style={styles.selectorText}>{displayLabel}</Text>
                <Text style={styles.chevron}>▾</Text>
            </Pressable>

            <BottomSheetWrapper ref={sheetRef} title="Select Unit" snapPoints={['40%']}>
                {options.map((flat) => (
                    <Pressable
                        key={flat.id}
                        style={[styles.option, flat.id === activeFlatId && styles.activeOption]}
                        onPress={() => onSelect(flat.id)}
                    >
                        <Text style={styles.optionLabel}>{flat.label}</Text>
                        {flat.apartmentName ? (
                            <Text style={styles.optionSub}>{flat.apartmentName}</Text>
                        ) : null}
                    </Pressable>
                ))}
            </BottomSheetWrapper>
        </>
    );
}

const styles = StyleSheet.create({
    selector: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        backgroundColor: '#fff',
        borderRadius: Radius.md,
        padding: Spacing.md,
        borderWidth: 1,
        borderColor: '#e5e7eb',
    },
    selectorText: { fontSize: FontSize.base, color: Colors.text.primary, fontWeight: '600' },
    chevron: { fontSize: 16, color: Colors.text.secondary },
    option: {
        paddingVertical: 14,
        paddingHorizontal: Spacing.md,
        borderRadius: Radius.md,
        marginBottom: 4,
    },
    activeOption: { backgroundColor: '#ede9fe' },
    optionLabel: { fontSize: FontSize.base, fontWeight: '600', color: Colors.text.primary },
    optionSub: { fontSize: FontSize.xs, color: Colors.text.secondary, marginTop: 2 },
});
```

### 7.14 RentBreakdownCard

```tsx
// components/domain/RentBreakdownCard.tsx
import React, { useState } from 'react';
import { View, Text, Pressable, StyleSheet } from 'react-native';
import { StatusChip } from '../ui/StatusChip';
import { Colors, Spacing, FontSize, Radius, Shadow } from '../../constants/tokens';
import { formatINR } from '../../utils/formatCurrency';

interface MaintenanceItem {
    item: string;
    totalCost: number;
    yourShare: number;
}
interface Breakdown {
    baseRent: number;
    utilityBill: number;
    maintenanceShare: number;
    maintenanceBreakdown?: MaintenanceItem[];
    previousDues: number;
    totalDue: number;
}
interface Props {
    month: number;
    year: number;
    status: 'Paid' | 'Partial' | 'Pending';
    breakdown: Breakdown;
    paidAmount: number;
    apartmentName?: string;
    flatNumber?: string;
}

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

export function RentBreakdownCard({
    month,
    year,
    status,
    breakdown,
    paidAmount,
    apartmentName,
    flatNumber,
}: Props) {
    const [expanded, setExpanded] = useState(false);

    return (
        <View style={[styles.card, Shadow.card]}>
            {/* Header */}
            <View style={styles.header}>
                <Text style={styles.monthLabel}>
                    {MONTHS[month - 1]} {year}
                </Text>
                {apartmentName && (
                    <Text style={styles.subLabel}>
                        {apartmentName} · {flatNumber}
                    </Text>
                )}
                <StatusChip status={status} />
            </View>

            {/* Breakdown Rows */}
            <Row label="Base Rent" amount={breakdown.baseRent} />
            <Row label="Electricity / Water" amount={breakdown.utilityBill} />

            {/* Maintenance with expand toggle */}
            <Pressable onPress={() => setExpanded(!expanded)} style={styles.rowTouchable}>
                <Text style={styles.rowLabel}>Maintenance</Text>
                <View style={styles.rowRight}>
                    <Text style={styles.rowAmount}>{formatINR(breakdown.maintenanceShare)}</Text>
                    {(breakdown.maintenanceBreakdown?.length ?? 0) > 0 && (
                        <Text style={styles.expand}>{expanded ? '▴' : '▾'}</Text>
                    )}
                </View>
            </Pressable>
            {expanded &&
                breakdown.maintenanceBreakdown?.map((item) => (
                    <View key={item.item} style={styles.subRow}>
                        <Text style={styles.subLabel}>
                            {item.item} (Total: {formatINR(item.totalCost)})
                        </Text>
                        <Text style={styles.subAmount}>
                            Your share: {formatINR(item.yourShare)}
                        </Text>
                    </View>
                ))}

            {breakdown.previousDues > 0 && (
                <Row label="Previous Dues" amount={breakdown.previousDues} isHighlighted />
            )}

            {/* Divider */}
            <View style={styles.divider} />

            {/* Total */}
            <View style={styles.totalRow}>
                <Text style={styles.totalLabel}>Total Due</Text>
                <Text style={styles.totalAmount}>{formatINR(breakdown.totalDue)}</Text>
            </View>
            {paidAmount > 0 && (
                <View style={[styles.totalRow, { marginTop: 4 }]}>
                    <Text style={[styles.rowLabel, { color: Colors.status.paid }]}>Paid</Text>
                    <Text style={[styles.rowAmount, { color: Colors.status.paid }]}>
                        {formatINR(paidAmount)}
                    </Text>
                </View>
            )}
        </View>
    );
}

function Row({
    label,
    amount,
    isHighlighted,
}: {
    label: string;
    amount: number;
    isHighlighted?: boolean;
}) {
    return (
        <View style={styles.row}>
            <Text style={[styles.rowLabel, isHighlighted && { color: Colors.status.pending }]}>
                {label}
            </Text>
            <Text style={[styles.rowAmount, isHighlighted && { color: Colors.status.pending }]}>
                {formatINR(amount)}
            </Text>
        </View>
    );
}

const styles = StyleSheet.create({
    card: {
        backgroundColor: '#fff',
        borderRadius: Radius.lg,
        padding: Spacing.md,
        marginBottom: Spacing.md,
    },
    header: {
        flexDirection: 'row',
        alignItems: 'center',
        flexWrap: 'wrap',
        gap: Spacing.sm,
        marginBottom: Spacing.md,
    },
    monthLabel: { fontSize: FontSize.lg, fontWeight: '700', color: Colors.text.primary, flex: 1 },
    row: { flexDirection: 'row', justifyContent: 'space-between', paddingVertical: 6 },
    rowTouchable: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        paddingVertical: 6,
    },
    rowLabel: { fontSize: FontSize.sm, color: Colors.text.secondary },
    rowAmount: { fontSize: FontSize.sm, color: Colors.text.primary, fontWeight: '500' },
    rowRight: { flexDirection: 'row', alignItems: 'center', gap: 6 },
    expand: { fontSize: 12, color: Colors.brand.violet },
    subRow: { paddingLeft: Spacing.md, paddingVertical: 4 },
    subLabel: { fontSize: FontSize.xs, color: Colors.text.secondary },
    subAmount: { fontSize: FontSize.xs, color: Colors.text.primary },
    divider: { height: 1, backgroundColor: '#f3f4f6', marginVertical: Spacing.sm },
    totalRow: { flexDirection: 'row', justifyContent: 'space-between' },
    totalLabel: { fontSize: FontSize.base, fontWeight: '700', color: Colors.text.primary },
    totalAmount: { fontSize: FontSize.base, fontWeight: '700', color: Colors.brand.violet },
});
```

### 7.15 NotificationCard

```tsx
// components/domain/NotificationCard.tsx
import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Colors, Spacing, FontSize, Radius } from '../../constants/tokens';

interface Props {
    title: string;
    message: string;
    targetType: 'tenant' | 'apartment';
    expiresAt: string;
    isExpired?: boolean;
}

export function NotificationCard({ title, message, targetType, expiresAt, isExpired }: Props) {
    const gradientColors = isExpired
        ? ['#6b7280', '#4b5563']
        : targetType === 'tenant'
          ? ['#7c3aed', '#a21caf']
          : ['#d97706', '#b45309'];

    const badge = targetType === 'tenant' ? 'Personal' : 'Apartment-wide';
    const expiryFormatted = new Date(expiresAt).toLocaleDateString('en-IN', {
        day: '2-digit',
        month: 'short',
        year: 'numeric',
    });

    return (
        <View style={[styles.container, isExpired && styles.dimmed]}>
            <LinearGradient colors={gradientColors as [string, string]} style={styles.gradient}>
                <View style={styles.row}>
                    <Text style={styles.title}>{title}</Text>
                    <View style={styles.badge}>
                        <Text style={styles.badgeText}>{badge}</Text>
                    </View>
                </View>
                <Text style={styles.message} numberOfLines={3}>
                    {message}
                </Text>
                <Text style={styles.expiry}>Expires: {expiryFormatted}</Text>
            </LinearGradient>
        </View>
    );
}

const styles = StyleSheet.create({
    container: { marginBottom: Spacing.sm, borderRadius: Radius.lg, overflow: 'hidden' },
    dimmed: { opacity: 0.6 },
    gradient: { padding: Spacing.md },
    row: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'flex-start',
        marginBottom: 6,
    },
    title: { fontSize: FontSize.base, fontWeight: '700', color: '#fff', flex: 1 },
    badge: {
        backgroundColor: 'rgba(255,255,255,0.25)',
        borderRadius: Radius.full,
        paddingHorizontal: 8,
        paddingVertical: 2,
    },
    badgeText: { fontSize: FontSize.xs, color: '#fff', fontWeight: '600' },
    message: { fontSize: FontSize.sm, color: 'rgba(255,255,255,0.9)', lineHeight: 20 },
    expiry: { fontSize: FontSize.xs, color: 'rgba(255,255,255,0.7)', marginTop: 6 },
});
```

### 7.16 SimplePaginator

```tsx
// components/domain/SimplePaginator.tsx
import React from 'react';
import { View, Text, Pressable, StyleSheet } from 'react-native';
import { Colors, Spacing, FontSize, Radius } from '../../constants/tokens';

interface Props {
    page: number;
    totalPages: number;
    onPrev: () => void;
    onNext: () => void;
}

export function SimplePaginator({ page, totalPages, onPrev, onNext }: Props) {
    return (
        <View style={styles.container}>
            <Pressable
                onPress={onPrev}
                disabled={page <= 1}
                style={[styles.btn, page <= 1 && styles.disabled]}
            >
                <Text style={styles.btnText}>← Prev</Text>
            </Pressable>
            <Text style={styles.label}>
                Page {page} of {totalPages}
            </Text>
            <Pressable
                onPress={onNext}
                disabled={page >= totalPages}
                style={[styles.btn, page >= totalPages && styles.disabled]}
            >
                <Text style={styles.btnText}>Next →</Text>
            </Pressable>
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        padding: Spacing.md,
    },
    btn: {
        backgroundColor: Colors.brand.violet,
        paddingHorizontal: 16,
        paddingVertical: 10,
        borderRadius: Radius.md,
    },
    disabled: { opacity: 0.3 },
    btnText: { color: '#fff', fontWeight: '600', fontSize: FontSize.sm },
    label: { fontSize: FontSize.sm, color: Colors.text.secondary },
});
```

---

## 8. Navigation Structure

```tsx
// app/_layout.tsx  (Root layout — OTA check + Providers)
import { useEffect } from 'react';
import { Slot } from 'expo-router';
import { Provider } from 'react-redux';
import { PersistGate } from 'redux-persist/integration/react';
import Toast from 'react-native-toast-message';
import * as Updates from 'expo-updates';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { BottomSheetModalProvider } from '@gorhom/bottom-sheet';
import { store, persistor } from '../store';
import { toastConfig } from '../components/ui/AppToast';

async function checkForOTAUpdate() {
    try {
        const update = await Updates.checkForUpdateAsync();
        if (update.isAvailable) {
            await Updates.fetchUpdateAsync();
            await Updates.reloadAsync(); // Reload with new bundle
        }
    } catch {}
}

export default function RootLayout() {
    useEffect(() => {
        checkForOTAUpdate();
    }, []);

    return (
        <GestureHandlerRootView style={{ flex: 1 }}>
            <Provider store={store}>
                <PersistGate loading={null} persistor={persistor}>
                    <BottomSheetModalProvider>
                        <Slot />
                        <Toast config={toastConfig} />
                    </BottomSheetModalProvider>
                </PersistGate>
            </Provider>
        </GestureHandlerRootView>
    );
}
```

```tsx
// app/(tabs)/_layout.tsx  (Authenticated Tab Navigator)
import { Tabs, Redirect } from 'expo-router';
import { useSelector } from 'react-redux';
import { RootState } from '../../store';
import { Ionicons } from '@expo/vector-icons';
import { Colors } from '../../constants/tokens';
import { View, Text } from 'react-native';

function NotificationBadge({ count }: { count: number }) {
    if (count === 0) return null;
    return (
        <View
            style={{
                position: 'absolute',
                top: -4,
                right: -8,
                backgroundColor: 'red',
                borderRadius: 9999,
                width: 18,
                height: 18,
                justifyContent: 'center',
                alignItems: 'center',
            }}
        >
            <Text style={{ color: '#fff', fontSize: 10, fontWeight: '700' }}>
                {count > 9 ? '9+' : count}
            </Text>
        </View>
    );
}

export default function TabLayout() {
    const { token, mustChangePassword } = useSelector((s: RootState) => s.auth);

    if (!token) return <Redirect href="/(auth)/login" />;
    if (mustChangePassword) return <Redirect href="/(auth)/change-password" />;

    return (
        <Tabs
            screenOptions={{
                tabBarActiveTintColor: Colors.brand.violet,
                tabBarStyle: { borderTopColor: '#e5e7eb' },
                headerStyle: { backgroundColor: Colors.brand.violet },
                headerTintColor: '#fff',
            }}
        >
            <Tabs.Screen
                name="index"
                options={{
                    title: 'Dashboard',
                    tabBarIcon: ({ color, size }) => (
                        <Ionicons name="home-outline" size={size} color={color} />
                    ),
                }}
            />
            <Tabs.Screen
                name="history"
                options={{
                    title: 'History',
                    tabBarIcon: ({ color, size }) => (
                        <Ionicons name="time-outline" size={size} color={color} />
                    ),
                }}
            />
            <Tabs.Screen
                name="documents"
                options={{
                    title: 'Documents',
                    tabBarIcon: ({ color, size }) => (
                        <Ionicons name="document-outline" size={size} color={color} />
                    ),
                }}
            />
            <Tabs.Screen
                name="notifications"
                options={{
                    title: 'Alerts',
                    tabBarIcon: ({ color, size }) => (
                        <Ionicons name="notifications-outline" size={size} color={color} />
                    ),
                }}
            />
            <Tabs.Screen
                name="profile"
                options={{
                    title: 'Profile',
                    tabBarIcon: ({ color, size }) => (
                        <Ionicons name="person-outline" size={size} color={color} />
                    ),
                }}
            />
        </Tabs>
    );
}
```

---

## 9. Authentication Flow

```
App Start
    │
    ├── OTA Check (background, reloads if update found)
    │
    ├── Redux Rehydrate from AsyncStorage
    │
    ├── token === null?  ──▶  Navigate to /login
    │
    ├── mustChangePassword === true?  ──▶  Navigate to /change-password
    │
    └── Navigate to /(tabs)/index (Dashboard)

Login Flow
    │
    ├── POST /tenant/auth/login
    ├── Store token in SecureStore ("auth_token")
    ├── Dispatch setCredentials to Redux
    │
    ├── needsPasswordChange === true?
    │       ├── YES: Navigate to /change-password
    │       └── NO:  Navigate to /(tabs)/index
    │
    └── Error: showToast.error("Invalid credentials")

Change Password Flow
    │
    ├── POST /tenant/change-password
    ├── Dispatch clearMustChangePassword
    └── Navigate to /(tabs)/index
```

### Token Storage Strategy

- **`expo-secure-store`** → `"auth_token"` — encrypted on device, used by Axios interceptor
- **Redux + AsyncStorage** → `authSlice.token` — for UI guards and logout
- On logout: `SecureStore.deleteItemAsync("auth_token")` + `dispatch(clearCredentials())` + `router.replace("/(auth)/login")`

---

## 10. Pages

### 10.1 Login Page

**File**: `app/(auth)/login.tsx`

```tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { KeyboardAvoidingView, ScrollView, View, Text } from 'react-native';
import * as SecureStore from 'expo-secure-store';
import { router } from 'expo-router';
import { useDispatch } from 'react-redux';
import { FormField } from '../../components/ui/FormField';
import { Button } from '../../components/ui/Button';
import { showToast } from '../../components/ui/AppToast';
import { setCredentials } from '../../store/slices/authSlice';
import { loginApi } from '../../api/endpoints/auth.api';

const schema = z.object({
    clientCode: z.string().min(1, 'Client code required'),
    email: z.string().email('Invalid email'),
    password: z.string().min(1, 'Password required'),
});

type FormData = z.infer<typeof schema>;

export default function LoginScreen() {
    const dispatch = useDispatch();
    const {
        control,
        handleSubmit,
        formState: { isSubmitting },
    } = useForm<FormData>({
        resolver: zodResolver(schema),
    });

    const onSubmit = async (values: FormData) => {
        const { data, error } = await loginApi(values);
        if (error || !data) {
            showToast.error('Login failed', error ?? 'Please try again');
            return;
        }
        await SecureStore.setItemAsync('auth_token', data.accessToken);
        dispatch(
            setCredentials({
                token: data.accessToken,
                userId: data.user.id,
                tenantKey: data.user.tenantKey,
                activeFlatId: null,
                mustChangePassword: data.user.needsPasswordChange,
            })
        );
        showToast.success('Welcome back!');
        if (data.user.needsPasswordChange) {
            router.replace('/(auth)/change-password');
        } else {
            router.replace('/(tabs)/');
        }
    };

    return (
        <KeyboardAvoidingView style={{ flex: 1, backgroundColor: '#f5f3ff' }} behavior="padding">
            <ScrollView
                contentContainerStyle={{ flexGrow: 1, justifyContent: 'center', padding: 24 }}
            >
                <Text
                    style={{ fontSize: 28, fontWeight: '800', color: '#7c3aed', marginBottom: 8 }}
                >
                    Tenant Portal
                </Text>
                <Text style={{ fontSize: 14, color: '#6b7280', marginBottom: 32 }}>
                    Sign in to your account
                </Text>
                <FormField
                    control={control}
                    name="clientCode"
                    label="Client Code"
                    placeholder="e.g. PM001"
                />
                <FormField
                    control={control}
                    name="email"
                    label="Email"
                    placeholder="you@example.com"
                    keyboardType="email-address"
                />
                <FormField control={control} name="password" label="Password" secureTextEntry />
                <Button
                    label="Sign In"
                    onPress={handleSubmit(onSubmit)}
                    isLoading={isSubmitting}
                    fullWidth
                />
            </ScrollView>
        </KeyboardAvoidingView>
    );
}
```

### 10.2 Change Password Page

**File**: `app/(auth)/change-password.tsx`

Same pattern as login with 3 fields: `currentPassword`, `newPassword`, `confirmPassword`.

Zod schema:

```ts
const schema = z
    .object({
        currentPassword: z.string().min(1),
        newPassword: z.string().min(8, 'Minimum 8 characters'),
        confirmPassword: z.string(),
    })
    .refine((d) => d.newPassword === d.confirmPassword, {
        message: 'Passwords do not match',
        path: ['confirmPassword'],
    });
```

On success: `dispatch(clearMustChangePassword())`, `router.replace("/(tabs)/")`

### 10.3 Dashboard Page

**File**: `app/(tabs)/index.tsx`

```tsx
// Key sections (full implementation pattern):
useEffect(() => {
    fetchDashboard(activeFlatId);
}, [activeFlatId]);

// Renders:
// 1. FlatSelector
// 2. NotificationCard (latest active notification or "No active notifications" StateCard)
// 3. Payment summary card (total outstanding)
// 4. RentBreakdownCard(s)
// 5. Previous month payment split grid
```

- In "All Flats" mode (`activeFlatId === "all"`): call `getDashboard()` for each flat via `Promise.all`, render one `RentBreakdownCard` per flat.
- Loading state: 3× `<SkeletonCard />`

### 10.4 History Page

**File**: `app/(tabs)/history.tsx`

```tsx
const [page, setPage] = useState(1);

useEffect(() => {
    setPage(1);
}, [activeFlatId]);

useEffect(() => {
    fetchHistory(activeFlatId, page);
}, [activeFlatId, page]);

// Renders:
// 1. FlatSelector
// 2. RentStackedBarChart + RentTrendLineChart (if items.length >= 2)
// 3. RentBreakdownCard per item (sorted newest first)
// 4. SimplePaginator (hidden in All Flats mode)
```

### 10.5 Notifications Page

**File**: `app/(tabs)/notifications.tsx`

```tsx
// Data reused from dashboard endpoint
// Renders:
// Header: "Notifications" + counts (X active · Y expired)
// Section "Active": NotificationCard list (violet/amber gradients)
// Section "Expired": Same cards at opacity 0.6
// Empty state: <StateCard message="No notifications found" variant="empty" />
```

### 10.6 Documents Page

**File**: `app/(tabs)/documents.tsx`

```tsx
import * as FileSystem from 'expo-file-system';
import * as Sharing from 'expo-sharing';
import * as WebBrowser from 'expo-web-browser';

// For "View" button:
const openDocument = async (url: string) => {
    await WebBrowser.openBrowserAsync(url);
};

// Renders:
// 1. "Tenant Documents" section
// 2. "Unit Documents" section grouped by apartment+unit
// Each doc row: filename, upload date, "View" pressable → openDocument(url)
// Empty state: dashed border card with AlertCircle icon
```

### 10.7 Profile Page

**File**: `app/(tabs)/profile.tsx`

```tsx
// Renders 9 InfoField rows in a ScrollView
// Loading: <StateCard message="Loading profile..." />
// Error:   <StateCard message="Unable to load profile" variant="error" />
```

---

## 11. Backend API Contracts

> All existing REST endpoints (`/tenant/*`) work identically for mobile.  
> Additional endpoints/changes needed for React Native:

### 11.1 No New Endpoints Required

The existing API surface is fully compatible. Axios on mobile sends identical JSON and headers.

### 11.2 Required Backend Configuration

```
1. CORS — add mobile deep-link schemes to allowed origins:
   Allow-Origin: tenantportal://*

2. Token TTL — consider longer expiry for mobile sessions
   (web: session-based, mobile: 30-day refresh token pattern recommended)

3. Push Notifications (future) — add endpoint:
   POST /tenant/device-token
   Body: { deviceToken: string, platform: "ios" | "android" }
   Purpose: Register Expo push token for server-sent notifications
```

### 11.3 Refresh Token Flow (Recommended for Mobile)

```
Current (web): Single access token, session clears on browser close

Recommended for mobile:
  POST /tenant/auth/login → { accessToken (15min), refreshToken (30d) }
  POST /tenant/auth/refresh → { accessToken } (call when 401 received)

Implementation:
  Store refreshToken in SecureStore("refresh_token")
  In Axios response interceptor (401):
    1. Call /tenant/auth/refresh with refreshToken
    2. If success: update accessToken, retry original request
    3. If failure: logout user
```

### 11.4 Recommended Backend Tech Stack

| Layer              | Technology                              | Notes                                            |
| ------------------ | --------------------------------------- | ------------------------------------------------ |
| Runtime            | **Node.js 20 LTS**                      | Same as current                                  |
| Framework          | **NestJS** (preferred) or Express       | NestJS provides decorators, guards, interceptors |
| Language           | **TypeScript**                          | Strict mode                                      |
| ORM                | **TypeORM** or **Prisma**               | Multi-tenant schema support                      |
| Database           | **PostgreSQL**                          | Per-client schema or row-level tenancy           |
| Auth               | **JWT** (access + refresh)              | `@nestjs/jwt`, `passport-jwt`                    |
| Password           | **bcrypt** (salt ≥ 12)                  | Same as current                                  |
| File Storage       | **AWS S3** + pre-signed URLs            | 30-min expiry for documents                      |
| Validation         | **class-validator + class-transformer** | DTOs for all endpoints                           |
| Caching            | **Redis** (optional)                    | Dashboard response caching per flat              |
| Push Notifications | **Expo Server SDK** (`expo-server-sdk`) | For future push support                          |

### 11.5 NestJS Module Structure (Backend)

```
backend/
├── src/
│   ├── modules/
│   │   ├── auth/
│   │   │   ├── auth.module.ts
│   │   │   ├── auth.controller.ts    # POST /tenant/auth/login, /refresh
│   │   │   ├── auth.service.ts
│   │   │   └── strategies/
│   │   │       └── jwt.strategy.ts
│   │   ├── tenant/
│   │   │   ├── tenant.module.ts
│   │   │   ├── dashboard.controller.ts   # GET /tenant/dashboard
│   │   │   ├── history.controller.ts     # GET /tenant/history
│   │   │   ├── profile.controller.ts     # GET /tenant/profile
│   │   │   ├── documents.controller.ts   # GET /tenant/documents
│   │   │   └── change-password.controller.ts
│   │   └── notifications/
│   │       └── device-token.controller.ts # POST /tenant/device-token
│   ├── guards/
│   │   ├── jwt-auth.guard.ts
│   │   └── tenant-active.guard.ts
│   ├── interceptors/
│   │   └── client-db.interceptor.ts   # Multi-tenant DB routing
│   ├── common/
│   │   ├── dto/
│   │   └── utils/
│   └── main.ts
```

### 11.6 Guards to Implement

```typescript
// guards/tenant-active.guard.ts
// Verifies tenant isActive === true in their client's DB
// Apply with @UseGuards(JwtAuthGuard, TenantActiveGuard)

// guards/must-change-password.guard.ts
// Blocks all routes except /change-password if mustChangePassword === true
// Prevents API abuse by skipping forced password change
```

---

## 12. OTA Update Strategy

### 12.1 EAS Update Channels

```bash
# Create channels
eas update:configure

# Channels:
# production  → released app store builds
# preview     → internal testing builds
# development → local simulator builds
```

### 12.2 Push an OTA Update

```bash
# Push update to production channel
eas update --channel production --message "Fix dashboard chart render"

# Preview before push
eas update --channel preview --message "Test new FlatSelector"
```

### 12.3 Runtime OTA Logic (in Root Layout)

```typescript
// Strategy: Check on app foreground, apply silently
// From app/_layout.tsx (already shown above)

// For critical updates, show a user-facing alert before reload:
const update = await Updates.checkForUpdateAsync();
if (update.isAvailable) {
    Alert.alert('Update Available', 'A new version is ready. Restart to apply?', [
        { text: 'Later' },
        {
            text: 'Restart',
            onPress: async () => {
                await Updates.fetchUpdateAsync();
                await Updates.reloadAsync();
            },
        },
    ]);
}
```

### 12.4 What OTA Can and Cannot Update

| Can Update via OTA               | Cannot Update via OTA               |
| -------------------------------- | ----------------------------------- |
| All JavaScript / TypeScript code | Native modules (new expo plugins)   |
| UI components and screens        | `app.json` config changes           |
| API endpoint URLs                | Permissions (camera, notifications) |
| Business logic                   | App icons / splash screen           |
| Bug fixes                        | Expo SDK upgrades                   |

> Rule: Any change that doesn't touch native code = OTA push. Native changes = full app store build via EAS Build.

---

## 13. Environment & Config

### `.env` files

```bash
# .env.local (development)
EXPO_PUBLIC_API_URL=http://localhost:3000

# .env.production
EXPO_PUBLIC_API_URL=https://api.tenant.app.com
```

> Expo automatically reads `EXPO_PUBLIC_*` variables at build time. Access via `process.env.EXPO_PUBLIC_API_URL`.

### `eas.json`

```json
{
    "cli": { "version": ">= 5.0.0" },
    "build": {
        "development": {
            "developmentClient": true,
            "distribution": "internal",
            "env": { "EXPO_PUBLIC_API_URL": "http://localhost:3000" }
        },
        "preview": {
            "distribution": "internal",
            "env": { "EXPO_PUBLIC_API_URL": "https://staging-api.tenant.app.com" }
        },
        "production": {
            "env": { "EXPO_PUBLIC_API_URL": "https://api.tenant.app.com" }
        }
    },
    "update": {
        "production": { "channel": "production" },
        "preview": { "channel": "preview" }
    }
}
```

---

## 14. Testing Checklist

### Auth

- [ ] Login with valid clientCode + email + password → Dashboard
- [ ] Login with wrong credentials → error toast, no navigation
- [ ] Login with `needsPasswordChange: true` → Change Password screen
- [ ] Change Password with mismatched confirm → inline validation error
- [ ] Change Password success → Dashboard, no redirect on next login
- [ ] Token expiry / 401 → SecureStore cleared, navigate to Login

### Dashboard

- [ ] Single flat: correct rent breakdown displayed
- [ ] Multi-flat: FlatSelector shows all options + "All Flats"
- [ ] All Flats mode: one card per flat rendered
- [ ] Notification banner shows latest active notification
- [ ] No notifications: shows "No active notifications" card
- [ ] Maintenance expand toggle works
- [ ] Previous Dues row only shows if > 0

### History

- [ ] Paginated correctly (10 per page, Prev/Next work)
- [ ] Charts render if 2+ history items
- [ ] Switching flat resets to page 1
- [ ] All Flats mode: no pagination, all data merged

### Notifications

- [ ] Active and Expired sections shown correctly
- [ ] Personal = violet gradient, Apartment-wide = amber gradient
- [ ] Expired = dimmed

### Documents

- [ ] "View" link opens pre-signed URL in browser
- [ ] No flat selector shown
- [ ] Empty state shown if no documents

### Profile

- [ ] All 9 fields displayed, "-" for empty optionals
- [ ] Aadhaar and PAN are masked

### OTA

- [ ] New bundle pushed to preview → app reloads on next launch
- [ ] Production bundle pushed → app reloads silently

### Cross-platform

- [ ] iOS: BottomSheet, SecureStore, tab bar behavior
- [ ] Android: Back button handling, status bar color, gesture conflicts
- [ ] Tablet: Verify readable layout (consider side-by-side columns on large screens)

---

_Generated: April 2026 | Stack: Expo SDK 51 + Expo Router v3 + EAS Update_