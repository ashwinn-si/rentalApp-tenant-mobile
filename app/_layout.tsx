import 'react-native-reanimated';

import { useEffect } from 'react';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { Provider } from 'react-redux';
import { PersistGate } from 'redux-persist/integration/react';
import { Slot, useRouter, useSegments } from 'expo-router';
import { SafeAreaProvider } from 'react-native-safe-area-context';

import { getSecureToken } from '../api/secureToken';
import { AppLoader } from '../components/ui/AppLoader';
import { AppToastHost } from '../components/ui/AppToast';
import { useAppDispatch, useAppSelector } from '../store';
import { persistor, store } from '../store';
import { clearAuth, setBootstrapped } from '../store/slices/authSlice';

function AuthGate() {
    const router = useRouter();
    const segments = useSegments();
    const dispatch = useAppDispatch();
    const isAuthenticated = useAppSelector((state) => state.auth.isAuthenticated);
    const isBootstrapped = useAppSelector((state) => state.auth.isBootstrapped);
    const mustChangePassword = useAppSelector((state) => state.auth.mustChangePassword);

    useEffect(() => {
        let mounted = true;

        async function bootstrapAuth() {
            try {
                const token = await getSecureToken();
                if (!token) {
                    dispatch(clearAuth());
                }
            } finally {
                if (mounted) {
                    dispatch(setBootstrapped(true));
                }
            }
        }

        bootstrapAuth();

        return () => {
            mounted = false;
        };
    }, [dispatch]);

    useEffect(() => {
        if (!isBootstrapped) {
            return;
        }

        const inAuthGroup = segments[0] === '(auth)';

        if (isAuthenticated && mustChangePassword && segments[1] !== 'change-password') {
            router.replace('/(auth)/change-password');
            return;
        }

        if (!isAuthenticated && !inAuthGroup) {
            router.replace('/(auth)/login');
            return;
        }

        if (isAuthenticated && inAuthGroup) {
            router.replace(
                mustChangePassword
                    ? '/(auth)/change-password'
                    : '/(tabs)'
            );
        }
    }, [isAuthenticated, isBootstrapped, mustChangePassword, segments, router]);

    if (!isBootstrapped) {
        return <AppLoader />;
    }

    return <Slot />;
}

export default function RootLayout() {
    return (
        <GestureHandlerRootView style={{ flex: 1 }}>
            <SafeAreaProvider>
                <Provider store={store}>
                    <PersistGate loading={<AppLoader />} persistor={persistor}>
                        <AuthGate />
                        <AppToastHost />
                    </PersistGate>
                </Provider>
            </SafeAreaProvider>
        </GestureHandlerRootView>
    );
}
