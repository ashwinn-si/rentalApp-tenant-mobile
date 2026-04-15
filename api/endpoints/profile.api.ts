import axiosInstance from '../axiosInstance';

export interface ProfileResponse {
    id: string;
    name: string;
    email: string;
    phone?: string;
    clientCode: string;
    tenantId: string;
    flats?: Array<{
        flatId: string;
        flatName: string;
    }>;
}

export async function getProfile(): Promise<ProfileResponse> {
    const response = await axiosInstance.get<ProfileResponse>('/tenant/profile');
    return response.data;
}
