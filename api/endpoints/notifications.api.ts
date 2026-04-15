import axiosInstance from '../axiosInstance';

export interface Notification {
    id: string;
    type: 'personal' | 'apartment';
    title: string;
    message: string;
    createdAt: string;
    isExpired: boolean;
    flatId?: string;
    flatName?: string;
}

export interface NotificationsResponse {
    active: Notification[];
    expired: Notification[];
}

export async function getNotifications(): Promise<NotificationsResponse> {
    const response = await axiosInstance.get<NotificationsResponse>('/tenant/notifications');
    return response.data;
}
