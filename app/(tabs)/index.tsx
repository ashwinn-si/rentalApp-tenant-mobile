import { useEffect, useState } from 'react';
import { ScrollView, View, Text, ActivityIndicator } from 'react-native';
import { getDashboard, type DashboardResponse } from '../../api/endpoints/dashboard.api';
import { StateCard } from '../../components/ui/StateCard';
import { colors, spacing } from '../../constants/tokens';

export default function DashboardScreen() {
    const [dashboard, setDashboard] = useState<DashboardResponse | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        fetchDashboard();
    }, []);

    const fetchDashboard = async () => {
        try {
            setLoading(true);
            setError(null);
            const data = await getDashboard('all');
            setDashboard(data);
        } catch (err) {
            setError(err instanceof Error ? err.message : 'Failed to load dashboard');
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

    if (!dashboard) {
        return (
            <ScrollView
                style={{ flex: 1, backgroundColor: colors.background, padding: spacing.lg }}
            >
                <StateCard message="No data available" variant="empty" />
            </ScrollView>
        );
    }

    return (
        <ScrollView style={{ flex: 1, backgroundColor: colors.background }}>
            <View style={{ padding: spacing.lg }}>
                <Text
                    style={{
                        fontSize: 24,
                        fontWeight: '700',
                        color: colors.textPrimary,
                        marginBottom: spacing.md,
                    }}
                >
                    {dashboard.flatName}
                </Text>

                {/* Payment Status Card */}
                <View
                    style={{
                        backgroundColor: colors.surface,
                        borderRadius: 12,
                        padding: spacing.lg,
                        marginBottom: spacing.lg,
                        borderLeftWidth: 4,
                        borderLeftColor: colors.brandViolet,
                    }}
                >
                    <Text style={{ fontSize: 12, color: colors.textSecondary, marginBottom: 4 }}>
                        Current Status
                    </Text>
                    <Text
                        style={{
                            fontSize: 28,
                            fontWeight: '700',
                            color: colors.brandViolet,
                            marginBottom: spacing.sm,
                        }}
                    >
                        ₹{dashboard.currentPaymentStatus.amount.toLocaleString()}
                    </Text>
                    <Text style={{ fontSize: 14, color: colors.textSecondary }}>
                        {dashboard.currentPaymentStatus.status.toUpperCase()}
                    </Text>
                </View>

                {/* Outstanding Amount */}
                {dashboard.totalOutstanding > 0 && (
                    <View
                        style={{
                            backgroundColor: '#fee2e2',
                            borderRadius: 12,
                            padding: spacing.lg,
                            marginBottom: spacing.lg,
                        }}
                    >
                        <Text style={{ fontSize: 12, color: '#991b1b', marginBottom: 4 }}>
                            Total Outstanding
                        </Text>
                        <Text
                            style={{
                                fontSize: 24,
                                fontWeight: '700',
                                color: '#dc2626',
                            }}
                        >
                            ₹{dashboard.totalOutstanding.toLocaleString()}
                        </Text>
                    </View>
                )}

                {/* Rent Breakdown */}
                {dashboard.rentBreakdown.length > 0 && (
                    <View>
                        <Text
                            style={{
                                fontSize: 16,
                                fontWeight: '600',
                                color: colors.textPrimary,
                                marginBottom: spacing.md,
                            }}
                        >
                            Rent Breakdown
                        </Text>
                        {dashboard.rentBreakdown.map((item, idx) => (
                            <View
                                key={idx}
                                style={{
                                    backgroundColor: colors.surface,
                                    borderRadius: 12,
                                    padding: spacing.md,
                                    marginBottom: spacing.md,
                                }}
                            >
                                <Text
                                    style={{
                                        fontSize: 14,
                                        fontWeight: '600',
                                        color: colors.textPrimary,
                                        marginBottom: spacing.sm,
                                    }}
                                >
                                    {item.month}
                                </Text>
                                <View
                                    style={{
                                        flexDirection: 'row',
                                        justifyContent: 'space-between',
                                        paddingVertical: 4,
                                    }}
                                >
                                    <Text style={{ color: colors.textSecondary, fontSize: 12 }}>
                                        Base Rent
                                    </Text>
                                    <Text
                                        style={{
                                            color: colors.textPrimary,
                                            fontWeight: '600',
                                            fontSize: 12,
                                        }}
                                    >
                                        ₹{item.baseRent.toLocaleString()}
                                    </Text>
                                </View>
                                {item.utility && (
                                    <View
                                        style={{
                                            flexDirection: 'row',
                                            justifyContent: 'space-between',
                                            paddingVertical: 4,
                                        }}
                                    >
                                        <Text style={{ color: colors.textSecondary, fontSize: 12 }}>
                                            Utility
                                        </Text>
                                        <Text
                                            style={{
                                                color: colors.textPrimary,
                                                fontWeight: '600',
                                                fontSize: 12,
                                            }}
                                        >
                                            ₹{item.utility.toLocaleString()}
                                        </Text>
                                    </View>
                                )}
                                {item.maintenance && (
                                    <View
                                        style={{
                                            flexDirection: 'row',
                                            justifyContent: 'space-between',
                                            paddingVertical: 4,
                                        }}
                                    >
                                        <Text style={{ color: colors.textSecondary, fontSize: 12 }}>
                                            Maintenance
                                        </Text>
                                        <Text
                                            style={{
                                                color: colors.textPrimary,
                                                fontWeight: '600',
                                                fontSize: 12,
                                            }}
                                        >
                                            ₹{item.maintenance.toLocaleString()}
                                        </Text>
                                    </View>
                                )}
                            </View>
                        ))}
                    </View>
                )}
            </View>
        </ScrollView>
    );
}
