import { View, Text } from 'react-native';
import { colors, spacing } from '../../constants/tokens';

type InfoFieldProps = {
    label: string;
    value: string | number | undefined | null;
};

export function InfoField({ label, value }: InfoFieldProps) {
    return (
        <View
            style={{
                paddingVertical: spacing.md,
                borderBottomWidth: 1,
                borderBottomColor: colors.border,
            }}
        >
            <Text style={{ fontSize: 12, color: colors.textSecondary, marginBottom: 4 }}>
                {label}
            </Text>
            <Text style={{ fontSize: 16, color: colors.textPrimary, fontWeight: '600' }}>
                {value ?? '-'}
            </Text>
        </View>
    );
}
