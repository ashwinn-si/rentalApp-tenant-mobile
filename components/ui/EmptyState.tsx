import { Text, View } from 'react-native';
import { colors } from '../../constants/tokens';

type EmptyStateProps = {
    title: string;
    subtitle?: string;
};

export function EmptyState({ title, subtitle }: EmptyStateProps) {
    return (
        <View
            style={{
                borderWidth: 1,
                borderColor: colors.border,
                borderRadius: 14,
                backgroundColor: colors.surface,
                padding: 16,
                gap: 4,
            }}
        >
            <Text style={{ color: colors.textPrimary, fontSize: 16, fontWeight: '600' }}>
                {title}
            </Text>
            {subtitle ? <Text style={{ color: colors.textSecondary }}>{subtitle}</Text> : null}
        </View>
    );
}
