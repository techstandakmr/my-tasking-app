<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;
class AuthRquest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            "name" => [
                "required",
                "string",
                "min:2",
                "max:255",
                "regex:/^[a-zA-Z\s]+$/"
            ],
            "email" => [
                "required",
                "email",
                "max:255",
                "unique:users,email"
            ],
            "password" => [
                "required",
                "confirmed",
                Password::min(8)
                    ->mixedCase()
                    ->numbers()
                    ->symbols()
            ],
        ];
    }

    public function messages(): array
    {
        return [
            // Name
            "name.required" => "Name is required",
            "name.min" => "Name must be at least 2 characters",
            "name.regex" => "Only letters allowed",

            // Email
            "email.required" => "Email is required",
            "email.email" => "Enter a valid email",
            "email.unique" => "Email already exists",

            // Password
            "password.required" => "Password is required",
            "password.min" => "Minimum 8 characters required",
            "password.regex" => "Password must contain uppercase, lowercase, number and special character",
            "password.confirmed" => "Passwords do not match",
        ];
    }
}
