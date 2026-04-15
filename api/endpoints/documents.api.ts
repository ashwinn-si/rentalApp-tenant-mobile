import axiosInstance from '../axiosInstance';

export interface Document {
    id: string;
    filename: string;
    type: 'tenant' | 'unit';
    flatId?: string;
    flatName?: string;
    uploadedAt: string;
    url: string;
}

export interface DocumentsResponse {
    tenantDocuments: Document[];
    unitDocuments: Document[];
}

export async function getDocuments(): Promise<DocumentsResponse> {
    const response = await axiosInstance.get<DocumentsResponse>('/tenant/documents');
    return response.data;
}
