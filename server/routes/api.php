<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\TaskController;
use App\Http\Controllers\Api\UserController;
use Illuminate\Support\Facades\Route;

Route::post("/auth/signup", [AuthController::class, 'signup']);
Route::post("/auth/login", [AuthController::class, 'login']);
Route::post('/user/send-otp', [UserController::class, 'sendOTP']);
Route::post('/user/verify-otp', [UserController::class, 'verifyOTP']);
Route::post('/user/change-password-by-otp', [UserController::class, 'updatePasswordByOTP']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/user', [UserController::class, 'profile']);
    Route::patch('/user', [UserController::class, 'update']);
    Route::post('/user-avatar', [UserController::class, 'update']);
    Route::post('/user/change-password-by-old', [UserController::class, 'updatePasswordByOld']);
    Route::delete('/user', [UserController::class, 'destroy']);
    Route::apiResource("tasks", TaskController::class);
});
