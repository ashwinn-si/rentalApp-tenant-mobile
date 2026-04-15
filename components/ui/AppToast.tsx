import Toast from 'react-native-toast-message';

export function AppToastHost() {
    return <Toast />;
}

export const showToast = {
    success: (title: string, message?: string) => {
        Toast.show({
            type: 'success',
            text1: title,
            text2: message,
            position: 'top',
            topOffset: 50,
        });
    },
    error: (title: string, message?: string) => {
        Toast.show({
            type: 'error',
            text1: title,
            text2: message,
            position: 'top',
            topOffset: 50,
        });
    },
    info: (title: string, message?: string) => {
        Toast.show({
            type: 'info',
            text1: title,
            text2: message,
            position: 'top',
            topOffset: 50,
        });
    },
};
