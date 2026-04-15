import { useEffect, useState } from 'react';
import { ScrollView, View, Text, ActivityIndicator, Pressable, Alert } from 'react-native';
import * as WebBrowser from 'expo-web-browser';
import { getDocuments, type DocumentsResponse } from '../../api/endpoints/documents.api';
import { StateCard } from '../../components/ui/StateCard';
import { colors, spacing } from '../../constants/tokens';

export default function DocumentsScreen() {
    const [documents, setDocuments] = useState<DocumentsResponse | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        fetchDocuments();
    }, []);

    const fetchDocuments = async () => {
        try {
            setLoading(true);
            setError(null);
            const data = await getDocuments();
            setDocuments(data);
        } catch (err) {
            setError(err instanceof Error ? err.message : 'Failed to load documents');
        } finally {
            setLoading(false);
        }
    };

    const openDocument = async (url: string, filename: string) => {
        try {
            await WebBrowser.openBrowserAsync(url);
        } catch (err) {
            Alert.alert('Error', 'Unable to open document');
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

    if (
        !documents ||
        (documents.tenantDocuments.length === 0 && documents.unitDocuments.length === 0)
    ) {
        return (
            <ScrollView
                style={{ flex: 1, backgroundColor: colors.background, padding: spacing.lg }}
            >
                <StateCard message="No documents available" variant="empty" />
            </ScrollView>
        );
    }

    return (
        <ScrollView style={{ flex: 1, backgroundColor: colors.background }}>
            <View style={{ padding: spacing.lg }}>
                {/* Tenant Documents */}
                {documents.tenantDocuments.length > 0 && (
                    <View style={{ marginBottom: spacing.lg }}>
                        <Text
                            style={{
                                fontSize: 16,
                                fontWeight: '600',
                                color: colors.textPrimary,
                                marginBottom: spacing.md,
                            }}
                        >
                            Tenant Documents
                        </Text>
                        {documents.tenantDocuments.map((doc) => (
                            <View
                                key={doc.id}
                                style={{
                                    backgroundColor: colors.surface,
                                    borderRadius: 12,
                                    padding: spacing.md,
                                    marginBottom: spacing.md,
                                    flexDirection: 'row',
                                    justifyContent: 'space-between',
                                    alignItems: 'center',
                                }}
                            >
                                <View style={{ flex: 1 }}>
                                    <Text
                                        style={{
                                            fontSize: 14,
                                            fontWeight: '600',
                                            color: colors.textPrimary,
                                            marginBottom: 4,
                                        }}
                                        numberOfLines={1}
                                    >
                                        {doc.filename}
                                    </Text>
                                    <Text style={{ fontSize: 12, color: colors.textSecondary }}>
                                        {new Date(doc.uploadedAt).toLocaleDateString()}
                                    </Text>
                                </View>
                                <Pressable
                                    onPress={() => openDocument(doc.url, doc.filename)}
                                    style={{
                                        backgroundColor: colors.brandViolet,
                                        paddingHorizontal: spacing.md,
                                        paddingVertical: spacing.sm,
                                        borderRadius: 8,
                                        marginLeft: spacing.md,
                                    }}
                                >
                                    <Text
                                        style={{
                                            color: '#fff',
                                            fontWeight: '600',
                                            fontSize: 12,
                                        }}
                                    >
                                        View
                                    </Text>
                                </Pressable>
                            </View>
                        ))}
                    </View>
                )}

                {/* Unit Documents */}
                {documents.unitDocuments.length > 0 && (
                    <View>
                        <Text
                            style={{
                                fontSize: 16,
                                fontWeight: '600',
                                color: colors.textPrimary,
                                marginBottom: spacing.md,
                            }}
                        >
                            Unit Documents
                        </Text>
                        {documents.unitDocuments.map((doc) => (
                            <View
                                key={doc.id}
                                style={{
                                    backgroundColor: colors.surface,
                                    borderRadius: 12,
                                    padding: spacing.md,
                                    marginBottom: spacing.md,
                                }}
                            >
                                <Text
                                    style={{
                                        fontSize: 12,
                                        color: colors.textSecondary,
                                        marginBottom: spacing.sm,
                                    }}
                                >
                                    {doc.flatName}
                                </Text>
                                <View
                                    style={{
                                        flexDirection: 'row',
                                        justifyContent: 'space-between',
                                        alignItems: 'center',
                                    }}
                                >
                                    <View style={{ flex: 1 }}>
                                        <Text
                                            style={{
                                                fontSize: 14,
                                                fontWeight: '600',
                                                color: colors.textPrimary,
                                                marginBottom: 4,
                                            }}
                                            numberOfLines={1}
                                        >
                                            {doc.filename}
                                        </Text>
                                        <Text style={{ fontSize: 12, color: colors.textSecondary }}>
                                            {new Date(doc.uploadedAt).toLocaleDateString()}
                                        </Text>
                                    </View>
                                    <Pressable
                                        onPress={() => openDocument(doc.url, doc.filename)}
                                        style={{
                                            backgroundColor: colors.brandViolet,
                                            paddingHorizontal: spacing.md,
                                            paddingVertical: spacing.sm,
                                            borderRadius: 8,
                                            marginLeft: spacing.md,
                                        }}
                                    >
                                        <Text
                                            style={{
                                                color: '#fff',
                                                fontWeight: '600',
                                                fontSize: 12,
                                            }}
                                        >
                                            View
                                        </Text>
                                    </Pressable>
                                </View>
                            </View>
                        ))}
                    </View>
                )}
            </View>
        </ScrollView>
    );
}
