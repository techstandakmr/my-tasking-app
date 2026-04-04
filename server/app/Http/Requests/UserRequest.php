<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UserRequest extends FormRequest
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
            "name" => "sometimes|string|max:255",
            "email" => "sometimes|email|unique:users,email," . auth()->id(),
            "avatar" => "nullable|image",
            "avatar_public_id"=>"nullable|string",
            "title" => "nullable|string",
            "description" => "nullable|string",
            "current_password" => "sometimes|required_with:new_password|string",
            "new_password" => "sometimes|string|min:6|different:current_password",
        ];
    }
}
