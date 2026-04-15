import { useEffect, useState } from 'react';
import { ScrollView, View, Text, ActivityIndicator, Pressable } from 'react-native';
import { getHistory, type HistoryResponse } from '../../api/endpoints/history.api';
import { StateCard } from '../../components/ui/StateCard';
import { colors, spacing } from '../../constants/tokens';

export default function HistoryScreen() {
    const [history, setHistory] = useState<HistoryResponse | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const [page, setPage] = useState(1);

    useEffect(() => {
        fetchHistory(page);
    }, [page]);

    const fetchHistory = async (pageNum: number) => {
        try {
            setLoading(true);
            setError(null);
            const data = await getHistory('all', pageNum);
            setHistory(data);
        } catch (err) {
            setError(err instanceof Error ? err.message : 'Failed to load history');
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

    if (!history || history.items.length === 0) {
        return (
            <ScrollView
                style={{ flex: 1, backgroundColor: colors.background, padding: spacing.lg }}
            >
                <StateCard message="No rent history available" variant="empty" />
            </ScrollView>
        );
    }

    return (
        <ScrollView style={{ flex: 1, backgroundColor: colors.background }}>
            <View style={{ padding: spacing.lg }}>
                <Text
                    style={{
                        fontSize: 20,
                        fontWeight: '700',
                        color: colors.textPrimary,
                        marginBottom: spacing.lg,
                    }}
                >
                    Rent History
                </Text>

                {/* History Items */}
                {history.items.map((item) => (
                    <View
                        key={item.id}
                        style={{
                            backgroundColor: colors.surface,
                            borderRadius: 12,
                            padding: spacing.md,
                            marginBottom: spacing.md,
                            borderLeftWidth: 4,
                            borderLeftColor:
                                item.status === 'paid'
                                    ? colors.success
                                    : item.status === 'partial'
                                      ? colors.warning
                                      : colors.danger,
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
                                }}
                            >
                                {item.month}
                            </Text>
                            <Text
                                style={{
                                    fontSize: 14,
                                    fontWeight: '600',
                                    color:
                                        item.status === 'paid'
                                            ? colors.success
                                            : item.status === 'partial'
                                              ? colors.warning
                                              : colors.danger,
                                }}
                            >
                                {item.status.toUpperCase()}
                            </Text>
                        </View>

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

                        <View
                            style={{
                                borderTopColor: colors.border,
                                borderTopWidth: 1,
                                marginTop: spacing.sm,
                                paddingTop: spacing.sm,
                            }}
                        >
                            <View
                                style={{
                                    flexDirection: 'row',
                                    justifyContent: 'space-between',
                                }}
                            >
                                <Text
                                    style={{
                                        color: colors.textPrimary,
                                        fontWeight: '700',
                                        fontSize: 14,
                                    }}
                                >
                                    Total
                                </Text>
                                <Text
                                    style={{
                                        color: colors.textPrimary,
                                        fontWeight: '700',
                                        fontSize: 14,
                                    }}
                                >
                                    ₹{item.total.toLocaleString()}
                                </Text>
                            </View>
                        </View>
                    </View>
                ))}

                {/* Pagination */}
                <View
                    style={{
                        flexDirection: 'row',
                        justifyContent: 'space-between',
                        paddingVertical: spacing.lg,
                    }}
                >
                    <Pressable
                        onPress={() => setPage(Math.max(1, page - 1))}
                        disabled={page === 1}
                        style={{
                            paddingHorizontal: spacing.md,
                            paddingVertical: spacing.sm,
                            backgroundColor: page === 1 ? colors.border : colors.brandViolet,
                            borderRadius: 8,
                        }}
                    >
                        <Text
                            style={{
                                color: page === 1 ? colors.textSecondary : '#fff',
                                fontWeight: '600',
                            }}
                        >
                            ← Previous
                        </Text>
                    </Pressable>

                    <Text
                        style={{
                            alignSelf: 'center',
                            color: colors.textSecondary,
                            fontSize: 12,
                        }}
                    >
                        Page {page} of {Math.ceil(history.total / history.limit)}
                    </Text>

                    <Pressable
                        onPress={() => setPage(page + 1)}
                        disabled={page >= Math.ceil(history.total / history.limit)}
                        style={{
                            paddingHorizontal: spacing.md,
                            paddingVertical: spacing.sm,
                            backgroundColor:
                                page >= Math.ceil(history.total / history.limit)
                                    ? colors.border
                                    : colors.brandViolet,
                            borderRadius: 8,
                        }}
                    >
                        <Text
                            style={{
                                color:
                                    page >= Math.ceil(history.total / history.limit)
                                        ? colors.textSecondary
                                        : '#fff',
                                fontWeight: '600',
                            }}
                        >
                            Next →
                        </Text>
                    </Pressable>
                </View>
            </View>
        </ScrollView>
    );
}
