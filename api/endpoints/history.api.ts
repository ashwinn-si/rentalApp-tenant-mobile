import axiosInstance from '../axiosInstance';

export interface HistoryItem {
    id: string;
    month: string;
    status: 'paid' | 'partial' | 'pending';
    baseRent: number;
    utility?: number;
    maintenance?: number;
    previousDues?: number;
    total: number;
    paidDate?: string;
}

export interface HistoryResponse {
    items: HistoryItem[];
    total: number;
    page: number;
    limit: number;
}

export async function getHistory(flatId: string, page: number = 1): Promise<HistoryResponse> {
    const response = await axiosInstance.get<HistoryResponse>(
        `/tenant/history?page=${page}${flatId !== 'all' ? `&flatId=${flatId}` : ''}`
    );
    return response.data;
}
