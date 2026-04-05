<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Http\Requests\UserRequest;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Http;
use Cloudinary\Cloudinary;
use Cloudinary\Configuration\Configuration;

class UserController extends Controller
{
    // Cloudinary config
    private function cloudinary(): Cloudinary
    {
        return new Cloudinary(
            new Configuration([
                'cloud' => [
                    'cloud_name' => env('CLOUDINARY_CLOUD_NAME'),
                    'api_key'    => env('CLOUDINARY_API_KEY'),
                    'api_secret' => env('CLOUDINARY_API_SECRET'),
                ],
                'url' => ['secure' => true],
            ])
        );
    }

    // Get user profile
    public function profile(Request $request)
    {
        return response()->json($request->user());
    }

    // Update profile
    public function update(UserRequest $request)
    {
        $user = $request->user();
        $data = $request->validated();

        // Upload avatar if exists
        if ($request->hasFile('avatar')) {
            if ($request->hasFile('avatar')) {

                $cloudinary = $this->cloudinary();

                // Delete old avatar
                if ($user->avatar_public_id) {
                    $cloudinary->uploadApi()->destroy($user->avatar_public_id);
                }

                // Upload new avatar
                $result = $cloudinary->uploadApi()->upload(
                    $request->file('avatar')->getRealPath(),
                    ['folder' => 'avatars']
                );

                $data['avatar']           = $result['secure_url'];
                $data['avatar_public_id'] = $result['public_id'];
            }
        }

        // Hash password if provided
        if (!empty($data['password'])) {
            $data['password'] = bcrypt($data['password']);
        }

        $user->update($data);

        return response()->json([
            'message' => 'Profile updated successfully',
            'user' => $user->fresh()
        ]);
    }

    // Update password using old password
    public function updatePasswordByOld(UserRequest $request)
    {
        $user = $request->user();

        $request->validated([
            "current_password" => "required",
            'new_password' => 'required|min:6|different:current_password'
        ]);

        // Check current password
        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'message' => 'Current password is incorrect'
            ], 422);
        }

        // Update password
        $user->update([
            'password' => Hash::make($request->new_password)
        ]);

        return response()->json([
            'message' => 'Password updated successfully'
        ]);
    }

    // Send OTP to email
    public function sendOTP(Request $request)
    {
        $request->validate([
            'email' => 'required|email|exists:users,email'
        ]);

        $user = User::where('email', $request->email)->first();

        $otp = rand(100000, 999999);

        // Save OTP
        $user->update([
            'otp' => $otp,
            'otp_expires_at' => now()->addMinutes(10)
        ]);

        // Email template
        $html = "
        <html>
        <body style='margin:0; padding:0; background:#f4f4f4; font-family:Arial, sans-serif;'>

        <div style='width:100%; padding:40px 0; background:#f4f4f4;'>
            
            <div style='max-width:500px; margin:auto; background:#ffffff; border-radius:10px; overflow:hidden; box-shadow:0 4px 10px rgba(0,0,0,0.1);'>
                
                <div style='background:#FFC107; color:#ffffff; text-align:center; padding:20px;'>
                    <h2 style='margin:0;'>Password Reset</h2>
                </div>

                <div style='padding:30px; text-align:center;'>
                    <p style='font-size:16px; color:#333;'>Use the OTP below to reset your password:</p>
                    
                    <div style='font-size:36px; font-weight:bold; color:#FFC107; margin:20px 0; letter-spacing:5px;'>
                        $otp
                    </div>

                    <p style='color:#777; font-size:14px;'>This OTP will expire in 10 minutes.</p>

                    <p style='color:#999; font-size:12px;'>If you didn’t request this, ignore this email.</p>
                </div>

                <div style='background:#f4f4f4; text-align:center; padding:15px; font-size:12px; color:#aaa;'>
                    © " . date('Y') . " My Tasking
                </div>

            </div>

        </div>

        </body>
        </html>
        ";

        // Send email
        $response = Http::withHeaders([
            'api-key' => env('BREVO_API_KEY'),
            'Content-Type' => 'application/json',
        ])->post('https://api.brevo.com/v3/smtp/email', [
            'sender' => [
                'name' => 'My Tasking',
                'email' => env('MAIL_FROM_ADDRESS'),
            ],
            'to' => [
                [
                    'email' => $user->email,
                ]
            ],
            'subject' => 'Password Reset OTP',
            'htmlContent' => $html,
        ]);

        return response()->json([
            'message' => 'OTP sent to your email'
        ]);
    }

    // Verify OTP
    public function verifyOTP(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'otp' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        // Check OTP
        if (!$user || $user->otp != $request->otp) {
            return response()->json([
                'message' => 'Invalid OTP'
            ], 422);
        }

        // Check expiry
        if ($user->otp_expires_at < now()) {
            return response()->json([
                'message' => 'OTP expired'
            ], 422);
        }

        // Mark OTP verified
        $user->update([
            'otp' => 'verified',
            'otp_expires_at' => null,
            'otp_verified' => true
        ]);

        return response()->json([
            'message' => 'OTP is verified'
        ]);
    }

    // Reset password using OTP
    public function updatePasswordByOTP(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'new_password' => 'required|min:6'
        ]);

        $user = User::where('email', $request->email)->first();

        // Check OTP verified
        if (!$user->otp != "verified") {
            return response()->json([
                'message' => 'OTP not verified'
            ], 403);
        }

        // Update password
        $user->update([
            'password' => Hash::make($request->new_password),
            'otp' => null
        ]);

        return response()->json([
            'message' => 'Password reset successfully'
        ]);
    }

    // Delete account
    public function destroy(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = $request->user();

        // Check email
        if ($request->email !== $user->email) {
            return response()->json([
                'message' => 'Email does not match'
            ], 403);
        }

        // Check password
        if (!Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Incorrect password'
            ], 403);
        }

        $cloudinary = $this->cloudinary();

        // Delete avatar
        if ($user->avatar_public_id) {
            $cloudinary->uploadApi()->destroy($user->avatar_public_id);
        }

        // Delete user
        $user->delete();

        return response()->json([
            'message' => 'Account deleted successfully'
        ]);
    }
}
