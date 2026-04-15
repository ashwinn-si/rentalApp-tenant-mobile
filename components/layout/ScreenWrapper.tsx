import type { PropsWithChildren } from 'react';
import { SafeAreaView, View } from 'react-native';
import { colors } from '../../constants/tokens';

export function ScreenWrapper({ children }: PropsWithChildren) {
    return (
        <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
            <View style={{ flex: 1, padding: 16 }}>{children}</View>
        </SafeAreaView>
    );
}
