import * as SecureStore from 'expo-secure-store';

const TOKEN_KEY = 'tenant_mobile_auth_token';

export async function getSecureToken(): Promise<string | null> {
    return SecureStore.getItemAsync(TOKEN_KEY);
}

export async function setSecureToken(token: string): Promise<void> {
    await SecureStore.setItemAsync(TOKEN_KEY, token);
}

export async function clearSecureToken(): Promise<void> {
    await SecureStore.deleteItemAsync(TOKEN_KEY);
}
