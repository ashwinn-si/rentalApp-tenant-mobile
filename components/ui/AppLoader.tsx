import { ActivityIndicator, View } from 'react-native';
import { colors } from '../../constants/tokens';

export function AppLoader() {
    return (
        <View
            style={{
                flex: 1,
                alignItems: 'center',
                justifyContent: 'center',
                backgroundColor: colors.background,
            }}
        >
            <ActivityIndicator size="large" color={colors.brandViolet} />
        </View>
    );
}
