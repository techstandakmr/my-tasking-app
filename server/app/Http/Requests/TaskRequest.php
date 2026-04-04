<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class TaskRequest extends FormRequest
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
            'title' => [
                'sometimes',
                'required',
                'string',
                'min:3',
                'max:100',
            ],

            'description' => [
                'sometimes',
                'required',
                'string',
                'min:10',
                'max:500',
            ],

            'due_date' => [
                'sometimes',
                'required',
                'date',
            ],

            'stage' => [
                'sometimes',
                'required',
                'in:pending,started,completed',
            ],

            'priority' => [
                'sometimes',
                'required',
                'in:low,medium,high',
            ],
        ];
    }
    public function messages(): array
    {
        return [
            'title.required' => 'Title is required',
            'title.min' => 'Title must be at least 3 characters',
            'title.max' => 'Title too long',

            'description.required' => 'Description is required',
            'description.min' => 'Description must be at least 10 characters',
            'description.max' => 'Description too long',

            'due_date.required' => 'Due date is required',
            'due_date.date' => 'Invalid due date',

            'stage.required' => 'Stage is required',
            'stage.in' => 'Invalid stage value',

            'priority.required' => 'Priority is required',
            'priority.in' => 'Invalid priority value',
        ];
    }
}
