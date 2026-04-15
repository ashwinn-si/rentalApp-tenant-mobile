import { CustomInput } from './CustomInput';
import type { Control, FieldPath, FieldValues } from 'react-hook-form';

type FormFieldProps<TFieldValues extends FieldValues> = {
    control: Control<TFieldValues>;
    name: FieldPath<TFieldValues>;
    label: string;
    placeholder?: string;
    secureTextEntry?: boolean;
    keyboardType?: 'default' | 'email-address' | 'numeric' | 'phone-pad';
};

export function FormField<TFieldValues extends FieldValues>({
    control,
    name,
    label,
    placeholder = '',
    secureTextEntry,
    keyboardType = 'default',
}: FormFieldProps<TFieldValues>) {
    return (
        <CustomInput
            control={control}
            name={name}
            label={label}
            placeholder={placeholder}
            secureTextEntry={secureTextEntry}
            keyboardType={keyboardType}
        />
    );
}
