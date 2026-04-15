import axiosInstance from '../axiosInstance';
import type { LoginRequest, LoginResponse } from '../../types/auth';

export async function login(payload: LoginRequest): Promise<LoginResponse> {
    const response = await axiosInstance.post<LoginResponse>('/tenant/auth/login', payload);
    return response.data;
}

export async function changePassword(payload: {
    currentPassword: string;
    newPassword: string;
}): Promise<{ message: string }> {
    const response = await axiosInstance.post<{ message: string }>(
        '/tenant/change-password',
        payload
    );
    return response.data;
}
