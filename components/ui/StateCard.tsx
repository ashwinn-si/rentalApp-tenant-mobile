import { View, Text } from 'react-native';
import { colors, spacing, radius } from '../../constants/tokens';

type StateCardVariant = 'empty' | 'error' | 'loading';

type StateCardProps = {
    message: string;
    variant?: StateCardVariant;
};

export function StateCard({ message, variant = 'empty' }: StateCardProps) {
    const variantStyles = {
        empty: { backgroundColor: '#f3f4f6', borderColor: '#d1d5db' },
        error: { backgroundColor: '#fee2e2', borderColor: '#fca5a5' },
        loading: { backgroundColor: '#ede9fe', borderColor: '#ddd6fe' },
    };

    const style = variantStyles[variant];

    return (
        <View
            style={{
                borderWidth: 1,
                borderRadius: radius.lg,
                borderStyle: 'dashed',
                paddingVertical: spacing.lg,
                paddingHorizontal: spacing.lg,
                alignItems: 'center',
                justifyContent: 'center',
                ...style,
            }}
        >
            <Text
                style={{
                    fontSize: 14,
                    color: colors.textSecondary,
                    textAlign: 'center',
                }}
            >
                {message}
            </Text>
        </View>
    );
}
