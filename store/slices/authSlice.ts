import { createSlice, type PayloadAction } from '@reduxjs/toolkit';
import type { AuthUser } from '../../types/auth';

type AuthState = {
    isAuthenticated: boolean;
    isBootstrapped: boolean;
    user: AuthUser | null;
    mustChangePassword: boolean;
    token: string | null;
};

const initialState: AuthState = {
    isAuthenticated: false,
    isBootstrapped: false,
    user: null,
    mustChangePassword: false,
    token: null,
};

const authSlice = createSlice({
    name: 'auth',
    initialState,
    reducers: {
        setAuthenticated(
            state,
            action: PayloadAction<{ user: AuthUser; token: string; mustChangePassword?: boolean }>
        ) {
            state.isAuthenticated = true;
            state.user = action.payload.user;
            state.token = action.payload.token;
            state.mustChangePassword = Boolean(action.payload.mustChangePassword);
        },
        clearAuth(state) {
            state.isAuthenticated = false;
            state.user = null;
            state.token = null;
            state.mustChangePassword = false;
        },
        setBootstrapped(state, action: PayloadAction<boolean>) {
            state.isBootstrapped = action.payload;
        },
    },
});

export const { setAuthenticated, clearAuth, setBootstrapped } = authSlice.actions;
export default authSlice.reducer;
