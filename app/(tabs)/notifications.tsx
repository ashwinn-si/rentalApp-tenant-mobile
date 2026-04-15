import { useEffect, useState } from 'react';
import { ScrollView, View, Text, ActivityIndicator } from 'react-native';
import { getNotifications, type NotificationsResponse } from '../../api/endpoints/notifications.api';
import { StateCard } from '../../components/ui/StateCard';
import { colors, spacing } from '../../constants/tokens';

export default function NotificationsScreen() {
    const [notifications, setNotifications] = useState<NotificationsResponse | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        fetchNotifications();
    }, []);

    const fetchNotifications = async () => {
        try {
            setLoading(true);
            setError(null);
            const data = await getNotifications();
            setNotifications(data);
        } catch (err) {
            setError(err instanceof Error ? err.message : 'Failed to load notifications');
        } finally {
            setLoading(false);
        }
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

    if (!notifications) {
        return (
            <ScrollView
                style={{ flex: 1, backgroundColor: colors.background, padding: spacing.lg }}
            >
                <StateCard message="No notifications available" variant="empty" />
            </ScrollView>
        );
    }

    const hasNotifications = notifications.active.length > 0 || notifications.expired.length > 0;

    return (
        <ScrollView style={{ flex: 1, backgroundColor: colors.background }}>
            <View style={{ padding: spacing.lg }}>
                <View
                    style={{
                        marginBottom: spacing.lg,
                        paddingBottom: spacing.md,
                        borderBottomWidth: 1,
                        borderBottomColor: colors.border,
                    }}
                >
                    <Text
                        style={{
                            fontSize: 24,
                            fontWeight: '700',
                            color: colors.textPrimary,
                            marginBottom: spacing.sm,
                        }}
                    >
                        Notifications
                    </Text>
                    <Text style={{ fontSize: 12, color: colors.textSecondary }}>
                        {notifications.active.length} active · {notifications.expired.length}{' '}
                        expired
                    </Text>
                </View>

                {!hasNotifications ? (
                    <StateCard message="No notifications found" variant="empty" />
                ) : (
                    <>
                        {/* Active Notifications */}
                        {notifications.active.length > 0 && (
                            <View style={{ marginBottom: spacing.lg }}>
                                <Text
                                    style={{
                                        fontSize: 14,
                                        fontWeight: '600',
                                        color: colors.textPrimary,
                                        marginBottom: spacing.md,
                                    }}
                                >
                                    Active
                                </Text>
                                {notifications.active.map((notif) => (
                                    <View
                                        key={notif.id}
                                        style={{
                                            backgroundColor: colors.surface,
                                            borderRadius: 12,
                                            padding: spacing.md,
                                            marginBottom: spacing.md,
                                            borderLeftWidth: 4,
                                            borderLeftColor:
                                                notif.type === 'personal'
                                                    ? colors.brandViolet
                                                    : colors.warning,
                                        }}
                                    >
                                        <View
                                            style={{
                                                flexDirection: 'row',
                                                justifyContent: 'space-between',
                                                marginBottom: spacing.sm,
                                            }}
                                        >
                                            <Text
                                                style={{
                                                    fontSize: 14,
                                                    fontWeight: '600',
                                                    color: colors.textPrimary,
                                                    flex: 1,
                                                    marginRight: spacing.sm,
                                                }}
                                            >
                                                {notif.title}
                                            </Text>
                                            <Text
                                                style={{
                                                    fontSize: 10,
                                                    color: colors.textSecondary,
                                                    fontWeight: '500',
                                                }}
                                            >
                                                {notif.type}
                                            </Text>
                                        </View>
                                        <Text
                                            style={{
                                                fontSize: 12,
                                                color: colors.textSecondary,
                                                lineHeight: 18,
                                                marginBottom: spacing.sm,
                                            }}
                                        >
                                            {notif.message}
                                        </Text>
                                        <Text
                                            style={{
                                                fontSize: 10,
                                                color: colors.textSecondary,
                                            }}
                                        >
                                            {new Date(notif.createdAt).toLocaleDateString()}
                                        </Text>
                                    </View>
                                ))}
                            </View>
                        )}

                        {/* Expired Notifications */}
                        {notifications.expired.length > 0 && (
                            <View>
                                <Text
                                    style={{
                                        fontSize: 14,
                                        fontWeight: '600',
                                        color: colors.textSecondary,
                                        marginBottom: spacing.md,
                                    }}
                                >
                                    Expired
                                </Text>
                                {notifications.expired.map((notif) => (
                                    <View
                                        key={notif.id}
                                        style={{
                                            backgroundColor: colors.surface,
                                            borderRadius: 12,
                                            padding: spacing.md,
                                            marginBottom: spacing.md,
                                            opacity: 0.6,
                                            borderLeftWidth: 4,
                                            borderLeftColor: colors.textSecondary,
                                        }}
                                    >
                                        <View
                                            style={{
                                                flexDirection: 'row',
                                                justifyContent: 'space-between',
                                                marginBottom: spacing.sm,
                                            }}
                                        >
                                            <Text
                                                style={{
                                                    fontSize: 14,
                                                    fontWeight: '600',
                                                    color: colors.textPrimary,
                                                    flex: 1,
                                                    marginRight: spacing.sm,
                                                }}
                                            >
                                                {notif.title}
                                            </Text>
                                            <Text
                                                style={{
                                                    fontSize: 10,
                                                    color: colors.textSecondary,
                                                    fontWeight: '500',
                                                }}
                                            >
                                                {notif.type}
                                            </Text>
                                        </View>
                                        <Text
                                            style={{
                                                fontSize: 12,
                                                color: colors.textSecondary,
                                                lineHeight: 18,
                                                marginBottom: spacing.sm,
                                            }}
                                        >
                                            {notif.message}
                                        </Text>
                                        <Text
                                            style={{
                                                fontSize: 10,
                                                color: colors.textSecondary,
                                            }}
                                        >
                                            {new Date(notif.createdAt).toLocaleDateString()}
                                        </Text>
                                    </View>
                                ))}
                            </View>
                        )}
                    </>
                )}
            </View>
        </ScrollView>
    );
}
