import axiosInstance from '../axiosInstance';

export interface RentBreakdown {
    month: string;
    baseRent: number;
    utility?: number;
    maintenance?: number;
    previousDues?: number;
}

export interface PaymentStatus {
    status: 'paid' | 'partial' | 'pending';
    amount: number;
    dueDate: string;
}

export interface Notification {
    id: string;
    type: 'personal' | 'apartment';
    title: string;
    message: string;
    createdAt: string;
    isExpired: boolean;
}

export interface DashboardResponse {
    flatId: string;
    flatName: string;
    currentPaymentStatus: PaymentStatus;
    totalOutstanding: number;
    rentBreakdown: RentBreakdown[];
    notifications: Notification[];
}

export async function getDashboard(flatId: string): Promise<DashboardResponse> {
    const response = await axiosInstance.get<DashboardResponse>(
        `/tenant/dashboard${flatId !== 'all' ? `?flatId=${flatId}` : ''}`
    );
    return response.data;
}
