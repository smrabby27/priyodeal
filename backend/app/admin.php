<?php
// backend/app/admin.php - Web Admin Panel controller

function handleAdminRequest(string $path, string $method): void {
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }

    $pdo = DB::getConnection();
    $subPath = preg_replace('#^/admin#', '', $path);
    $subPath = '/' . ltrim($subPath, '/');

    // -------------------------------------------------------------
    // AUTHENTICATION
    // -------------------------------------------------------------
    if ($subPath === '/login') {
        if ($method === 'POST') {
            $email = trim($_POST['email'] ?? '');
            $password = trim($_POST['password'] ?? '');

            $stmt = $pdo->prepare("SELECT * FROM users WHERE (email = ? OR phone = ?) AND role = 'admin' LIMIT 1");
            $stmt->execute([$email, $email]);
            $admin = $stmt->fetch();

            if ($admin && password_verify($password, $admin['password'])) {
                $_SESSION['admin_user'] = [
                    'id' => $admin['id'],
                    'name' => $admin['name'],
                    'email' => $admin['email'],
                    'role' => $admin['role']
                ];
                header('Location: /admin');
                exit;
            } else {
                renderView('admin/login', ['error' => 'Invalid admin credentials. Please try again.']);
                exit;
            }
        }
        renderView('admin/login');
        exit;
    }

    if ($subPath === '/logout') {
        unset($_SESSION['admin_user']);
        session_destroy();
        header('Location: /admin/login');
        exit;
    }

    // Require Login for all other /admin routes
    requireAdminSession();

    // -------------------------------------------------------------
    // DASHBOARD
    // -------------------------------------------------------------
    if ($subPath === '/' || $subPath === '/dashboard') {
        $totalUsers = (int)$pdo->query("SELECT COUNT(*) FROM users")->fetchColumn();
        $totalDoctors = (int)$pdo->query("SELECT COUNT(*) FROM businesses WHERE type = 'doctor'")->fetchColumn();
        $totalShops = (int)$pdo->query("SELECT COUNT(*) FROM businesses WHERE type = 'shop'")->fetchColumn();
        $totalBookings = (int)$pdo->query("SELECT COUNT(*) FROM appointments")->fetchColumn();
        $totalOrders = (int)$pdo->query("SELECT COUNT(*) FROM orders")->fetchColumn();
        $totalRevenue = (float)$pdo->query("SELECT COALESCE(SUM(total), 0) FROM orders WHERE status != 'cancelled'")->fetchColumn();
        $pendingVendors = (int)$pdo->query("SELECT COUNT(*) FROM businesses WHERE status = 'pending'")->fetchColumn();

        // Recent Bookings
        $recentBookings = $pdo->query("SELECT a.*, b.name as doctor_name, c.name as chamber_name FROM appointments a JOIN businesses b ON a.business_id = b.id JOIN chambers c ON a.chamber_id = c.id ORDER BY a.id DESC LIMIT 5")->fetchAll();

        // Recent Orders
        $recentOrders = $pdo->query("SELECT o.*, b.name as shop_name FROM orders o JOIN businesses b ON o.business_id = b.id ORDER BY o.id DESC LIMIT 5")->fetchAll();

        // Pending Applications
        $pendingApps = $pdo->query("SELECT b.*, u.name as applicant_name FROM businesses b LEFT JOIN users u ON b.owner_id = u.id WHERE b.status = 'pending' ORDER BY b.id DESC LIMIT 5")->fetchAll();

        renderView('admin/dashboard', compact(
            'totalUsers', 'totalDoctors', 'totalShops', 'totalBookings',
            'totalOrders', 'totalRevenue', 'pendingVendors',
            'recentBookings', 'recentOrders', 'pendingApps'
        ));
        exit;
    }

    // -------------------------------------------------------------
    // VENDORS (DOCTORS & SHOPS)
    // -------------------------------------------------------------
    if ($subPath === '/vendors') {
        if ($method === 'POST') {
            $action = $_POST['action'] ?? '';
            $bizId = (int)($_POST['business_id'] ?? 0);

            if ($action === 'approve') {
                $pdo->prepare("UPDATE businesses SET status = 'approved', rejection_reason = NULL WHERE id = ?")->execute([$bizId]);
                $_SESSION['flash'] = 'Vendor approved successfully!';
            } elseif ($action === 'reject') {
                $reason = trim($_POST['reason'] ?? 'Documents incomplete or invalid.');
                $pdo->prepare("UPDATE businesses SET status = 'rejected', rejection_reason = ? WHERE id = ?")->execute([$reason, $bizId]);
                $_SESSION['flash'] = 'Vendor application rejected.';
            } elseif ($action === 'suspend') {
                $pdo->prepare("UPDATE businesses SET status = 'suspended' WHERE id = ?")->execute([$bizId]);
                $_SESSION['flash'] = 'Vendor suspended.';
            } elseif ($action === 'add') {
                $name = trim($_POST['name'] ?? '');
                $type = trim($_POST['type'] ?? 'doctor');
                $categoryId = (int)($_POST['category_id'] ?? 1);
                $tagline = trim($_POST['tagline'] ?? '');
                $address = trim($_POST['address'] ?? '');
                $area = trim($_POST['area'] ?? 'Dhaka');
                $phone = trim($_POST['phone'] ?? '');

                $pdo->prepare("INSERT INTO businesses (name, type, category_id, tagline, address, area, phone, status) VALUES (?, ?, ?, ?, ?, ?, ?, 'approved')")
                    ->execute([$name, $type, $categoryId, $tagline, $address, $area, $phone]);
                $_SESSION['flash'] = 'New vendor added successfully!';
            }
            header('Location: /admin/vendors');
            exit;
        }

        $filterStatus = $_GET['status'] ?? '';
        $filterType = $_GET['type'] ?? '';

        $sql = "SELECT b.*, c.name as category_name, u.name as owner_name FROM businesses b LEFT JOIN categories c ON b.category_id = c.id LEFT JOIN users u ON b.owner_id = u.id WHERE 1=1";
        $params = [];
        if (!empty($filterStatus)) {
            $sql .= " AND b.status = ?";
            $params[] = $filterStatus;
        }
        if (!empty($filterType)) {
            $sql .= " AND b.type = ?";
            $params[] = $filterType;
        }
        $sql .= " ORDER BY b.id DESC";

        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $vendors = $stmt->fetchAll();

        $categories = $pdo->query("SELECT * FROM categories ORDER BY name ASC")->fetchAll();

        renderView('admin/vendors', compact('vendors', 'categories', 'filterStatus', 'filterType'));
        exit;
    }

    // -------------------------------------------------------------
    // CATEGORIES
    // -------------------------------------------------------------
    if ($subPath === '/categories') {
        if ($method === 'POST') {
            $action = $_POST['action'] ?? '';
            if ($action === 'add') {
                $name = trim($_POST['name'] ?? '');
                $module = trim($_POST['module'] ?? 'booking');
                $icon = trim($_POST['icon'] ?? 'folder');
                $slug = strtolower(trim(preg_replace('/[^A-Za-z0-9-]+/', '-', $name)));
                $image = trim($_POST['image'] ?? '');
                $sort = (int)($_POST['sort_order'] ?? 0);

                if (!empty($name)) {
                    $pdo->prepare("INSERT INTO categories (name, module, slug, icon, image, sort_order) VALUES (?, ?, ?, ?, ?, ?)")
                        ->execute([$name, $module, $slug, $icon, $image, $sort]);
                    $_SESSION['flash'] = 'Category added successfully!';
                }
            } elseif ($action === 'delete') {
                $id = (int)($_POST['id'] ?? 0);
                $pdo->prepare("DELETE FROM categories WHERE id = ?")->execute([$id]);
                $_SESSION['flash'] = 'Category deleted.';
            }
            header('Location: /admin/categories');
            exit;
        }

        $categories = $pdo->query("SELECT * FROM categories ORDER BY module ASC, sort_order ASC, id ASC")->fetchAll();
        renderView('admin/categories', compact('categories'));
        exit;
    }

    // -------------------------------------------------------------
    // BOOKINGS (APPOINTMENTS)
    // -------------------------------------------------------------
    if ($subPath === '/bookings') {
        if ($method === 'POST') {
            $bookingId = (int)($_POST['booking_id'] ?? 0);
            $newStatus = trim($_POST['status'] ?? 'confirmed');
            $pdo->prepare("UPDATE appointments SET status = ? WHERE id = ?")->execute([$newStatus, $bookingId]);
            $_SESSION['flash'] = "Booking status updated to {$newStatus}.";
            header('Location: /admin/bookings');
            exit;
        }

        $status = $_GET['status'] ?? '';
        $sql = "SELECT a.*, b.name as doctor_name, c.name as chamber_name FROM appointments a JOIN businesses b ON a.business_id = b.id JOIN chambers c ON a.chamber_id = c.id";
        $params = [];
        if (!empty($status)) {
            $sql .= " WHERE a.status = ?";
            $params[] = $status;
        }
        $sql .= " ORDER BY a.id DESC";

        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $bookings = $stmt->fetchAll();

        renderView('admin/bookings', compact('bookings', 'status'));
        exit;
    }

    // -------------------------------------------------------------
    // ORDERS
    // -------------------------------------------------------------
    if ($subPath === '/orders') {
        if ($method === 'POST') {
            $orderId = (int)($_POST['order_id'] ?? 0);
            $newStatus = trim($_POST['status'] ?? 'confirmed');
            $pdo->prepare("UPDATE orders SET status = ? WHERE id = ?")->execute([$newStatus, $orderId]);
            $_SESSION['flash'] = "Order status updated to {$newStatus}.";
            header('Location: /admin/orders');
            exit;
        }

        $status = $_GET['status'] ?? '';
        $sql = "SELECT o.*, b.name as shop_name FROM orders o JOIN businesses b ON o.business_id = b.id";
        $params = [];
        if (!empty($status)) {
            $sql .= " WHERE o.status = ?";
            $params[] = $status;
        }
        $sql .= " ORDER BY o.id DESC";

        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $orders = $stmt->fetchAll();

        foreach ($orders as &$ord) {
            $itemStmt = $pdo->prepare("SELECT * FROM order_items WHERE order_id = ?");
            $itemStmt->execute([$ord['id']]);
            $ord['items'] = $itemStmt->fetchAll();
        }

        renderView('admin/orders', compact('orders', 'status'));
        exit;
    }

    // -------------------------------------------------------------
    // PRODUCTS
    // -------------------------------------------------------------
    if ($subPath === '/products') {
        if ($method === 'POST') {
            $action = $_POST['action'] ?? '';
            if ($action === 'add') {
                $bizId = (int)($_POST['business_id'] ?? 0);
                $catId = (int)($_POST['category_id'] ?? 0);
                $name = trim($_POST['name'] ?? '');
                $desc = trim($_POST['description'] ?? '');
                $price = (float)($_POST['price'] ?? 0);
                $disc = !empty($_POST['discount_price']) ? (float)$_POST['discount_price'] : null;
                $stock = (int)($_POST['stock'] ?? 100);
                $image = trim($_POST['image'] ?? '');
                $unit = trim($_POST['unit'] ?? 'item');

                $pdo->prepare("INSERT INTO products (business_id, category_id, name, description, price, discount_price, stock, image, unit, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'active')")
                    ->execute([$bizId, $catId, $name, $desc, $price, $disc, $stock, $image, $unit]);
                $_SESSION['flash'] = 'Product added successfully!';
            } elseif ($action === 'toggle_status') {
                $pid = (int)($_POST['product_id'] ?? 0);
                $st = $_POST['status'] === 'active' ? 'inactive' : 'active';
                $pdo->prepare("UPDATE products SET status = ? WHERE id = ?")->execute([$st, $pid]);
                $_SESSION['flash'] = 'Product status updated.';
            }
            header('Location: /admin/products');
            exit;
        }

        $products = $pdo->query("SELECT p.*, b.name as shop_name, c.name as category_name FROM products p JOIN businesses b ON p.business_id = b.id LEFT JOIN categories c ON p.category_id = c.id ORDER BY p.id DESC")->fetchAll();
        $shops = $pdo->query("SELECT id, name FROM businesses WHERE type = 'shop' AND status = 'approved'")->fetchAll();
        $categories = $pdo->query("SELECT id, name FROM categories WHERE module = 'shopping'")->fetchAll();

        renderView('admin/products', compact('products', 'shops', 'categories'));
        exit;
    }

    // -------------------------------------------------------------
    // USERS
    // -------------------------------------------------------------
    if ($subPath === '/users') {
        if ($method === 'POST') {
            $userId = (int)($_POST['user_id'] ?? 0);
            $action = $_POST['action'] ?? '';
            if ($action === 'toggle_status') {
                $newStatus = $_POST['current_status'] === 'active' ? 'suspended' : 'active';
                $pdo->prepare("UPDATE users SET status = ? WHERE id = ?")->execute([$newStatus, $userId]);
                $_SESSION['flash'] = 'User status updated.';
            }
            header('Location: /admin/users');
            exit;
        }

        $users = $pdo->query("SELECT * FROM users ORDER BY id DESC")->fetchAll();
        renderView('admin/users', compact('users'));
        exit;
    }

    // -------------------------------------------------------------
    // BANNERS
    // -------------------------------------------------------------
    if ($subPath === '/banners') {
        if ($method === 'POST') {
            $action = $_POST['action'] ?? '';
            if ($action === 'add') {
                $title = trim($_POST['title'] ?? '');
                $sub = trim($_POST['subtitle'] ?? '');
                $img = trim($_POST['image'] ?? '');
                $url = trim($_POST['target_url'] ?? '');
                $sort = (int)($_POST['sort_order'] ?? 0);

                if (!empty($title) && !empty($img)) {
                    $pdo->prepare("INSERT INTO banners (title, subtitle, image, target_url, sort_order) VALUES (?, ?, ?, ?, ?)")
                        ->execute([$title, $sub, $img, $url, $sort]);
                    $_SESSION['flash'] = 'Banner added successfully!';
                }
            } elseif ($action === 'delete') {
                $id = (int)($_POST['id'] ?? 0);
                $pdo->prepare("DELETE FROM banners WHERE id = ?")->execute([$id]);
                $_SESSION['flash'] = 'Banner deleted.';
            }
            header('Location: /admin/banners');
            exit;
        }

        $banners = $pdo->query("SELECT * FROM banners ORDER BY sort_order ASC, id DESC")->fetchAll();
        renderView('admin/banners', compact('banners'));
        exit;
    }

    // -------------------------------------------------------------
    // FINANCE & PRICING PLANS (100% Free For All Modules)
    // -------------------------------------------------------------
    if ($subPath === '/finance') {
        if ($method === 'POST') {
            $action = $_POST['action'] ?? '';
            if ($action === 'add_category') {
                $name = trim($_POST['name'] ?? '');
                $module = trim($_POST['module'] ?? 'finance_personal');
                if (!empty($name)) {
                    $slug = strtolower(preg_replace('/[^a-zA-Z0-9]+/', '-', $name));
                    $pdo->prepare("INSERT INTO categories (module, name, slug, icon) VALUES (?, ?, ?, ?)")
                        ->execute([$module, $name, $slug, 'wallet']);
                    $_SESSION['flash'] = 'Finance category added successfully!';
                }
            } elseif ($action === 'delete_category') {
                $id = (int)($_POST['id'] ?? 0);
                $pdo->prepare("DELETE FROM categories WHERE id = ?")->execute([$id]);
                $_SESSION['flash'] = 'Category deleted.';
            } elseif ($action === 'save_plans') {
                setSetting('pricing_policy', '100% Free Lifetime');
                setSetting('personal_finance_active', '1');
                setSetting('business_pos_active', '1');
                setSetting('inventory_active', '1');
                $_SESSION['flash'] = 'Pricing policy updated: All personal & business modules are 100% FREE!';
            }
            header('Location: /admin/finance');
            exit;
        }

        $financeCats = $pdo->query("SELECT * FROM categories WHERE module IN ('finance_personal', 'finance_business') ORDER BY id DESC")->fetchAll();
        renderView('admin/finance', compact('financeCats'));
        exit;
    }

    // -------------------------------------------------------------
    // SETTINGS & DATABASE CONFIG
    // -------------------------------------------------------------
    if ($subPath === '/settings') {
        $testResult = null;
        if ($method === 'POST') {
            $action = $_POST['action'] ?? '';
            if ($action === 'save_settings') {
                setSetting('support_phone', trim($_POST['support_phone'] ?? ''));
                setSetting('support_email', trim($_POST['support_email'] ?? ''));
                setSetting('developer_name', trim($_POST['developer_name'] ?? ''));
                setSetting('domain', trim($_POST['domain'] ?? ''));
                setSetting('default_delivery_fee', trim($_POST['default_delivery_fee'] ?? '60'));
                setSetting('apk_version', trim($_POST['apk_version'] ?? '1.0.0'));
                $_SESSION['flash'] = 'Settings saved successfully!';
            } elseif ($action === 'test_mysql') {
                $host = trim($_POST['db_host'] ?? '127.0.0.1');
                $name = trim($_POST['db_name'] ?? '');
                $user = trim($_POST['db_user'] ?? '');
                $pass = trim($_POST['db_pass'] ?? '');

                try {
                    $testPdo = new PDO("mysql:host={$host};dbname={$name};charset=utf8mb4", $user, $pass, [
                        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                        PDO::ATTR_TIMEOUT => 3
                    ]);
                    $testResult = ['success' => true, 'message' => "Successfully connected to MySQL database: {$name}!"];
                    
                    // Save to config.json
                    $configFile = __DIR__ . '/../data/config.json';
                    file_put_contents($configFile, json_encode([
                        'db_type' => 'mysql',
                        'db_host' => $host,
                        'db_name' => $name,
                        'db_user' => $user,
                        'db_pass' => $pass
                    ], JSON_PRETTY_PRINT));
                    $_SESSION['flash'] = 'MySQL connected & activated!';
                } catch (Exception $e) {
                    $testResult = ['success' => false, 'message' => "MySQL Connection error: " . $e->getMessage()];
                }
            } elseif ($action === 'switch_sqlite') {
                $configFile = __DIR__ . '/../data/config.json';
                file_put_contents($configFile, json_encode(['db_type' => 'sqlite'], JSON_PRETTY_PRINT));
                $_SESSION['flash'] = 'Switched to SQLite storage successfully!';
            }
            if ($action !== 'test_mysql') {
                header('Location: /admin/settings');
                exit;
            }
        }

        $configFile = __DIR__ . '/../data/config.json';
        $currentConfig = file_exists($configFile) ? json_decode(file_get_contents($configFile), true) : ['db_type' => 'sqlite'];

        renderView('admin/settings', compact('currentConfig', 'testResult'));
        exit;
    }

    // Default 404
    header('Location: /admin');
    exit;
}

