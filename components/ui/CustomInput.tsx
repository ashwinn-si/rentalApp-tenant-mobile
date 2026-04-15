import type { Control, FieldPath, FieldValues } from 'react-hook-form';
import { Controller } from 'react-hook-form';
import { Text, TextInput, View, type KeyboardTypeOptions } from 'react-native';
import { colors, radius } from '../../constants/tokens';

type CustomInputProps<TFieldValues extends FieldValues> = {
    control: Control<TFieldValues>;
    name: FieldPath<TFieldValues>;
    label: string;
    placeholder: string;
    secureTextEntry?: boolean;
    keyboardType?: KeyboardTypeOptions;
};

export function CustomInput<TFieldValues extends FieldValues>({
    control,
    name,
    label,
    placeholder,
    secureTextEntry,
    keyboardType = 'default',
}: CustomInputProps<TFieldValues>) {
    return (
        <Controller
            control={control}
            name={name}
            render={({ field: { value, onChange, onBlur }, fieldState: { error } }) => (
                <View style={{ marginBottom: 12 }}>
                    <Text style={{ marginBottom: 6, color: colors.textPrimary, fontWeight: '600' }}>
                        {label}
                    </Text>
                    <TextInput
                        value={String(value ?? '')}
                        onChangeText={onChange}
                        onBlur={onBlur}
                        placeholder={placeholder}
                        secureTextEntry={secureTextEntry}
                        keyboardType={keyboardType}
                        autoCapitalize="none"
                        style={{
                            borderWidth: 1,
                            borderColor: error ? colors.danger : colors.border,
                            borderRadius: radius.md,
                            backgroundColor: colors.surface,
                            paddingHorizontal: 12,
                            paddingVertical: 10,
                            color: colors.textPrimary,
                        }}
                    />
                    {error ? (
                        <Text style={{ marginTop: 4, color: colors.danger }}>{error.message}</Text>
                    ) : null}
                </View>
            )}
        />
    );
}
