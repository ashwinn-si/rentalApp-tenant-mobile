import { Tabs } from 'expo-router';
import { View, Text } from 'react-native';
import { colors } from '../../constants/tokens';

function TabBarIcon({ focused, name }: { focused: boolean; name: string }) {
    const iconMap: Record<string, string> = {
        'index': '📊',
        'history': '📈',
        'notifications': '🔔',
        'documents': '📄',
        'profile': '👤',
    };

    return (
        <Text style={{ fontSize: 20 }}>
            {iconMap[name] || '○'}
        </Text>
    );
}

export default function TabLayout() {
    return (
        <Tabs
            screenOptions={{
                tabBarActiveTintColor: colors.brandViolet,
                tabBarInactiveTintColor: colors.textSecondary,
                tabBarStyle: {
                    backgroundColor: colors.surface,
                    borderTopColor: colors.border,
                    borderTopWidth: 1,
                    paddingBottom: 8,
                },
                headerStyle: {
                    backgroundColor: colors.surface,
                    borderBottomColor: colors.border,
                    borderBottomWidth: 1,
                },
                headerTintColor: colors.textPrimary,
                headerTitleStyle: {
                    fontWeight: '600',
                },
            }}
        >
            <Tabs.Screen
                name="index"
                options={{
                    title: 'Dashboard',
                    tabBarLabel: 'Dashboard',
                    tabBarIcon: ({ focused }) => <TabBarIcon focused={focused} name="index" />,
                }}
            />
            <Tabs.Screen
                name="history"
                options={{
                    title: 'History',
                    tabBarLabel: 'History',
                    tabBarIcon: ({ focused }) => <TabBarIcon focused={focused} name="history" />,
                }}
            />
            <Tabs.Screen
                name="notifications"
                options={{
                    title: 'Notifications',
                    tabBarLabel: 'Notifications',
                    tabBarIcon: ({ focused }) => (
                        <TabBarIcon focused={focused} name="notifications" />
                    ),
                }}
            />
            <Tabs.Screen
                name="documents"
                options={{
                    title: 'Documents',
                    tabBarLabel: 'Documents',
                    tabBarIcon: ({ focused }) => <TabBarIcon focused={focused} name="documents" />,
                }}
            />
            <Tabs.Screen
                name="profile"
                options={{
                    title: 'Profile',
                    tabBarLabel: 'Profile',
                    tabBarIcon: ({ focused }) => <TabBarIcon focused={focused} name="profile" />,
                }}
            />
        </Tabs>
    );
}
