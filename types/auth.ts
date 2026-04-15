export type AuthUser = {
    tenantId: string;
    email: string;
    name?: string;
};

export type LoginRequest = {
    clientCode: string;
    email: string;
    password: string;
};

export type LoginResponse = {
    token: string;
    user: AuthUser;
    mustChangePassword?: boolean;
};
