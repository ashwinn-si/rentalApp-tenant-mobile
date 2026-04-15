import axios from 'axios';
import { clearSecureToken, getSecureToken } from './secureToken';
import { store } from '../store';
import { clearAuth } from '../store/slices/authSlice';

const expoEnv = (globalThis as { process?: { env?: Record<string, string | undefined> } }).process
    ?.env;
const baseURL = expoEnv?.EXPO_PUBLIC_API_URL || 'http://localhost:5000/api';

const axiosInstance = axios.create({
    baseURL,
    headers: { 'Content-Type': 'application/json' },
});

axiosInstance.interceptors.request.use(async (config) => {
    const token = await getSecureToken();
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});

axiosInstance.interceptors.response.use(
    (response) => response,
    async (error) => {
        const status = error?.response?.status;
        const isLoginRequest = error?.config?.url?.includes('auth/login');

        if ((status === 401 || status === 403) && !isLoginRequest) {
            await clearSecureToken();
            store.dispatch(clearAuth());
        }

        return Promise.reject(error);
    }
);

export default axiosInstance;
