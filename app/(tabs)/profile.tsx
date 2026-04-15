import { useEffect, useState } from 'react';
import { ScrollView, View, Text, ActivityIndicator, Pressable, Alert } from 'react-native';
import { router } from 'expo-router';
import * as SecureStore from 'expo-secure-store';
import { getProfile, type ProfileResponse } from '../../api/endpoints/profile.api';
import { StateCard } from '../../components/ui/StateCard';
import { InfoField } from '../../components/ui/InfoField';
import { useAppDispatch } from '../../store';
import { clearAuth } from '../../store/slices/authSlice';
import { colors, spacing } from '../../constants/tokens';

export default function ProfileScreen() {
    const [profile, setProfile] = useState<ProfileResponse | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const dispatch = useAppDispatch();

    useEffect(() => {
        fetchProfile();
    }, []);

    const fetchProfile = async () => {
        try {
            setLoading(true);
            setError(null);
            const data = await getProfile();
            setProfile(data);
        } catch (err) {
            setError(err instanceof Error ? err.message : 'Failed to load profile');
        } finally {
            setLoading(false);
        }
    };

    const handleLogout = () => {
        Alert.alert('Logout', 'Are you sure you want to logout?', [
            { text: 'Cancel', style: 'cancel' },
            {
                text: 'Logout',
                style: 'destructive',
                onPress: async () => {
                    await SecureStore.deleteItemAsync('auth_token');
                    dispatch(clearAuth());
                    router.replace('/(auth)/login');
                },
            },
        ]);
    };

    if (loading) {
        return (
            <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
                <ActivityIndicator size="large" color={colors.brandViolet} />
            </View>
        );
    }

    if (error) {
        return (
            <ScrollView
                style={{ flex: 1, backgroundColor: colors.background, padding: spacing.lg }}
            >
                <StateCard message={error} variant="error" />
            </ScrollView>
        );
    }

    if (!profile) {
        return (
            <ScrollView
                style={{ flex: 1, backgroundColor: colors.background, padding: spacing.lg }}
            >
                <StateCard message="Unable to load profile" variant="error" />
            </ScrollView>
        );
    }

    return (
        <ScrollView style={{ flex: 1, backgroundColor: colors.background }}>
            <View style={{ padding: spacing.lg }}>
                {/* Profile Header */}
                <View
                    style={{
                        backgroundColor: colors.surface,
                        borderRadius: 12,
                        padding: spacing.lg,
                        marginBottom: spacing.lg,
                        alignItems: 'center',
                    }}
                >
                    <View
                        style={{
                            width: 80,
                            height: 80,
                            borderRadius: 40,
                            backgroundColor: colors.brandViolet,
                            justifyContent: 'center',
                            alignItems: 'center',
                            marginBottom: spacing.md,
                        }}
                    >
                        <Text style={{ fontSize: 32, color: '#fff' }}>👤</Text>
                    </View>
                    <Text
                        style={{
                            fontSize: 20,
                            fontWeight: '700',
                            color: colors.textPrimary,
                        }}
                    >
                        {profile.name}
                    </Text>
                    <Text style={{ fontSize: 12, color: colors.textSecondary }}>
                        {profile.email}
                    </Text>
                </View>

                {/* Profile Fields */}
                <View
                    style={{
                        backgroundColor: colors.surface,
                        borderRadius: 12,
                        padding: spacing.lg,
                        marginBottom: spacing.lg,
                    }}
                >
                    <InfoField label="Email" value={profile.email} />
                    <InfoField label="Name" value={profile.name} />
                    <InfoField label="Phone" value={profile.phone} />
                    <InfoField label="Client Code" value={profile.clientCode} />
                    <InfoField label="Tenant ID" value={profile.tenantId} />

                    {profile.flats && profile.flats.length > 0 && (
                        <View style={{ marginTop: spacing.md }}>
                            <Text
                                style={{
                                    fontSize: 12,
                                    color: colors.textSecondary,
                                    marginBottom: spacing.md,
                                }}
                            >
                                Assigned Units
                            </Text>
                            {profile.flats.map((flat) => (
                                <View
                                    key={flat.flatId}
                                    style={{
                                        backgroundColor: colors.background,
                                        borderRadius: 8,
                                        padding: spacing.md,
                                        marginBottom: spacing.sm,
                                    }}
                                >
                                    <Text
                                        style={{
                                            fontSize: 13,
                                            color: colors.textPrimary,
                                            fontWeight: '500',
                                        }}
                                    >
                                        {flat.flatName}
                                    </Text>
                                </View>
                            ))}
                        </View>
                    )}
                </View>

                {/* Logout Button */}
                <Pressable
                    onPress={handleLogout}
                    style={{
                        backgroundColor: colors.danger,
                        borderRadius: 12,
                        paddingVertical: spacing.md,
                        alignItems: 'center',
                    }}
                >
                    <Text style={{ color: '#fff', fontWeight: '600', fontSize: 16 }}>
                        Logout
                    </Text>
                </Pressable>
            </View>
        </ScrollView>
    );
}
