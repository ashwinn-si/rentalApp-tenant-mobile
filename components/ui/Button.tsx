import type { PropsWithChildren } from 'react';
import { ActivityIndicator, Pressable, Text } from 'react-native';
import { colors, radius } from '../../constants/tokens';

type ButtonProps = PropsWithChildren<{
    onPress?: () => void;
    disabled?: boolean;
    loading?: boolean;
}>;

export function Button({ children, onPress, disabled = false, loading = false }: ButtonProps) {
    const isDisabled = disabled || loading;

    return (
        <Pressable
            onPress={onPress}
            disabled={isDisabled}
            style={{
                backgroundColor: isDisabled ? '#C4B5FD' : colors.brandViolet,
                paddingVertical: 12,
                borderRadius: radius.lg,
                alignItems: 'center',
            }}
        >
            {loading ? (
                <ActivityIndicator color="#FFFFFF" />
            ) : (
                <Text style={{ color: '#FFFFFF', fontWeight: '600', fontSize: 16 }}>
                    {children}
                </Text>
            )}
        </Pressable>
    );
}
