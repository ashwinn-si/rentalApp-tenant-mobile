import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { KeyboardAvoidingView, ScrollView, View, Text, Platform } from 'react-native';
import { router } from 'expo-router';

import { FormField } from '../../components/ui/FormField';
import { Button } from '../../components/ui/Button';
import { showToast } from '../../components/ui/AppToast';
import { useAppDispatch } from '../../store';
import { clearAuth } from '../../store/slices/authSlice';
import { changePassword } from '../../api/endpoints/auth.api';
import * as SecureStore from 'expo-secure-store';
import { colors, spacing } from '../../constants/tokens';

const schema = z
    .object({
        currentPassword: z.string().min(1, 'Current password required'),
        newPassword: z.string().min(8, 'Minimum 8 characters'),
        confirmPassword: z.string(),
    })
    .refine((d) => d.newPassword === d.confirmPassword, {
        message: 'Passwords do not match',
        path: ['confirmPassword'],
    });

type FormData = z.infer<typeof schema>;

export default function ChangePasswordScreen() {
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
            await changePassword({
                currentPassword: values.currentPassword,
                newPassword: values.newPassword,
            });
            showToast.success('Password changed successfully');
            await SecureStore.deleteItemAsync('auth_token');
            dispatch(clearAuth());
            router.replace('/(auth)/login');
        } catch (error) {
            const errorMessage = error instanceof Error ? error.message : 'Failed to change password';
            showToast.error('Error', errorMessage);
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
                        Change Password
                    </Text>
                    <Text style={{ fontSize: 14, color: colors.textSecondary }}>
                        Update your password to continue
                    </Text>
                </View>

                <FormField
                    control={control}
                    name="currentPassword"
                    label="Current Password"
                    placeholder="••••••••"
                    secureTextEntry
                />
                <FormField
                    control={control}
                    name="newPassword"
                    label="New Password"
                    placeholder="••••••••"
                    secureTextEntry
                />
                <FormField
                    control={control}
                    name="confirmPassword"
                    label="Confirm Password"
                    placeholder="••••••••"
                    secureTextEntry
                />

                <View style={{ marginTop: spacing.lg }}>
                    <Button onPress={handleSubmit(onSubmit)} loading={isSubmitting}>
                        Update Password
                    </Button>
                </View>
            </ScrollView>
        </KeyboardAvoidingView>
    );
}
