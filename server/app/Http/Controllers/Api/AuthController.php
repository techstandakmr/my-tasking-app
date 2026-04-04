<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use App\Http\Requests\AuthRquest;

class AuthController extends Controller
{
    // Handle user registration
    public function signup(AuthRquest $request)
    {
        // Validate incoming request data
        $validatedData = $request->validated();

        // Hash the password before saving
        $validatedData['password'] = bcrypt($validatedData['password']);

        // Create new user in database
        $user = User::create($validatedData);

        // Generate API token for the user
        $token = $user->createToken("auth_token")->plainTextToken;

        // Return success response with token
        return response()->json([
            'message' => 'Registration successful',
            'access_token' => $token,
            'token_type' => "Bearer"
        ], 201);
    }

    // Handle user login
    public function login(Request $request)
    {
        // Attempt to authenticate user with email & password
        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json([
                'message' => 'Invalid email or password'
            ], 401);
        }

        // Fetch authenticated user from database
        $user = User::where('email', $request->email)->firstOrFail();

        // Generate new API token
        $token = $user->createToken('auth_token')->plainTextToken;

        // Return success response with token
        return response()->json([
            'message' => 'Login successful',
            'access_token' => $token,
            'token_type' => 'Bearer',
        ]);
    }

    // Handle user logout
    public function logout(Request $request)
    {
        // Delete current access token (logout from current device)
        $request->user()->currentAccessToken()->delete();

        // Return logout success message
        return response()->json([
            'message' => 'Logged out successfully'
        ]);
    }
}