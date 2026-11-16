<?php
// backend/app/db.php - Database connection & migration/seeding

class DB {
    private static ?PDO $pdo = null;

    public static function getConnection(): PDO {
        if (self::$pdo !== null) {
            return self::$pdo;
        }

        $configFile = __DIR__ . '/../data/config.json';
        $config = [];
        if (file_exists($configFile)) {
            $config = json_decode(file_get_contents($configFile), true) ?: [];
        }

        $dbType = $config['db_type'] ?? 'sqlite';
        $dbHost = $config['db_host'] ?? '127.0.0.1';
        $dbName = $config['db_name'] ?? '';
        $dbUser = $config['db_user'] ?? '';
        $dbPass = $config['db_pass'] ?? '';

        if ($dbType === 'mysql' && !empty($dbName)) {
            try {
                $dsn = "mysql:host={$dbHost};dbname={$dbName};charset=utf8mb4";
                self::$pdo = new PDO($dsn, $dbUser, $dbPass, [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false,
                ]);
                self::ensureSchema(false);
                return self::$pdo;
            } catch (Exception $e) {
                error_log("MySQL connection failed, falling back to SQLite: " . $e->getMessage());
            }
        }

        // SQLite fallback (reliable on all shared hosting)
        $dataDir = __DIR__ . '/../data';
        if (!is_dir($dataDir)) {
            mkdir($dataDir, 0755, true);
        }
        $sqlitePath = $dataDir . '/priyodeal.sqlite';
        $isNew = !file_exists($sqlitePath);

        self::$pdo = new PDO("sqlite:" . $sqlitePath, null, null, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
        ]);
        self::$pdo->exec("PRAGMA foreign_keys = ON;");

        self::ensureSchema(true);
        if ($isNew) {
            self::seedData();
        }

