<?php
// backend/app/helpers.php - Core utilities, authentication, responses

function jsonResponse(array $data, int $statusCode = 200): void {
    http_response_code($statusCode);
    header('Content-Type: application/json; charset=utf-8');
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, X-Auth-Token');
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit;
}

function getJsonInput(): array {
    $raw = file_get_contents('php://input');
    if (empty($raw)) {
        return $_POST;
    }
    $decoded = json_decode($raw, true);
    return is_array($decoded) ? array_merge($_POST, $decoded) : $_POST;
}

function getBearerToken(): ?string {
    if (!empty($_SERVER['HTTP_AUTHORIZATION'])) {
        if (preg_match('/Bearer\s(\S+)/i', $_SERVER['HTTP_AUTHORIZATION'], $matches)) {
            return $matches[1];
        }
    }
    if (!empty($_SERVER['REDIRECT_HTTP_AUTHORIZATION'])) {
        if (preg_match('/Bearer\s(\S+)/i', $_SERVER['REDIRECT_HTTP_AUTHORIZATION'], $matches)) {
            return $matches[1];
        }
    }
    if (!empty($_SERVER['HTTP_X_AUTH_TOKEN'])) {
        return trim($_SERVER['HTTP_X_AUTH_TOKEN']);
    }
    if (isset($_GET['token']) && !empty($_GET['token'])) {
        return trim($_GET['token']);
    }
    if (function_exists('apache_request_headers')) {
        $headers = apache_request_headers();
        foreach ($headers as $key => $val) {
            if (strtolower($key) === 'authorization') {
                if (preg_match('/Bearer\s(\S+)/i', $val, $matches)) {
                    return $matches[1];
                }
            }
            if (strtolower($key) === 'x-auth-token') {
                return trim($val);
            }
        }
    }
    return null;
}

function getAuthUser(?PDO $pdo = null): ?array {
    $token = getBearerToken();
    if (!$token) {
        return null;
    }
    $pdo = $pdo ?: DB::getConnection();
    $stmt = $pdo->prepare("SELECT id, name, phone, email, role, avatar, status FROM users WHERE api_token = ? AND status = 'active' LIMIT 1");
    $stmt->execute([$token]);
    $user = $stmt->fetch();
    return $user ?: null;
}

function requireAuthUser(?PDO $pdo = null): array {
    $user = getAuthUser($pdo);
    if (!$user) {
        jsonResponse([
            'success' => false,
            'message' => 'Unauthenticated or invalid token. Please log in.'
        ], 401);
    }
    return $user;
}

function requireAdminSession(): void {
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
    if (empty($_SESSION['admin_user'])) {
        header('Location: /admin/login');
        exit;
    }
}

function getSetting(string $key, string $default = ''): string {
    $pdo = DB::getConnection();
    $stmt = $pdo->prepare("SELECT key_value FROM settings WHERE key_name = ? LIMIT 1");
    $stmt->execute([$key]);
    $res = $stmt->fetchColumn();
    return $res !== false ? $res : $default;
}

function setSetting(string $key, string $value): void {
    $pdo = DB::getConnection();
    $stmt = $pdo->prepare("INSERT OR REPLACE INTO settings (key_name, key_value) VALUES (?, ?)");
    $stmt->execute([$key, $value]);
}

function renderView(string $viewPath, array $data = []): void {
    extract($data);
    $fullPath = __DIR__ . '/../views/' . $viewPath . '.php';
    if (file_exists($fullPath)) {
        require $fullPath;
    } else {
        echo "View [{$viewPath}] not found!";
    }
}

