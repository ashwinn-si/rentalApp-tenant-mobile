import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { KeyboardAvoidingView, ScrollView, View, Text, Platform } from 'react-native';
import * as SecureStore from 'expo-secure-store';
import { router } from 'expo-router';

import { FormField } from '../../components/ui/FormField';
import { Button } from '../../components/ui/Button';
import { showToast } from '../../components/ui/AppToast';
import { useAppDispatch } from '../../store';
import { setAuthenticated } from '../../store/slices/authSlice';
import { login } from '../../api/endpoints/auth.api';
import { colors, spacing } from '../../constants/tokens';

const schema = z.object({
    clientCode: z.string().min(1, 'Client code required'),
    email: z.string().email('Invalid email'),
    password: z.string().min(1, 'Password required'),
});

type FormData = z.infer<typeof schema>;

export default function LoginScreen() {
    const dispatch = useAppDispatch();
    const {
        control,
        handleSubmit,
        formState: { isSubmitting },
    } = useForm<FormData>({
        resolver: zodResolver(schema),
    });

    const onSubmit = async (values: FormData) => {
        try {
            const response = await login(values);
            await SecureStore.setItemAsync('auth_token', response.token);
            dispatch(
                setAuthenticated({
                    user: response.user,
                    token: response.token,
                    mustChangePassword: response.mustChangePassword || false,
                })
            );
            showToast.success('Welcome back!');
            if (response.mustChangePassword) {
                router.replace('/(auth)/change-password');
            } else {
                router.replace('/(tabs)');
            }
        } catch (error) {
            const errorMessage = error instanceof Error ? error.message : 'Login failed';
            showToast.error('Login failed', errorMessage);
        }
    };

    return (
        <KeyboardAvoidingView
            style={{ flex: 1, backgroundColor: colors.background }}
            behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        >
            <ScrollView
                contentContainerStyle={{
                    flexGrow: 1,
                    justifyContent: 'center',
                    paddingHorizontal: spacing.lg,
                }}
            >
                <View style={{ marginBottom: spacing.xl }}>
                    <Text
                        style={{
                            fontSize: 28,
                            fontWeight: '800',
                            color: colors.brandViolet,
                            marginBottom: spacing.sm,
                        }}
                    >
                        Tenant Portal
                    </Text>
                    <Text style={{ fontSize: 14, color: colors.textSecondary }}>
                        Sign in to your account
                    </Text>
                </View>

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
                <FormField
                    control={control}
                    name="password"
                    label="Password"
                    placeholder="••••••••"
                    secureTextEntry
                />

                <View style={{ marginTop: spacing.lg }}>
                    <Button onPress={handleSubmit(onSubmit)} loading={isSubmitting}>
                        Sign In
                    </Button>
                </View>
            </ScrollView>
        </KeyboardAvoidingView>
    );
}
