<?php
// backend/index.php - Application Router & Entry Point

error_reporting(E_ALL);
ini_set('display_errors', '0');

require_once __DIR__ . '/app/db.php';
require_once __DIR__ . '/app/helpers.php';
require_once __DIR__ . '/app/api.php';
require_once __DIR__ . '/app/admin.php';

// Initialize DB schema & seed data if needed
DB::getConnection();

$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$method = $_SERVER['REQUEST_METHOD'];

// Handle direct download routes
if (str_starts_with($uri, '/downloads/')) {
    $filename = basename(explode('?', $uri)[0]);
    $filepath = __DIR__ . '/public/downloads/' . $filename;
    if (!file_exists($filepath)) {
        $filepath = __DIR__ . '/downloads/' . $filename;
    }
    if (file_exists($filepath)) {
        header('Content-Type: application/vnd.android.package-archive');
        header('Content-Disposition: attachment; filename="' . $filename . '"');
        header('Content-Length: ' . filesize($filepath));
        header('Cache-Control: no-cache, no-store, must-revalidate');
        header('Pragma: no-cache');
        header('Expires: 0');
        readfile($filepath);
        exit;
    } else {
        // If APK is still being generated or not uploaded yet, serve a friendly download placeholder
        header('Content-Type: text/html; charset=utf-8');
        echo "<!DOCTYPE html><html><head><meta charset='utf-8'><title>APK Downloading - Priyo Deal</title><script src='https://cdn.tailwindcss.com'></script></head><body class='bg-slate-900 text-white min-h-screen flex items-center justify-center p-4 font-sans text-center'><div class='max-w-md bg-slate-950 p-8 rounded-3xl border border-slate-800'><h2 class='text-2xl font-bold mb-2'>Priyo Deal Android APK</h2><p class='text-slate-400 text-xs mb-6'>Version 1.0.0 is being assembled or downloaded. You can also build it locally with flutter build apk.</p><a href='/' class='px-4 py-2 bg-teal-600 rounded-xl font-bold text-xs'>Back to Home</a></div></body></html>";
        exit;
    }
}

// REST API routes
if (str_starts_with($uri, '/api/v1')) {
    handleApiRequest($uri, $method);
    exit;
}

// Admin Panel routes
if (str_starts_with($uri, '/admin')) {
    handleAdminRequest($uri, $method);
    exit;
}

// Landing Page (default)
renderView('landing/index');

