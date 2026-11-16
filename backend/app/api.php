<?php
// backend/app/api.php - REST API router & controller

function handleApiRequest(string $path, string $method): void {
    // Handle CORS preflight
    if ($method === 'OPTIONS') {
        jsonResponse(['status' => 'ok'], 200);
    }

    $pdo = DB::getConnection();
    $subPath = preg_replace('#^/api/v1#', '', $path);
    $subPath = '/' . ltrim($subPath, '/');

    // -------------------------------------------------------------
    // AUTH ROUTES
    // -------------------------------------------------------------
    if ($subPath === '/auth/register' && $method === 'POST') {
        $input = getJsonInput();
        $email = trim($input['email'] ?? '');
        $password = trim($input['password'] ?? '');
        $name = trim($input['name'] ?? '');
        $phone = trim($input['phone'] ?? '');
        $role = trim($input['role'] ?? 'customer');

        if (empty($email)) {
            jsonResponse(['success' => false, 'message' => 'Email address is required'], 422);
        }
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            jsonResponse(['success' => false, 'message' => 'Please enter a valid email address'], 422);
        }
        if (empty($password)) {
            jsonResponse(['success' => false, 'message' => 'Password is required'], 422);
        }
        if (strlen($password) < 4) {
            jsonResponse(['success' => false, 'message' => 'Password must be at least 4 characters'], 422);
        }

        if (empty($name)) {
            $name = ucfirst(explode('@', $email)[0]);
        }

        // Check duplicates
        $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ? LIMIT 1");
        $stmt->execute([$email]);
        if ($stmt->fetch()) {
            jsonResponse(['success' => false, 'message' => 'This email address is already registered. Please login.'], 409);
        }

        $hash = password_hash($password, PASSWORD_BCRYPT);
        $token = bin2hex(random_bytes(32));

        $stmt = $pdo->prepare("INSERT INTO users (name, phone, email, password, role, api_token, status) VALUES (?, ?, ?, ?, ?, ?, 'active')");
        $stmt->execute([$name, $phone ?: null, $email, $hash, $role, $token]);
        $userId = $pdo->lastInsertId();

        $user = [
            'id' => (int)$userId,
            'name' => $name,
            'phone' => $phone ?: '',
            'email' => $email,
            'role' => $role,
            'avatar' => null
        ];

        jsonResponse([
            'success' => true,
            'message' => 'Registration successful',
            'token' => $token,
            'user' => $user
        ], 201);
    }

    if ($subPath === '/auth/login' && $method === 'POST') {
        $input = getJsonInput();
        $identifier = trim($input['identifier'] ?? ($input['email'] ?? ($input['phone'] ?? '')));
        $password = trim($input['password'] ?? '');

        if (empty($identifier)) {
            jsonResponse(['success' => false, 'message' => 'Phone or Email is required'], 422);
        }

        $stmt = $pdo->prepare("SELECT * FROM users WHERE (email = ? OR phone = ?) LIMIT 1");
        $stmt->execute([$identifier, $identifier]);
        $user = $stmt->fetch();

        if (!$user) {
            jsonResponse(['success' => false, 'message' => 'User not found. Please register first.'], 401);
        }

        if (empty($password)) {
            jsonResponse(['success' => false, 'message' => 'Password is required'], 422);
        }

        if (!empty($user['password'])) {
            if (!password_verify($password, $user['password'])) {
                jsonResponse(['success' => false, 'message' => 'Invalid email or password'], 401);
            }
        }

        $token = bin2hex(random_bytes(32));
        $pdo->prepare("UPDATE users SET api_token = ? WHERE id = ?")->execute([$token, $user['id']]);

        unset($user['password'], $user['api_token']);
        jsonResponse([
            'success' => true,
            'message' => 'Login successful',
            'token' => $token,
            'user' => $user
        ]);
    }

    if ($subPath === '/auth/otp/send' && $method === 'POST') {
        $input = getJsonInput();
        $phone = trim($input['phone'] ?? '');
        if (empty($phone)) {
            jsonResponse(['success' => false, 'message' => 'Phone number is required'], 422);
        }

        // Generate 6-digit OTP
        $code = (string)rand(100000, 999999);
        $expires = date('Y-m-d H:i:s', time() + 300);

        $pdo->prepare("INSERT INTO otp_codes (phone, code, expires_at) VALUES (?, ?, ?)")->execute([$phone, $code, $expires]);

        // In test/demo mode, return code in response so testing works without paid SMS gateway
        jsonResponse([
            'success' => true,
            'message' => 'OTP sent successfully',
            'debug_otp' => $code,
            'expires_in_seconds' => 300
        ]);
    }

    if ($subPath === '/auth/otp/verify' && $method === 'POST') {
        $input = getJsonInput();
        $phone = trim($input['phone'] ?? '');
        $code = trim($input['code'] ?? '');

        if (empty($phone) || empty($code)) {
            jsonResponse(['success' => false, 'message' => 'Phone and Code are required'], 422);
        }

        $stmt = $pdo->prepare("SELECT * FROM otp_codes WHERE phone = ? AND code = ? AND verified = 0 AND expires_at > datetime('now') ORDER BY id DESC LIMIT 1");
        $stmt->execute([$phone, $code]);
        $row = $stmt->fetch();

        if (!$row && $code !== '123456') { // Allow 123456 as master test bypass
            jsonResponse(['success' => false, 'message' => 'Invalid or expired OTP code'], 400);
        }

        if ($row) {
            $pdo->prepare("UPDATE otp_codes SET verified = 1 WHERE id = ?")->execute([$row['id']]);
        }

        // Find or create user
        $stmt = $pdo->prepare("SELECT * FROM users WHERE phone = ? LIMIT 1");
        $stmt->execute([$phone]);
        $user = $stmt->fetch();

        $token = bin2hex(random_bytes(32));

        if (!$user) {
            $pdo->prepare("INSERT INTO users (name, phone, role, api_token, status) VALUES (?, ?, 'customer', ?, 'active')")
                ->execute(['User ' . substr($phone, -4), $phone, $token]);
            $userId = $pdo->lastInsertId();
            $user = [
                'id' => (int)$userId,
                'name' => 'User ' . substr($phone, -4),
                'phone' => $phone,
                'email' => null,
                'role' => 'customer'
            ];
        } else {
            $pdo->prepare("UPDATE users SET api_token = ? WHERE id = ?")->execute([$token, $user['id']]);
            unset($user['password'], $user['api_token']);
        }

        jsonResponse([
            'success' => true,
            'message' => 'OTP verified successfully',
            'token' => $token,
            'user' => $user
        ]);
    }

    if ($subPath === '/auth/forgot-password' && $method === 'POST') {
        $input = getJsonInput();
        $identifier = trim($input['identifier'] ?? ($input['email'] ?? ($input['phone'] ?? '')));
        if (empty($identifier)) {
            jsonResponse(['success' => false, 'message' => 'দয়া করে আপনার নিবন্ধিত ইমেইল বা মোবাইল নম্বর দিন'], 422);
        }

        $stmt = $pdo->prepare("SELECT * FROM users WHERE email = ? OR phone = ? LIMIT 1");
        $stmt->execute([$identifier, $identifier]);
        $user = $stmt->fetch();

        if (!$user) {
            jsonResponse(['success' => false, 'message' => 'এই তথ্যের কোনো অ্যাকাউন্ট পাওয়া যায়নি। সঠিক ইমেইল দিন।'], 404);
        }

        // Generate 6 digit reset code
        $code = (string)rand(100000, 999999);
        $pdo->prepare("UPDATE users SET reset_code = ? WHERE id = ?")->execute([$code, $user['id']]);

        jsonResponse([
            'success' => true,
            'message' => 'পাসওয়ার্ড রিসেট কোড পাঠানো হয়েছে',
            'code' => $code, // returned so app can display/auto-fill easily in test/demo mode
            'email' => $user['email']
        ]);
    }

    if ($subPath === '/auth/reset-password' && $method === 'POST') {
        $input = getJsonInput();
        $identifier = trim($input['identifier'] ?? ($input['email'] ?? ($input['phone'] ?? '')));
        $code = trim($input['code'] ?? '');
        $newPassword = trim($input['new_password'] ?? ($input['password'] ?? ''));

        if (empty($identifier) || empty($newPassword)) {
            jsonResponse(['success' => false, 'message' => 'ইমেইল ও নতুন পাসওয়ার্ড প্রদান করুন'], 422);
        }

        if (strlen($newPassword) < 4) {
            jsonResponse(['success' => false, 'message' => 'পাসওয়ার্ড কমপক্ষে ৪ অক্ষরের হতে হবে'], 422);
        }

        $stmt = $pdo->prepare("SELECT * FROM users WHERE email = ? OR phone = ? LIMIT 1");
        $stmt->execute([$identifier, $identifier]);
        $user = $stmt->fetch();

        if (!$user) {
            jsonResponse(['success' => false, 'message' => 'ব্যবহারকারী পাওয়া যায়নি'], 404);
        }

        // Allow match with reset_code or master bypass 123456
        if (!empty($user['reset_code']) && !empty($code) && $user['reset_code'] !== $code && $code !== '123456') {
            jsonResponse(['success' => false, 'message' => 'ভুল অথবা মেয়াদোত্তীর্ণ ওটিপি/কোড'], 400);
        }

        $hash = password_hash($newPassword, PASSWORD_BCRYPT);
        $token = bin2hex(random_bytes(32));

        $pdo->prepare("UPDATE users SET password = ?, reset_code = NULL, api_token = ? WHERE id = ?")
            ->execute([$hash, $token, $user['id']]);

        $user['name'] = $user['name'] ?? 'User';
        unset($user['password'], $user['api_token'], $user['reset_code']);

        jsonResponse([
            'success' => true,
            'message' => 'পাসওয়ার্ড সফলভাবে পরিবর্তন হয়েছে। নতুন পাসওয়ার্ড দিয়ে লগইন করুন।',
            'token' => $token,
            'user' => $user
        ]);
    }

    if ($subPath === '/me' && $method === 'GET') {
        $user = requireAuthUser($pdo);
        unset($user['password'], $user['api_token'], $user['reset_code']);
        jsonResponse(['success' => true, 'user' => $user]);
    }

    if (($subPath === '/me' || $subPath === '/user/profile') && ($method === 'PUT' || $method === 'POST')) {
        $user = requireAuthUser($pdo);
        $input = getJsonInput();
        $name = trim($input['name'] ?? $user['name']);
        $phone = trim($input['phone'] ?? ($user['phone'] ?? ''));
        $email = trim($input['email'] ?? ($user['email'] ?? ''));
        $avatar = trim($input['avatar'] ?? ($user['avatar'] ?? ''));
        $gender = trim($input['gender'] ?? ($user['gender'] ?? ''));
        $dob = trim($input['dob'] ?? ($user['dob'] ?? ''));
        $address = trim($input['address'] ?? ($user['address'] ?? ''));
        $city = trim($input['city'] ?? ($user['city'] ?? ''));
        $businessName = trim($input['business_name'] ?? ($user['business_name'] ?? ''));

        // Check if email changed and is taken by another user
        if (!empty($email) && $email !== $user['email']) {
            $checkStmt = $pdo->prepare("SELECT id FROM users WHERE email = ? AND id != ? LIMIT 1");
            $checkStmt->execute([$email, $user['id']]);
            if ($checkStmt->fetch()) {
                jsonResponse(['success' => false, 'message' => 'এই ইমেইলটি অন্য একাউন্টে ব্যবহৃত হচ্ছে'], 409);
            }
        }

        // Check if phone changed and is taken by another user
        if (!empty($phone) && $phone !== $user['phone']) {
            $checkStmt = $pdo->prepare("SELECT id FROM users WHERE phone = ? AND id != ? LIMIT 1");
            $checkStmt->execute([$phone, $user['id']]);
            if ($checkStmt->fetch()) {
                jsonResponse(['success' => false, 'message' => 'এই মোবাইল নম্বরটি অন্য একাউন্টে ব্যবহৃত হচ্ছে'], 409);
            }
        }

        $pdo->prepare("UPDATE users SET name = ?, phone = ?, email = ?, avatar = ?, gender = ?, dob = ?, address = ?, city = ?, business_name = ? WHERE id = ?")
            ->execute([$name, $phone ?: null, $email ?: null, $avatar, $gender, $dob, $address, $city, $businessName, $user['id']]);

        $user['name'] = $name;
        $user['phone'] = $phone;
        $user['email'] = $email;
        $user['avatar'] = $avatar;
        $user['address'] = $address;
        $user['city'] = $city;
        $user['business_name'] = $businessName;
        unset($user['password'], $user['api_token'], $user['reset_code']);

        jsonResponse(['success' => true, 'message' => 'প্রোফাইল সফলভাবে আপডেট হয়েছে', 'user' => $user]);
    }

    // -------------------------------------------------------------
    // CATALOG & PUBLIC ROUTES
    // -------------------------------------------------------------
    if ($subPath === '/banners' && $method === 'GET') {
        $stmt = $pdo->query("SELECT * FROM banners WHERE status = 'active' ORDER BY sort_order ASC");
        jsonResponse(['success' => true, 'banners' => $stmt->fetchAll()]);
    }

    if ($subPath === '/categories' && $method === 'GET') {
        $module = $_GET['module'] ?? '';
        $sql = "SELECT * FROM categories WHERE status = 'active'";
        $params = [];
        if (!empty($module)) {
            $sql .= " AND module = ?";
            $params[] = $module;
        }
        $sql .= " ORDER BY sort_order ASC";
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        jsonResponse(['success' => true, 'categories' => $stmt->fetchAll()]);
    }

    if ($subPath === '/businesses' && $method === 'GET') {
        $type = $_GET['type'] ?? '';
        $categoryId = (int)($_GET['category_id'] ?? 0);
        $q = trim($_GET['q'] ?? '');

        $sql = "SELECT b.*, c.name as category_name, dp.specialty_name, dp.degrees, dp.consultation_fee, dp.experience_years
                FROM businesses b
                LEFT JOIN categories c ON b.category_id = c.id
                LEFT JOIN doctor_profiles dp ON dp.business_id = b.id
                WHERE b.status = 'approved'";
        $params = [];

        if (!empty($type)) {
            $sql .= " AND b.type = ?";
            $params[] = $type;
        }
        if ($categoryId > 0) {
            $sql .= " AND b.category_id = ?";
            $params[] = $categoryId;
        }
        if (!empty($q)) {
            $sql .= " AND (b.name LIKE ? OR b.area LIKE ? OR dp.specialty_name LIKE ?)";
            $params[] = "%{$q}%";
            $params[] = "%{$q}%";
            $params[] = "%{$q}%";
        }

        $sql .= " ORDER BY b.rating DESC, b.id ASC";
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $businesses = $stmt->fetchAll();

        jsonResponse(['success' => true, 'businesses' => $businesses]);
    }

    if (preg_match('#^/businesses/(\d+)$#', $subPath, $matches) && $method === 'GET') {
        $id = (int)$matches[1];
        $stmt = $pdo->prepare("SELECT b.*, c.name as category_name FROM businesses b LEFT JOIN categories c ON b.category_id = c.id WHERE b.id = ?");
        $stmt->execute([$id]);
        $biz = $stmt->fetch();

        if (!$biz) {
            jsonResponse(['success' => false, 'message' => 'Business not found'], 404);
        }

        if ($biz['type'] === 'doctor') {
            $docStmt = $pdo->prepare("SELECT * FROM doctor_profiles WHERE business_id = ?");
            $docStmt->execute([$id]);
            $biz['doctor_profile'] = $docStmt->fetch() ?: null;

            $chStmt = $pdo->prepare("SELECT * FROM chambers WHERE business_id = ?");
            $chStmt->execute([$id]);
            $biz['chambers'] = $chStmt->fetchAll();
        } else {
            $prodStmt = $pdo->prepare("SELECT * FROM products WHERE business_id = ? AND status = 'active'");
            $prodStmt->execute([$id]);
            $biz['products'] = $prodStmt->fetchAll();
        }

        jsonResponse(['success' => true, 'business' => $biz]);
    }

    if (preg_match('#^/doctors/(\d+)/slots$#', $subPath, $matches) && $method === 'GET') {
        $businessId = (int)$matches[1];
        $chamberId = (int)($_GET['chamber_id'] ?? 0);
        $date = $_GET['date'] ?? date('Y-m-d');

        $chStmt = $pdo->prepare("SELECT * FROM chambers WHERE business_id = ? AND (id = ? OR ? = 0) LIMIT 1");
        $chStmt->execute([$businessId, $chamberId, $chamberId]);
        $chamber = $chStmt->fetch();

        if (!$chamber) {
            jsonResponse(['success' => false, 'message' => 'Chamber not found'], 404);
        }

        // Generate realistic hourly slots for the visiting time
        $slots = [
            '05:00 PM', '05:20 PM', '05:40 PM',
            '06:00 PM', '06:20 PM', '06:40 PM',
            '07:00 PM', '07:20 PM', '07:40 PM',
            '08:00 PM', '08:20 PM', '08:40 PM'
        ];

        // Fetch already booked slots for this date
        $bkStmt = $pdo->prepare("SELECT slot_time FROM appointments WHERE business_id = ? AND chamber_id = ? AND date = ? AND status != 'cancelled'");
        $bkStmt->execute([$businessId, $chamber['id'], $date]);
        $booked = $bkStmt->fetchAll(PDO::FETCH_COLUMN);

        $availableSlots = [];
        foreach ($slots as $s) {
            $availableSlots[] = [
                'time' => $s,
                'available' => !in_array($s, $booked),
            ];
        }

        jsonResponse([
            'success' => true,
            'chamber' => $chamber,
            'date' => $date,
            'slots' => $availableSlots
        ]);
    }

    // -------------------------------------------------------------
    // APPOINTMENTS (BOOKING MODULE)
    // -------------------------------------------------------------
    if ($subPath === '/appointments' && $method === 'POST') {
        $user = requireAuthUser($pdo);
        $input = getJsonInput();

        $businessId = (int)($input['business_id'] ?? 0);
        $chamberId = (int)($input['chamber_id'] ?? 0);
        $date = trim($input['date'] ?? '');
        $slotTime = trim($input['slot_time'] ?? '');
        $patientName = trim($input['patient_name'] ?? $user['name']);
        $patientPhone = trim($input['patient_phone'] ?? ($user['phone'] ?? ''));
        $patientAge = (int)($input['patient_age'] ?? 30);
        $patientGender = trim($input['patient_gender'] ?? 'Male');
        $problem = trim($input['problem_description'] ?? '');

        if (empty($businessId) || empty($chamberId) || empty($date) || empty($slotTime)) {
            jsonResponse(['success' => false, 'message' => 'Doctor, Chamber, Date and Slot Time are required'], 422);
        }

        // Enforce no double-booking on server
        $checkStmt = $pdo->prepare("SELECT id FROM appointments WHERE business_id = ? AND chamber_id = ? AND date = ? AND slot_time = ? AND status != 'cancelled' LIMIT 1");
        $checkStmt->execute([$businessId, $chamberId, $date, $slotTime]);
        if ($checkStmt->fetch()) {
            jsonResponse(['success' => false, 'message' => 'This slot has just been booked. Please choose another slot.'], 409);
        }

        // Get consultation fee
        $docStmt = $pdo->prepare("SELECT consultation_fee FROM doctor_profiles WHERE business_id = ? LIMIT 1");
        $docStmt->execute([$businessId]);
        $fee = (int)($docStmt->fetchColumn() ?: 800);

        // Next serial number
        $serStmt = $pdo->prepare("SELECT MAX(serial_no) FROM appointments WHERE business_id = ? AND chamber_id = ? AND date = ?");
        $serStmt->execute([$businessId, $chamberId, $date]);
        $serialNo = ((int)$serStmt->fetchColumn()) + 1;

        $bookingCode = 'BK-' . rand(10000, 99999);

        $insStmt = $pdo->prepare("INSERT INTO appointments (booking_code, user_id, business_id, chamber_id, date, slot_time, serial_no, patient_name, patient_phone, patient_age, patient_gender, problem_description, fee, status, payment_status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'confirmed', 'pay_at_clinic')");
        $insStmt->execute([$bookingCode, $user['id'], $businessId, $chamberId, $date, $slotTime, $serialNo, $patientName, $patientPhone, $patientAge, $patientGender, $problem, $fee]);
        $appointmentId = $pdo->lastInsertId();

        jsonResponse([
            'success' => true,
            'message' => 'Appointment booked successfully!',
            'appointment' => [
                'id' => (int)$appointmentId,
                'booking_code' => $bookingCode,
                'serial_no' => $serialNo,
                'date' => $date,
                'slot_time' => $slotTime,
                'fee' => $fee,
                'status' => 'confirmed',
                'payment_status' => 'pay_at_clinic'
            ]
        ], 201);
    }

    if ($subPath === '/appointments' && $method === 'GET') {
        $user = requireAuthUser($pdo);
        $status = $_GET['status'] ?? '';

        $sql = "SELECT a.*, b.name as doctor_name, b.logo as doctor_photo, c.name as chamber_name, c.address as chamber_address, dp.specialty_name, dp.degrees
                FROM appointments a
                JOIN businesses b ON a.business_id = b.id
                JOIN chambers c ON a.chamber_id = c.id
                LEFT JOIN doctor_profiles dp ON dp.business_id = b.id
                WHERE a.user_id = ?";
        $params = [$user['id']];

        if (!empty($status)) {
            $sql .= " AND a.status = ?";
            $params[] = $status;
        }
        $sql .= " ORDER BY a.date DESC, a.slot_time DESC";

        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        jsonResponse(['success' => true, 'appointments' => $stmt->fetchAll()]);
    }

    if (preg_match('#^/appointments/(\d+)/cancel$#', $subPath, $matches) && $method === 'PUT') {
        $user = requireAuthUser($pdo);
        $id = (int)$matches[1];

        $stmt = $pdo->prepare("UPDATE appointments SET status = 'cancelled' WHERE id = ? AND user_id = ?");
        $stmt->execute([$id, $user['id']]);

        jsonResponse(['success' => true, 'message' => 'Appointment cancelled successfully']);
    }

    // -------------------------------------------------------------
    // SHOPPING MODULE & ORDERS
    // -------------------------------------------------------------
    if (preg_match('#^/shops/(\d+)/products$#', $subPath, $matches) && $method === 'GET') {
        $shopId = (int)$matches[1];
        $stmt = $pdo->prepare("SELECT p.*, c.name as category_name FROM products p LEFT JOIN categories c ON p.category_id = c.id WHERE p.business_id = ? AND p.status = 'active'");
        $stmt->execute([$shopId]);
        jsonResponse(['success' => true, 'products' => $stmt->fetchAll()]);
    }

    if (preg_match('#^/products/(\d+)$#', $subPath, $matches) && $method === 'GET') {
        $id = (int)$matches[1];
        $stmt = $pdo->prepare("SELECT p.*, b.name as shop_name, b.area as shop_area FROM products p JOIN businesses b ON p.business_id = b.id WHERE p.id = ?");
        $stmt->execute([$id]);
        $prod = $stmt->fetch();
        if (!$prod) {
            jsonResponse(['success' => false, 'message' => 'Product not found'], 404);
        }
        jsonResponse(['success' => true, 'product' => $prod]);
    }

    if ($subPath === '/orders' && $method === 'POST') {
        $user = requireAuthUser($pdo);
        $input = getJsonInput();

        $businessId = (int)($input['business_id'] ?? 0);
        $items = $input['items'] ?? [];
        $shippingName = trim($input['shipping_name'] ?? $user['name']);
        $shippingPhone = trim($input['shipping_phone'] ?? ($user['phone'] ?? ''));
        $shippingAddress = trim($input['shipping_address'] ?? '');
        $notes = trim($input['notes'] ?? '');

        if (empty($businessId) || empty($items) || empty($shippingAddress)) {
            jsonResponse(['success' => false, 'message' => 'Shop, Items and Shipping Address are required'], 422);
        }

        $subtotal = 0;
        foreach ($items as $item) {
            $price = (float)($item['price'] ?? 0);
            $qty = (int)($item['quantity'] ?? 1);
            $subtotal += ($price * $qty);
        }

        $deliveryFee = (float)getSetting('default_delivery_fee', '60');
        $total = $subtotal + $deliveryFee;
        $orderCode = 'ORD-' . rand(10000, 99999);

        $stmt = $pdo->prepare("INSERT INTO orders (order_code, user_id, business_id, shipping_name, shipping_phone, shipping_address, subtotal, delivery_fee, discount, total, payment_method, payment_status, status, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0, ?, 'cod', 'pending', 'placed', ?)");
        $stmt->execute([$orderCode, $user['id'], $businessId, $shippingName, $shippingPhone, $shippingAddress, $subtotal, $deliveryFee, $total, $notes]);
        $orderId = $pdo->lastInsertId();

        $itemStmt = $pdo->prepare("INSERT INTO order_items (order_id, product_id, product_name, price, quantity, total) VALUES (?, ?, ?, ?, ?, ?)");
        foreach ($items as $item) {
            $pid = (int)($item['product_id'] ?? 0);
            $pname = trim($item['product_name'] ?? 'Product Item');
            $pr = (float)($item['price'] ?? 0);
            $qt = (int)($item['quantity'] ?? 1);
            $tot = $pr * $qt;
            $itemStmt->execute([$orderId, $pid, $pname, $pr, $qt, $tot]);

            // Deduct stock
            $pdo->prepare("UPDATE products SET stock = MAX(0, stock - ?) WHERE id = ?")->execute([$qt, $pid]);
        }

        jsonResponse([
            'success' => true,
            'message' => 'Order placed successfully via Cash on Delivery!',
            'order' => [
                'id' => (int)$orderId,
                'order_code' => $orderCode,
                'subtotal' => $subtotal,
                'delivery_fee' => $deliveryFee,
                'total' => $total,
                'status' => 'placed',
                'payment_method' => 'cod'
            ]
        ], 201);
    }

    if ($subPath === '/orders' && $method === 'GET') {
        $user = requireAuthUser($pdo);
        $stmt = $pdo->prepare("SELECT o.*, b.name as shop_name, b.logo as shop_logo FROM orders o JOIN businesses b ON o.business_id = b.id WHERE o.user_id = ? ORDER BY o.id DESC");
        $stmt->execute([$user['id']]);
        $orders = $stmt->fetchAll();

        foreach ($orders as &$ord) {
            $iStmt = $pdo->prepare("SELECT * FROM order_items WHERE order_id = ?");
            $iStmt->execute([$ord['id']]);
            $ord['items'] = $iStmt->fetchAll();
        }

        jsonResponse(['success' => true, 'orders' => $orders]);
    }

    // -------------------------------------------------------------
    // ADDRESS BOOK
    // -------------------------------------------------------------
    if ($subPath === '/addresses' && $method === 'GET') {
        $user = requireAuthUser($pdo);
        $stmt = $pdo->prepare("SELECT * FROM addresses WHERE user_id = ? ORDER BY is_default DESC, id DESC");
        $stmt->execute([$user['id']]);
        jsonResponse(['success' => true, 'addresses' => $stmt->fetchAll()]);
    }

    if ($subPath === '/addresses' && $method === 'POST') {
        $user = requireAuthUser($pdo);
        $input = getJsonInput();
        $label = trim($input['label'] ?? 'Home');
        $name = trim($input['recipient_name'] ?? $user['name']);
        $phone = trim($input['phone'] ?? ($user['phone'] ?? ''));
        $address = trim($input['address'] ?? '');
        $area = trim($input['area'] ?? 'Dhaka');

        if (empty($address)) {
            jsonResponse(['success' => false, 'message' => 'Address is required'], 422);
        }

        $stmt = $pdo->prepare("INSERT INTO addresses (user_id, label, recipient_name, phone, address, area) VALUES (?, ?, ?, ?, ?, ?)");
        $stmt->execute([$user['id'], $label, $name, $phone, $address, $area]);

        jsonResponse(['success' => true, 'message' => 'Address saved successfully']);
    }

    // -------------------------------------------------------------
    // VENDOR APPLY & VENDOR DASHBOARD
    // -------------------------------------------------------------
    if ($subPath === '/vendor/apply' && $method === 'POST') {
        $user = requireAuthUser($pdo);
        $input = getJsonInput();

        $type = trim($input['type'] ?? 'doctor');
        $name = trim($input['name'] ?? '');
        $categoryId = (int)($input['category_id'] ?? 1);
        $tagline = trim($input['tagline'] ?? '');
        $address = trim($input['address'] ?? '');
        $phone = trim($input['phone'] ?? ($user['phone'] ?? ''));

        if (empty($name) || empty($address)) {
            jsonResponse(['success' => false, 'message' => 'Business Name and Address are required'], 422);
        }

        $stmt = $pdo->prepare("INSERT INTO businesses (owner_id, type, category_id, name, tagline, address, phone, status) VALUES (?, ?, ?, ?, ?, ?, ?, 'pending')");
        $stmt->execute([$user['id'], $type, $categoryId, $name, $tagline, $address, $phone]);
        $bizId = $pdo->lastInsertId();

        // Update user role
        $pdo->prepare("UPDATE users SET role = 'vendor' WHERE id = ?")->execute([$user['id']]);

        jsonResponse([
            'success' => true,
            'message' => 'Vendor application submitted! Pending admin verification.',
            'business_id' => (int)$bizId
        ]);
    }

    // -------------------------------------------------------------
    // FINANCE & SUBSCRIPTION PLANS (100% Free Lifetime)
    // -------------------------------------------------------------
    if ($subPath === '/plans' && $method === 'GET') {
        jsonResponse([
            'success' => true,
            'policy' => '100% Free Lifetime',
            'plan' => [
                'name' => 'Custom (On-Demand) Lifetime Free',
                'price' => 0,
                'currency' => 'BDT',
                'is_free' => true,
                'status' => 'active',
                'modules' => [
                    ['id' => 'sales_pos', 'name' => 'বিক্রয় ব্যবস্থাপনা (Sales POS)', 'unlocked' => true],
                    ['id' => 'purchase_mgmt', 'name' => 'ক্রয় ব্যবস্থাপনা (Purchase)', 'unlocked' => true],
                    ['id' => 'inventory', 'name' => 'স্টক/ইনভেন্টরি ব্যবস্থাপনা', 'unlocked' => true],
                    ['id' => 'hr_staff', 'name' => 'মানবসম্পদ (এইচআর) ব্যবস্থাপনা', 'unlocked' => true],
                    ['id' => 'payroll', 'name' => 'বেতন (পেরোল) ব্যবস্থাপনা', 'unlocked' => true],
                    ['id' => 'cash_book', 'name' => 'ক্যাশ বুক ও ব্যাংক বুক', 'unlocked' => true],
                    ['id' => 'dena_pawna', 'name' => 'দেনা/পাওনা ও কাস্টমার লেজার', 'unlocked' => true],
                    ['id' => 'pdf_export', 'name' => 'পিডিএফ ও এক্সেল রিপোর্ট', 'unlocked' => true],
                ]
            ]
        ]);
    }

    if ($subPath === '/finance/categories' && $method === 'GET') {
        $stmt = $pdo->query("SELECT * FROM categories WHERE module IN ('finance_personal', 'finance_business') ORDER BY id ASC");
        jsonResponse(['success' => true, 'categories' => $stmt->fetchAll()]);
    }

    if ($subPath === '/finance/categories' && $method === 'POST') {
        $user = requireAuthUser($pdo);
        $userId = (int)$user['id'];
        $input = getJsonInput();

        $name = trim($input['name'] ?? '');
        $type = trim($input['type'] ?? 'expense');
        $mode = trim($input['mode'] ?? 'personal');
        $icon = trim($input['icon'] ?? 'category');
        $color = trim($input['color'] ?? '#0284C7');

        if (empty($name)) {
            jsonResponse(['success' => false, 'message' => 'Category name is required'], 422);
        }

        $catId = $input['id'] ?? ('cat_' . time() . '_' . rand(100, 999));
        $stmt = $pdo->prepare("INSERT INTO finance_categories (user_id, cat_id, name, type, mode, icon, color) VALUES (?, ?, ?, ?, ?, ?, ?)");
        $stmt->execute([$userId, $catId, $name, $type, $mode, $icon, $color]);

        jsonResponse([
            'success' => true,
            'message' => 'Category created successfully',
            'category' => [
                'id' => $catId,
                'name' => $name,
                'type' => $type,
                'mode' => $mode,
                'icon' => $icon,
                'color' => $color,
            ]
        ], 201);
    }

    // -------------------------------------------------------------
    // USER-SCOPED FINANCE DATA (FROM DATABASE)
    // -------------------------------------------------------------
    if ($subPath === '/finance/data' && $method === 'GET') {
        $user = requireAuthUser($pdo);
        $userId = (int)$user['id'];

        // Accounts
        $stmt = $pdo->prepare("SELECT account_id as id, name, type, provider, account_number as accountNumber, initial_balance as initialBalance, COALESCE(mode, 'personal') as mode FROM finance_accounts WHERE user_id = ? ORDER BY id ASC");
        $stmt->execute([$userId]);
        $accounts = $stmt->fetchAll();

        // Transactions
        $stmt = $pdo->prepare("SELECT tx_id as id, amount, type, mode, category, account, to_account as toAccount, voucher_no as voucherNo, note, date FROM finance_transactions WHERE user_id = ? ORDER BY date DESC, id DESC");
        $stmt->execute([$userId]);
        $transactions = $stmt->fetchAll();

        // Products
        $stmt = $pdo->prepare("SELECT product_id as id, name, category, unit, stock, buy_price as buyPrice, sell_price as sellPrice FROM finance_products WHERE user_id = ? ORDER BY id DESC");
        $stmt->execute([$userId]);
        $products = $stmt->fetchAll();

        // Parties
        $stmt = $pdo->prepare("SELECT party_id as id, type, name, phone, address, opening_balance as openingBalance, due_balance as dueBalance FROM finance_parties WHERE user_id = ? ORDER BY id DESC");
        $stmt->execute([$userId]);
        $parties = $stmt->fetchAll();

        // Invoices
        $stmt = $pdo->prepare("SELECT invoice_no as invoiceNo, customer_name as customerName, customer_phone as customerPhone, customer_address as customerAddress, items, subtotal, vat, delivery, discount, discount_type as discountType, discount_value as discountValue, total, paid_amount as paidAmount, due_amount as dueAmount, payment_method as paymentMethod, payment_status as paymentStatus, date, status FROM finance_invoices WHERE user_id = ? ORDER BY date DESC, id DESC");
        $stmt->execute([$userId]);
        $rawInvoices = $stmt->fetchAll();
        $invoices = [];
        foreach ($rawInvoices as $inv) {
            $inv['items'] = json_decode($inv['items'] ?? '[]', true) ?: [];
            $invoices[] = $inv;
        }

        // Custom Categories
        $stmt = $pdo->prepare("SELECT cat_id as id, name, type, mode, icon, color FROM finance_categories WHERE user_id = ? ORDER BY id ASC");
        $stmt->execute([$userId]);
        $categories = $stmt->fetchAll();

        jsonResponse([
            'success' => true,
            'data' => [
                'accounts' => $accounts,
                'transactions' => $transactions,
                'products' => $products,
                'parties' => $parties,
                'invoices' => $invoices,
                'categories' => $categories,
            ]
        ]);
    }

    if ($subPath === '/finance/sync' && $method === 'POST') {
        $user = requireAuthUser($pdo);
        $userId = (int)$user['id'];
        $input = getJsonInput();

        $pdo->beginTransaction();
        try {
            // 1. Accounts: update when provided and non-empty
            if (!empty($input['accounts']) && is_array($input['accounts'])) {
                $pdo->prepare("DELETE FROM finance_accounts WHERE user_id = ?")->execute([$userId]);
                $stmt = $pdo->prepare("INSERT INTO finance_accounts (user_id, account_id, name, type, provider, account_number, initial_balance, mode) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
                foreach ($input['accounts'] as $acc) {
                    $stmt->execute([
                        $userId,
                        $acc['id'] ?? uniqid('acc_'),
                        $acc['name'] ?? '',
                        $acc['type'] ?? 'cash',
                        $acc['provider'] ?? null,
                        $acc['accountNumber'] ?? null,
                        (float)($acc['initialBalance'] ?? 0),
                        $acc['mode'] ?? 'personal',
                    ]);
                }
            }

            // 2. Transactions: only replace if provided and non-empty, OR if explicitly force_clear
            if (isset($input['transactions']) && is_array($input['transactions'])) {
                if (!empty($input['transactions']) || !empty($input['clear_transactions'])) {
                    $pdo->prepare("DELETE FROM finance_transactions WHERE user_id = ?")->execute([$userId]);
                    $stmt = $pdo->prepare("INSERT INTO finance_transactions (user_id, tx_id, amount, type, mode, category, account, to_account, voucher_no, note, date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
                    foreach ($input['transactions'] as $tx) {
                        $dateVal = $tx['date'] ?? date('Y-m-d H:i:s');
                        // Clean up ISO date if needed
                        $dateVal = str_replace('T', ' ', preg_replace('/\.\d+Z?$/', '', $dateVal));
                        $stmt->execute([
                            $userId,
                            $tx['id'] ?? uniqid('tx_'),
                            (float)($tx['amount'] ?? 0),
                            $tx['type'] ?? 'expense',
                            $tx['mode'] ?? 'personal',
                            $tx['category'] ?? '',
                            $tx['account'] ?? '',
                            $tx['toAccount'] ?? null,
                            $tx['voucherNo'] ?? null,
                            $tx['note'] ?? '',
                            $dateVal,
                        ]);
                    }
                }
            }

            // 3. Products: only replace if provided and non-empty
            if (isset($input['products']) && is_array($input['products'])) {
                if (!empty($input['products']) || !empty($input['clear_products'])) {
                    $pdo->prepare("DELETE FROM finance_products WHERE user_id = ?")->execute([$userId]);
                    $stmt = $pdo->prepare("INSERT INTO finance_products (user_id, product_id, name, category, unit, stock, buy_price, sell_price) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
                    foreach ($input['products'] as $prod) {
                        $stmt->execute([
                            $userId,
                            $prod['id'] ?? uniqid('prod_'),
                            $prod['name'] ?? '',
                            $prod['category'] ?? 'General',
                            $prod['unit'] ?? 'PCS',
                            (float)($prod['stock'] ?? 0),
                            (float)($prod['buyPrice'] ?? 0),
                            (float)($prod['sellPrice'] ?? 0),
                        ]);
                    }
                }
            }

            // 4. Parties: only replace if provided and non-empty
            if (isset($input['parties']) && is_array($input['parties'])) {
                if (!empty($input['parties']) || !empty($input['clear_parties'])) {
                    $pdo->prepare("DELETE FROM finance_parties WHERE user_id = ?")->execute([$userId]);
                    $stmt = $pdo->prepare("INSERT INTO finance_parties (user_id, party_id, type, name, phone, address, opening_balance, due_balance) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
                    foreach ($input['parties'] as $pty) {
                        $stmt->execute([
                            $userId,
                            $pty['id'] ?? uniqid('pty_'),
                            $pty['type'] ?? 'customer',
                            $pty['name'] ?? '',
                            $pty['phone'] ?? '',
                            $pty['address'] ?? '',
                            (float)($pty['openingBalance'] ?? 0),
                            (float)($pty['dueBalance'] ?? 0),
                        ]);
                    }
                }
            }

            // 5. Invoices: only replace if provided and non-empty
            if (isset($input['invoices']) && is_array($input['invoices'])) {
                if (!empty($input['invoices']) || !empty($input['clear_invoices'])) {
                    $pdo->prepare("DELETE FROM finance_invoices WHERE user_id = ?")->execute([$userId]);
                    $stmt = $pdo->prepare("INSERT INTO finance_invoices (user_id, invoice_no, customer_name, customer_phone, customer_address, items, subtotal, vat, delivery, discount, discount_type, discount_value, total, paid_amount, due_amount, payment_method, payment_status, date, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
                    foreach ($input['invoices'] as $inv) {
                        $invDate = $inv['date'] ?? date('Y-m-d H:i:s');
                        $invDate = str_replace('T', ' ', preg_replace('/\.\d+Z?$/', '', $invDate));
                        $stmt->execute([
                            $userId,
                            $inv['invoiceNo'] ?? uniqid('INV-'),
                            $inv['customerName'] ?? '',
                            $inv['customerPhone'] ?? '',
                            $inv['customerAddress'] ?? '',
                            json_encode($inv['items'] ?? []),
                            (float)($inv['subtotal'] ?? 0),
                            (float)($inv['vat'] ?? 0),
                            (float)($inv['delivery'] ?? 0),
                            (float)($inv['discount'] ?? 0),
                            $inv['discountType'] ?? 'fixed',
                            (float)($inv['discountValue'] ?? 0),
                            (float)($inv['total'] ?? 0),
                            (float)($inv['paidAmount'] ?? 0),
                            (float)($inv['dueAmount'] ?? 0),
                            $inv['paymentMethod'] ?? 'Cash',
                            $inv['paymentStatus'] ?? 'paid',
                            $invDate,
                            $inv['status'] ?? 'approved',
                        ]);
                    }
                }
            }

            // 6. Categories: sync user custom categories
            if (isset($input['categories']) && is_array($input['categories'])) {
                $pdo->prepare("DELETE FROM finance_categories WHERE user_id = ?")->execute([$userId]);
                $stmt = $pdo->prepare("INSERT INTO finance_categories (user_id, cat_id, name, type, mode, icon, color) VALUES (?, ?, ?, ?, ?, ?, ?)");
                foreach ($input['categories'] as $cat) {
                    $stmt->execute([
                        $userId,
                        $cat['id'] ?? uniqid('cat_'),
                        $cat['name'] ?? '',
                        $cat['type'] ?? 'expense',
                        $cat['mode'] ?? 'personal',
                        $cat['icon'] ?? 'category',
                        $cat['color'] ?? '#0284C7',
                    ]);
                }
            }

            $pdo->commit();
            jsonResponse([
                'success' => true,
                'message' => 'Finance data synced to database successfully'
            ]);
        } catch (\Throwable $e) {
            $pdo->rollBack();
            jsonResponse([
                'success' => false,
                'message' => 'Sync transaction error: ' . $e->getMessage()
            ], 500);
        }
    }

    if ($subPath === '/finance/clear' && $method === 'POST') {
        $user = requireAuthUser($pdo);
        $userId = (int)$user['id'];
        $pdo->prepare("DELETE FROM finance_accounts WHERE user_id = ?")->execute([$userId]);
        $pdo->prepare("DELETE FROM finance_transactions WHERE user_id = ?")->execute([$userId]);
        $pdo->prepare("DELETE FROM finance_products WHERE user_id = ?")->execute([$userId]);
        $pdo->prepare("DELETE FROM finance_parties WHERE user_id = ?")->execute([$userId]);
        $pdo->prepare("DELETE FROM finance_invoices WHERE user_id = ?")->execute([$userId]);
        $pdo->prepare("DELETE FROM finance_categories WHERE user_id = ?")->execute([$userId]);

        jsonResponse(['success' => true, 'message' => 'All user finance data cleared from database']);
    }

    // Fallback 404
    jsonResponse(['success' => false, 'message' => "Endpoint not found: {$method} {$subPath}"], 404);
}

