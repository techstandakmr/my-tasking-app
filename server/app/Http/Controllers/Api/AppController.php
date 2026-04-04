<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
class AppController extends Controller
{
    // Get new version apk
    public function version()
    {
        return response()->json([
            "latestVersion" => "1.0.0",
            "apkUrl" => "https://github.com/yourname/yourrepo/releases/download/v1.0.1/my-tasking.apk",
            "forceUpdate" => false
        ]);
    }
}