        return self::$pdo;
    }

    private static function ensureSchema(bool $isSqlite): void {
        $idCol = $isSqlite ? "INTEGER PRIMARY KEY AUTOINCREMENT" : "INT AUTO_INCREMENT PRIMARY KEY";
        $dtDefault = $isSqlite ? "DATETIME DEFAULT CURRENT_TIMESTAMP" : "DATETIME DEFAULT CURRENT_TIMESTAMP";

        $schema = [
            "CREATE TABLE IF NOT EXISTS users (
                id {$idCol},
                name VARCHAR(150) NOT NULL,
                phone VARCHAR(30) UNIQUE,
                email VARCHAR(150) UNIQUE,
                password VARCHAR(255),
                role VARCHAR(30) DEFAULT 'customer',
                avatar VARCHAR(255),
                gender VARCHAR(20),
                dob DATE,
                status VARCHAR(30) DEFAULT 'active',
                api_token VARCHAR(100),
                created_at {$dtDefault}
            );",

            "CREATE TABLE IF NOT EXISTS categories (
                id {$idCol},
                module VARCHAR(30) NOT NULL,
                parent_id INT DEFAULT 0,
                name VARCHAR(100) NOT NULL,
                slug VARCHAR(100) NOT NULL,
                icon VARCHAR(100) DEFAULT 'folder',
                image VARCHAR(255),
                sort_order INT DEFAULT 0,
                status VARCHAR(20) DEFAULT 'active',
                created_at {$dtDefault}
            );",

            "CREATE TABLE IF NOT EXISTS businesses (
                id {$idCol},
                owner_id INT DEFAULT 1,
                type VARCHAR(30) NOT NULL,
                category_id INT DEFAULT 0,
                name VARCHAR(150) NOT NULL,
                tagline VARCHAR(255),
                description TEXT,
                logo VARCHAR(255),
                cover VARCHAR(255),
                address VARCHAR(255),
                area VARCHAR(100) DEFAULT 'Dhaka',
                lat REAL DEFAULT 23.8103,
                lng REAL DEFAULT 90.4125,
                phone VARCHAR(30),
                email VARCHAR(150),
                working_hours VARCHAR(150),
                status VARCHAR(30) DEFAULT 'approved',
                rating REAL DEFAULT 4.8,
                reviews_count INT DEFAULT 12,
                rejection_reason TEXT,
                created_at {$dtDefault}
            );",

            "CREATE TABLE IF NOT EXISTS doctor_profiles (
                id {$idCol},
                business_id INT NOT NULL,
                specialty_id INT DEFAULT 0,
                specialty_name VARCHAR(100),
                degrees VARCHAR(255),
                bmdc_reg_no VARCHAR(50),
                experience_years INT DEFAULT 5,
                consultation_fee INT DEFAULT 800,
                follow_up_fee INT DEFAULT 500,
                about TEXT,
                created_at {$dtDefault}
            );",

            "CREATE TABLE IF NOT EXISTS chambers (
                id {$idCol},
                business_id INT NOT NULL,
                name VARCHAR(150) NOT NULL,
                hospital VARCHAR(150),
                address VARCHAR(255),
                area VARCHAR(100),
                phone VARCHAR(30),
                visiting_days VARCHAR(100) DEFAULT 'Sat, Sun, Mon, Tue, Wed',
                visiting_time VARCHAR(100) DEFAULT '5:00 PM - 9:00 PM',
                slot_minutes INT DEFAULT 15,
                max_patients INT DEFAULT 25,
                created_at {$dtDefault}
            );",

            "CREATE TABLE IF NOT EXISTS appointments (
                id {$idCol},
                booking_code VARCHAR(30) UNIQUE,
                user_id INT NOT NULL,
                business_id INT NOT NULL,
                chamber_id INT NOT NULL,
                date DATE NOT NULL,
                slot_time VARCHAR(20) NOT NULL,
                serial_no INT DEFAULT 1,
                patient_name VARCHAR(150) NOT NULL,
                patient_phone VARCHAR(30) NOT NULL,
                patient_age INT DEFAULT 30,
                patient_gender VARCHAR(20) DEFAULT 'Male',
                problem_description TEXT,
                fee INT DEFAULT 800,
                status VARCHAR(30) DEFAULT 'confirmed',
                payment_status VARCHAR(30) DEFAULT 'pay_at_clinic',
                created_at {$dtDefault}
            );",

            "CREATE TABLE IF NOT EXISTS products (
                id {$idCol},
                business_id INT NOT NULL,
                category_id INT DEFAULT 0,
                name VARCHAR(200) NOT NULL,
                description TEXT,
                price REAL NOT NULL,
                discount_price REAL,
                stock INT DEFAULT 100,
                image VARCHAR(255),
                unit VARCHAR(50) DEFAULT 'item',
                status VARCHAR(30) DEFAULT 'active',
                created_at {$dtDefault}
            );",

            "CREATE TABLE IF NOT EXISTS addresses (
                id {$idCol},
                user_id INT NOT NULL,
                label VARCHAR(50) DEFAULT 'Home',
                recipient_name VARCHAR(150),
                phone VARCHAR(30),
                address TEXT NOT NULL,
                area VARCHAR(100) DEFAULT 'Dhaka',
                is_default INT DEFAULT 1,
                created_at {$dtDefault}
            );",

            "CREATE TABLE IF NOT EXISTS orders (
                id {$idCol},
                order_code VARCHAR(30) UNIQUE,
                user_id INT NOT NULL,
                business_id INT NOT NULL,
                address_id INT DEFAULT 0,
                shipping_name VARCHAR(150),
                shipping_phone VARCHAR(30),
                shipping_address TEXT,
                subtotal REAL NOT NULL,
                delivery_fee REAL DEFAULT 60,
                discount REAL DEFAULT 0,
                total REAL NOT NULL,
                payment_method VARCHAR(50) DEFAULT 'cod',
                payment_status VARCHAR(30) DEFAULT 'pending',
                status VARCHAR(30) DEFAULT 'placed',
                notes TEXT,
                created_at {$dtDefault}
            );",

            "CREATE TABLE IF NOT EXISTS order_items (
                id {$idCol},
                order_id INT NOT NULL,
                product_id INT NOT NULL,
                product_name VARCHAR(200) NOT NULL,
                price REAL NOT NULL,
                quantity INT NOT NULL,
                total REAL NOT NULL
            );",

            "CREATE TABLE IF NOT EXISTS banners (
                id {$idCol},
                title VARCHAR(150) NOT NULL,
                subtitle VARCHAR(255),
                image VARCHAR(255) NOT NULL,
                target_url VARCHAR(255),
                sort_order INT DEFAULT 0,
                status VARCHAR(20) DEFAULT 'active',
                created_at {$dtDefault}
            );",

            "CREATE TABLE IF NOT EXISTS settings (
                key_name VARCHAR(100) PRIMARY KEY,
                key_value TEXT
            );",

            "CREATE TABLE IF NOT EXISTS otp_codes (
                id {$idCol},
                phone VARCHAR(30) NOT NULL,
                code VARCHAR(10) NOT NULL,
                expires_at DATETIME NOT NULL,
                verified INT DEFAULT 0,
                created_at {$dtDefault}
            );",

            "CREATE TABLE IF NOT EXISTS finance_accounts (
                id {$idCol},
                user_id INT NOT NULL,
                account_id VARCHAR(100) NOT NULL,
                name VARCHAR(150) NOT NULL,
                type VARCHAR(50) NOT NULL,
                provider VARCHAR(100),
                account_number VARCHAR(100),
                initial_balance REAL DEFAULT 0,
                mode VARCHAR(50) DEFAULT 'personal',
                created_at {$dtDefault}
            );",

            "CREATE TABLE IF NOT EXISTS finance_categories (
                id {$idCol},
                user_id INT NOT NULL,
                cat_id VARCHAR(100) NOT NULL,
                name VARCHAR(150) NOT NULL,
                type VARCHAR(50) NOT NULL,
                mode VARCHAR(50) DEFAULT 'personal',
                icon VARCHAR(100) DEFAULT 'category',
                color VARCHAR(50) DEFAULT '#0284C7',
                created_at {$dtDefault}
            );",

            "CREATE TABLE IF NOT EXISTS finance_transactions (
                id {$idCol},
                user_id INT NOT NULL,
                tx_id VARCHAR(100) NOT NULL,
                amount REAL NOT NULL,
                type VARCHAR(50) NOT NULL,
                mode VARCHAR(50) DEFAULT 'personal',
                category VARCHAR(100),
                account VARCHAR(150),
                to_account VARCHAR(150),
                voucher_no VARCHAR(50),
                note TEXT,
                date DATETIME,
                created_at {$dtDefault}
            );",

            "CREATE TABLE IF NOT EXISTS finance_products (
                id {$idCol},
                user_id INT NOT NULL,
                product_id VARCHAR(100) NOT NULL,
                name VARCHAR(200) NOT NULL,
                category VARCHAR(100),
                unit VARCHAR(50) DEFAULT 'PCS',
                stock REAL DEFAULT 0,
                buy_price REAL DEFAULT 0,
                sell_price REAL DEFAULT 0,
                created_at {$dtDefault}
            );",

            "CREATE TABLE IF NOT EXISTS finance_parties (
                id {$idCol},
                user_id INT NOT NULL,
                party_id VARCHAR(100) NOT NULL,
                type VARCHAR(50) DEFAULT 'customer',
                name VARCHAR(150) NOT NULL,
                phone VARCHAR(50),
                address TEXT,
                opening_balance REAL DEFAULT 0,
                due_balance REAL DEFAULT 0,
                created_at {$dtDefault}
            );",

            "CREATE TABLE IF NOT EXISTS finance_invoices (
                id {$idCol},
                user_id INT NOT NULL,
                invoice_no VARCHAR(100) NOT NULL,
                customer_name VARCHAR(150) NOT NULL,
                customer_phone VARCHAR(50),
                customer_address TEXT,
                items TEXT,
                subtotal REAL DEFAULT 0,
                vat REAL DEFAULT 0,
                delivery REAL DEFAULT 0,
                discount REAL DEFAULT 0,
                discount_type VARCHAR(20) DEFAULT 'fixed',
                discount_value REAL DEFAULT 0,
                total REAL NOT NULL,
                paid_amount REAL DEFAULT 0,
                due_amount REAL DEFAULT 0,
                payment_method VARCHAR(50) DEFAULT 'Cash',
                payment_status VARCHAR(50) DEFAULT 'paid',
                date DATETIME,
                status VARCHAR(50) DEFAULT 'approved',
                created_at {$dtDefault}
            );"
        ];

        foreach ($schema as $sql) {
            self::$pdo->exec($sql);
        }

        // Add user profile and password reset columns if not exists
        $userCols = ['address VARCHAR(255)', 'city VARCHAR(100)', 'business_name VARCHAR(150)', 'reset_code VARCHAR(20)'];
        foreach ($userCols as $col) {
            try {
                self::$pdo->exec("ALTER TABLE users ADD COLUMN {$col}");
            } catch (\Throwable $e) {
                // Column likely already exists
            }
        }

        // Add mode column to finance_accounts for strict Personal vs Business isolation
        try {
            self::$pdo->exec("ALTER TABLE finance_accounts ADD COLUMN mode VARCHAR(50) DEFAULT 'personal'");
        } catch (\Throwable $e) {
            // Column likely already exists
        }
    }

    public static function seedData(): void {
        $pdo = self::$pdo;

        // Admin User
        $adminPass = password_hash('admin123', PASSWORD_BCRYPT);
        $userPass = password_hash('123456', PASSWORD_BCRYPT);

        $pdo->prepare("INSERT OR IGNORE INTO users (id, name, phone, email, password, role, status) VALUES 
            (1, 'Super Admin', '01700000000', 'admin@priyodeal.com', ?, 'admin', 'active'),
            (2, 'Dr. Rafiqul Hasan', '01711111111', 'dr.rafiq@priyodeal.com', ?, 'vendor', 'active'),
            (3, 'Dhaka Fresh Mart', '01722222222', 'shop@priyodeal.com', ?, 'vendor', 'active')
        ")->execute([$adminPass, $userPass, $userPass]);

        // Categories
        $categories = [
            // Booking (Doctor specialties)
            ['booking', 'General Physician', 'general-physician', 'stethoscope', 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=300', 1],
            ['booking', 'Cardiologist', 'cardiologist', 'heart-pulse', 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=300', 2],
            ['booking', 'Pediatrician (Child Specialist)', 'pediatrician', 'baby', 'https://images.unsplash.com/photo-1584515979956-d9f6e5d09982?w=300', 3],
            ['booking', 'Dermatologist (Skin)', 'dermatologist', 'sparkles', 'https://images.unsplash.com/photo-1512290900672-1f55b9a897f2?w=300', 4],
            ['booking', 'Gynecologist', 'gynecologist', 'user', 'https://images.unsplash.com/photo-1594824813627-2c5e533b827e?w=300', 5],
            ['booking', 'Dentist', 'dentist', 'smile', 'https://images.unsplash.com/photo-1606811841689-23dfddce3e95?w=300', 6],
            // Shopping categories
            ['shopping', 'Daily Grocery', 'grocery', 'shopping-cart', 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=300', 1],
            ['shopping', 'Pharmacy & Healthcare', 'pharmacy', 'pill', 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=300', 2],
            ['shopping', 'Fashion & Clothing', 'fashion', 'shirt', 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=300', 3],
            ['shopping', 'Electronics & Gadgets', 'electronics', 'smartphone', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=300', 4],
            ['shopping', 'Home & Living', 'home-living', 'home', 'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=300', 5]
        ];

        $catStmt = $pdo->prepare("INSERT INTO categories (module, name, slug, icon, image, sort_order) VALUES (?, ?, ?, ?, ?, ?)");
        foreach ($categories as $cat) {
            $catStmt->execute($cat);
        }

        // Businesses (Doctors & Shops)
        $businesses = [
            // Doctor 1
            [2, 'doctor', 1, 'Prof. Dr. Rafiqul Hasan', 'Senior Consultant - Internal Medicine', 'Expert in diabetes, hypertension, and complex medical disorders with over 18 years of clinical experience.', 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=300', 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=800', 'Dhanmondi, Dhaka', 'Dhanmondi', 23.7461, 90.3742, '01711111111', 'dr.rafiq@priyodeal.com', 'Sat - Wed: 5 PM - 9 PM', 'approved', 4.9, 142],
            // Doctor 2
            [2, 'doctor', 2, 'Dr. Farhana Chowdhury', 'Interventional Cardiologist', 'Specialist in heart disease, angiography, echocardiogram, and preventative cardiac care.', 'https://images.unsplash.com/photo-1594824813627-2c5e533b827e?w=300', 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=800', 'Panthapath, Dhaka', 'Panthapath', 23.7516, 90.3886, '01711222333', 'dr.farhana@priyodeal.com', 'Mon - Thu: 6 PM - 10 PM', 'approved', 4.8, 98],
            // Doctor 3
            [2, 'doctor', 3, 'Dr. Mahbubur Rahman', 'Child & Adolescent Specialist', 'Compassionate pediatric care, neonatal management, infant vaccination, and child nutrition guidance.', 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=300', 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=800', 'Mirpur 10, Dhaka', 'Mirpur', 23.8071, 90.3686, '01711333444', 'dr.mahbub@priyodeal.com', 'Daily: 4 PM - 8 PM', 'approved', 4.9, 87],
            // Doctor 4
            [2, 'doctor', 4, 'Dr. Sadia Sultana', 'Consultant Dermatologist & Cosmetologist', 'Expertise in skin diseases, acne scar treatment, allergy, laser therapies, and hair care.', 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=300', 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=800', 'Gulshan 2, Dhaka', 'Gulshan', 23.7925, 90.4078, '01711444555', 'dr.sadia@priyodeal.com', 'Sat - Wed: 3 PM - 7 PM', 'approved', 4.7, 64],
            // Shop 1
            [3, 'shop', 7, 'Dhaka Fresh Mart', 'Fresh Organic Groceries & Daily Needs', 'Premium groceries, farm-fresh vegetables, dairy, cooking oil, spices, and imported culinary goods delivered to your doorstep in 1 hour.', 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=300', 'https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=800', 'House 14, Road 7, Banani, Dhaka', 'Banani', 23.7937, 90.4066, '01722222222', 'shop@priyodeal.com', '8:00 AM - 11:00 PM', 'approved', 4.9, 310],
            // Shop 2
            [3, 'shop', 8, 'Green Care Pharmacy', '100% Authentic Medicines & Healthcare Supplies', 'Licensed pharmacy stocking genuine medicines, baby food, orthopedic supports, diabetic care supplies, and personal hygiene products.', 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=300', 'https://images.unsplash.com/photo-1586015555751-63bb77f4322a?w=800', 'Dhanmondi 27, Dhaka', 'Dhanmondi', 23.7533, 90.3769, '01755556666', 'greencare@priyodeal.com', '24 Hours Open', 'approved', 4.8, 185],
            // Shop 3
            [3, 'shop', 10, 'Bengal Tech Hub', 'Genuine Smartphones, Audio & Gadgets', 'Authorised accessories, original chargers, smart watches, wireless earbuds, power banks, and tech accessories with official warranty.', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=300', 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=800', 'Multiplan Center, New Elephant Road, Dhaka', 'Elephant Road', 23.7388, 90.3855, '01788889999', 'techhub@priyodeal.com', '10:00 AM - 9:00 PM', 'approved', 4.7, 94]
        ];

        $bizStmt = $pdo->prepare("INSERT INTO businesses (owner_id, type, category_id, name, tagline, description, logo, cover, address, area, lat, lng, phone, email, working_hours, status, rating, reviews_count) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        foreach ($businesses as $b) {
            $bizStmt->execute($b);
        }

        // Doctor Profiles
        $docProfiles = [
            [1, 1, 'General Physician', 'MBBS (DMC), FCPS (Medicine), MACP (USA)', 'A-34821', 18, 1000, 600, 'Gold Medalist physician with extensive experience treating chronic internal ailments, uncontrolled diabetes, and complex respiratory conditions.'],
            [2, 2, 'Cardiologist', 'MBBS, MD (Cardiology), NICVD, Fellow ESC', 'A-49210', 14, 1200, 800, 'Specialist in non-invasive cardiology, coronary intervention, hypertension management, and heart failure protocols.'],
            [3, 3, 'Pediatrician', 'MBBS, DCH, FCPS (Pediatrics), BSMMU', 'A-51203', 12, 800, 500, 'Devoted child healthcare expert focusing on growth tracking, childhood asthma, infectious pediatric diseases, and newborn care.'],
            [4, 4, 'Dermatologist', 'MBBS, DDV, FCPS (Dermatology)', 'A-42195', 10, 900, 600, 'Certified dermatologist experienced in clinical skin disease diagnosis, modern aesthetic procedures, and hair fall therapies.']
        ];
        $docStmt = $pdo->prepare("INSERT INTO doctor_profiles (business_id, specialty_id, specialty_name, degrees, bmdc_reg_no, experience_years, consultation_fee, follow_up_fee, about) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
        foreach ($docProfiles as $dp) {
            $docStmt->execute($dp);
        }

        // Chambers
        $chambers = [
            [1, 'Chamber 1 - Square Hospital Annex', 'Square Hospital', '18/F Bir Uttam Qazi Nuruzzaman Sarak, Panthapath, Dhaka', 'Panthapath', '01711111111', 'Sat, Mon, Wed', '5:00 PM - 9:00 PM', 15, 20],
            [1, 'Chamber 2 - Ibn Sina Diagnostic Dhanmondi', 'Ibn Sina Diagnostic Center', 'House 48, Road 9/A, Dhanmondi, Dhaka', 'Dhanmondi', '01711111112', 'Sun, Tue, Thu', '6:00 PM - 9:30 PM', 15, 25],
            [2, 'Chamber 1 - Labaid Cardiac Hospital', 'Labaid Cardiac Hospital', 'House 01, Road 04, Dhanmondi, Dhaka', 'Dhanmondi', '01711222333', 'Mon, Tue, Wed, Thu', '6:00 PM - 10:00 PM', 20, 15],
            [3, 'Chamber 1 - Popular Diagnostic Mirpur', 'Popular Diagnostic Center', 'House 02, Block A, Mirpur 10, Dhaka', 'Mirpur', '01711333444', 'Daily (except Fri)', '4:00 PM - 8:00 PM', 15, 30],
            [4, 'Chamber 1 - United Hospital Medical Center', 'United Hospital Gulshan', 'Plot 15, Road 71, Gulshan 2, Dhaka', 'Gulshan', '01711444555', 'Sat, Sun, Mon, Wed', '3:00 PM - 7:00 PM', 15, 20]
        ];
        $chStmt = $pdo->prepare("INSERT INTO chambers (business_id, name, hospital, address, area, phone, visiting_days, visiting_time, slot_minutes, max_patients) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        foreach ($chambers as $ch) {
            $chStmt->execute($ch);
        }

        // Products for shops (business_id 5 = Dhaka Fresh Mart, 6 = Green Care Pharmacy, 7 = Bengal Tech Hub)
        $products = [
            // Grocery
            [5, 7, 'Pran Pure Mustard Oil (1 Litre)', '100% natural, cold-pressed mustard oil with pungent aroma for traditional cooking.', 320, 290, 50, 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400', 'bottle'],
            [5, 7, 'Chashi Aromatic Chinigura Rice (1 Kg)', 'Finest aromatic premium rice with authentic fragrance, ideal for special polao and biryani.', 140, 125, 80, 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400', 'pack'],
            [5, 7, 'Fresh Farm Brown Eggs (1 Dozen)', 'Nutritious farm-fresh brown eggs, rich in protein, cleaned and graded.', 160, 145, 100, 'https://images.unsplash.com/photo-1506976785307-8732e854ad03?w=400', 'box'],
            [5, 7, 'Teer Fortified Soybean Oil (5 Litre)', 'Vitamin A enriched triple refined soybean oil for healthy daily cooking.', 840, 810, 40, 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400', 'can'],
            [5, 7, 'Aarong Dairy Pure Ghee (400g)', 'Traditional golden ghee made from fresh cow milk butter with rich aroma.', 650, 599, 35, 'https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=400', 'jar'],
            // Pharmacy
            [6, 8, 'Napa Extra Paracetamol 500mg+65mg (Box of 100)', 'Fast relief from headache, fever, toothache, and body pain.', 250, 240, 150, 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400', 'box'],
            [6, 8, 'Savlon Antiseptic Liquid (1 Litre)', 'Proven hospital-grade antiseptic liquid for first aid, cuts, and surface disinfection.', 380, 360, 60, 'https://images.unsplash.com/photo-1583947581924-860bda6a26df?w=400', 'bottle'],
            [6, 8, 'Accu-Chek Instant Blood Glucose Meter', 'No setup required, simple instant blood sugar testing kit with 10 test strips.', 2200, 1950, 20, 'https://images.unsplash.com/photo-1615461066841-6116e61058f4?w=400', 'kit'],
            // Tech Hub
            [7, 10, 'Oraimo 20000mAh Fast Charging Power Bank', 'Dual high-speed USB output with LED battery indicator and multi-protect safety system.', 1850, 1650, 30, 'https://images.unsplash.com/photo-1609592424364-772922712f5a?w=400', 'unit'],
            [7, 10, 'Haylou Solar Pro Smart Watch (AMOLED)', '1.43-inch AMOLED display, Bluetooth calling, 100+ sports modes, and 7-day battery life.', 3400, 2999, 15, 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400', 'unit'],
            [7, 10, 'Realme Buds T110 True Wireless Earbuds', '10mm dynamic bass driver, AI ENC noise cancellation for calls, 38 hours playback.', 2100, 1850, 25, 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=400', 'pair']
        ];
        $prodStmt = $pdo->prepare("INSERT INTO products (business_id, category_id, name, description, price, discount_price, stock, image, unit) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
        foreach ($products as $pr) {
            $prodStmt->execute($pr);
        }

        // Banners
        $banners = [
            ['Get 20% Off on First Doctor Consultation', 'Consult top specialist doctors in Dhaka with zero convenience fees', 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=1000', '/booking', 1],
            ['Flash Grocery Sale: 1-Hour Super Express Delivery', 'Fresh vegetables, milk, oil and daily essentials at wholesale rates', 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=1000', '/shopping', 2],
            ['Master Your Monthly Finances with Priyo Finance', '100% offline, zero-data-leak personal income, expense & budget manager', 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=1000', '/finance', 3]
        ];
        $banStmt = $pdo->prepare("INSERT INTO banners (title, subtitle, image, target_url, sort_order) VALUES (?, ?, ?, ?, ?)");
        foreach ($banners as $bn) {
            $banStmt->execute($bn);
        }

        // Platform settings
        $settings = [
            'app_name' => 'Priyo Deal',
            'support_phone' => '+880 1700-000000',
            'support_email' => 'priyodealbd@gmail.com',
            'developer_name' => 'Md. Rabby Islam',
            'domain' => 'www.priyodeal.com.bd',
            'default_delivery_fee' => '60',
            'currency_symbol' => '৳',
            'apk_download_url' => '/downloads/priyodeal.apk',
            'apk_version' => '1.0.0',
            'apk_size' => '24 MB'
        ];
        $stStmt = $pdo->prepare("INSERT OR REPLACE INTO settings (key_name, key_value) VALUES (?, ?)");
        foreach ($settings as $k => $v) {
            $stStmt->execute([$k, $v]);
        }
    }
}

