import { Link } from 'expo-router';
import { Text, View } from 'react-native';

export default function NotFoundScreen() {
    return (
        <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', padding: 16 }}>
            <Text style={{ fontSize: 20, fontWeight: '700', marginBottom: 8 }}>
                Screen not found
            </Text>
            <Link href="/">Go to home</Link>
        </View>
    );
}
