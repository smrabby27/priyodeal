// priyodeal_app/lib/models/models.dart

class User {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String role;
  final String? token;
  final String? address;
  final String? businessName;

  User({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    required this.role,
    this.token,
    this.address,
    this.businessName,
  });

  factory User.fromJson(Map<String, dynamic> json, {String? token}) {
    return User(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? 'User',
      phone: json['phone'],
      email: json['email'],
      role: json['role'] ?? 'customer',
      token: token ?? json['api_token'],
      address: json['address'] ?? json['city'],
      businessName: json['business_name'] ?? json['businessName'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'role': role,
    'token': token,
    'address': address,
    'business_name': businessName,
  };
}

class CategoryItem {
  final int id;
  final String module;
  final String name;
  final String slug;
  final String icon;
  final String? image;

  CategoryItem({
    required this.id,
    required this.module,
    required this.name,
    required this.slug,
    required this.icon,
    this.image,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      module: json['module'] ?? 'booking',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      icon: json['icon'] ?? 'folder',
      image: json['image'],
    );
  }
}

class BusinessItem {
  final int id;
  final String type; // 'doctor' or 'shop'
  final String name;
  final String? tagline;
  final String? description;
  final String? logo;
  final String? cover;
  final String? address;
  final String area;
  final String? phone;
  final double rating;
  final int reviewsCount;
  final String? specialtyName;
  final String? degrees;
  final int consultationFee;
  final List<ChamberItem> chambers;
  final List<ProductItem> products;

  BusinessItem({
    required this.id,
    required this.type,
    required this.name,
    this.tagline,
    this.description,
    this.logo,
    this.cover,
    this.address,
    required this.area,
    this.phone,
    required this.rating,
    required this.reviewsCount,
    this.specialtyName,
    this.degrees,
    required this.consultationFee,
    this.chambers = const [],
    this.products = const [],
  });

  factory BusinessItem.fromJson(Map<String, dynamic> json) {
    List<ChamberItem> chambersList = [];
    if (json['chambers'] != null && json['chambers'] is List) {
      chambersList = (json['chambers'] as List)
          .map((c) => ChamberItem.fromJson(c))
          .toList();
    }

    List<ProductItem> prodList = [];
    if (json['products'] != null && json['products'] is List) {
      prodList = (json['products'] as List)
          .map((p) => ProductItem.fromJson(p))
          .toList();
    }

    return BusinessItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      type: json['type'] ?? 'doctor',
      name: json['name'] ?? '',
      tagline: json['tagline'],
      description: json['description'],
      logo: json['logo'],
      cover: json['cover'],
      address: json['address'],
      area: json['area'] ?? 'Dhaka',
      phone: json['phone'],
      rating: (json['rating'] != null) ? double.tryParse(json['rating'].toString()) ?? 4.8 : 4.8,
      reviewsCount: (json['reviews_count'] != null) ? int.tryParse(json['reviews_count'].toString()) ?? 0 : 0,
      specialtyName: json['specialty_name'],
      degrees: json['degrees'],
      consultationFee: (json['consultation_fee'] != null) ? int.tryParse(json['consultation_fee'].toString()) ?? 800 : 800,
      chambers: chambersList,
      products: prodList,
    );
  }
}

class ChamberItem {
  final int id;
  final int businessId;
  final String name;
  final String? hospital;
  final String? address;
  final String? phone;
  final String visitingDays;
  final String visitingTime;

  ChamberItem({
    required this.id,
    required this.businessId,
    required this.name,
    this.hospital,
    this.address,
    this.phone,
    required this.visitingDays,
    required this.visitingTime,
  });

  factory ChamberItem.fromJson(Map<String, dynamic> json) {
    return ChamberItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      businessId: json['business_id'] is int ? json['business_id'] : int.tryParse(json['business_id'].toString()) ?? 0,
      name: json['name'] ?? '',
      hospital: json['hospital'],
      address: json['address'],
      phone: json['phone'],
      visitingDays: json['visiting_days'] ?? 'Sat - Wed',
      visitingTime: json['visiting_time'] ?? '5:00 PM - 9:00 PM',
    );
  }
}

class TimeSlotItem {
  final String time;
  final bool available;

  TimeSlotItem({required this.time, required this.available});

  factory TimeSlotItem.fromJson(Map<String, dynamic> json) {
    return TimeSlotItem(
      time: json['time'] ?? '',
      available: json['available'] == true || json['available'] == 1,
    );
  }
}

class AppointmentItem {
  final int id;
  final String bookingCode;
  final int serialNo;
  final String date;
  final String slotTime;
  final int fee;
  final String status;
  final String patientName;
  final String patientPhone;
  final int patientAge;
  final String patientGender;
  final String? problem;
  final String? doctorName;
  final String? chamberName;

  AppointmentItem({
    required this.id,
    required this.bookingCode,
    required this.serialNo,
    required this.date,
    required this.slotTime,
    required this.fee,
    required this.status,
    required this.patientName,
    required this.patientPhone,
    required this.patientAge,
    required this.patientGender,
    this.problem,
    this.doctorName,
    this.chamberName,
  });

  factory AppointmentItem.fromJson(Map<String, dynamic> json) {
    return AppointmentItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      bookingCode: json['booking_code'] ?? 'BK-000',
      serialNo: json['serial_no'] is int ? json['serial_no'] : int.tryParse(json['serial_no'].toString()) ?? 1,
      date: json['date'] ?? '',
      slotTime: json['slot_time'] ?? '',
      fee: json['fee'] is int ? json['fee'] : int.tryParse(json['fee'].toString()) ?? 800,
      status: json['status'] ?? 'confirmed',
      patientName: json['patient_name'] ?? 'Patient',
      patientPhone: json['patient_phone'] ?? '',
      patientAge: json['patient_age'] is int ? json['patient_age'] : int.tryParse(json['patient_age'].toString()) ?? 30,
      patientGender: json['patient_gender'] ?? 'Male',
      problem: json['problem_description'],
      doctorName: json['doctor_name'],
      chamberName: json['chamber_name'],
    );
  }
}

class ProductItem {
  final int id;
  final int businessId;
  final int categoryId;
  final String name;
  final String? description;
  final double price;
  final double? discountPrice;
  final int stock;
  final String? image;
  final String unit;

  ProductItem({
    required this.id,
    required this.businessId,
    required this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.discountPrice,
    required this.stock,
    this.image,
    required this.unit,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      businessId: json['business_id'] is int ? json['business_id'] : int.tryParse(json['business_id'].toString()) ?? 0,
      categoryId: json['category_id'] is int ? json['category_id'] : int.tryParse(json['category_id'].toString()) ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] != null) ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
      discountPrice: (json['discount_price'] != null) ? double.tryParse(json['discount_price'].toString()) : null,
      stock: (json['stock'] != null) ? int.tryParse(json['stock'].toString()) ?? 10 : 10,
      image: json['image'],
      unit: json['unit'] ?? 'item',
    );
  }

  double get displayPrice => (discountPrice != null && discountPrice! > 0) ? discountPrice! : price;
}

class CartItem {
  final ProductItem product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.displayPrice * quantity;
}

class OrderItemData {
  final int id;
  final String orderCode;
  final String shopName;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String status;
  final String shippingAddress;
  final List<dynamic> items;

  OrderItemData({
    required this.id,
    required this.orderCode,
    required this.shopName,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.shippingAddress,
    required this.items,
  });

  factory OrderItemData.fromJson(Map<String, dynamic> json) {
    return OrderItemData(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      orderCode: json['order_code'] ?? 'ORD-000',
      shopName: json['shop_name'] ?? 'Shop',
      subtotal: (json['subtotal'] != null) ? double.tryParse(json['subtotal'].toString()) ?? 0 : 0,
      deliveryFee: (json['delivery_fee'] != null) ? double.tryParse(json['delivery_fee'].toString()) ?? 60 : 60,
      total: (json['total'] != null) ? double.tryParse(json['total'].toString()) ?? 0 : 0,
      status: json['status'] ?? 'placed',
      shippingAddress: json['shipping_address'] ?? '',
      items: json['items'] ?? [],
    );
  }
}

// -------------------------------------------------------------
// FINANCE MODULE MODELS (Personal & Business, 100% Free & Offline-First)
// -------------------------------------------------------------
class FinanceTransaction {
  final String id;
  final double amount;
  final String type; // 'income' or 'expense'
  final String mode; // 'personal' or 'business'
  final String category; // 'Food', 'Salary', 'Sales', 'Office Rent', etc.
  final String account; // 'Cash', 'Bank', 'Mobile Banking' (bKash/Nagad)
  final DateTime date;
  final String? note;
  final String? partyName; // Customer, Supplier, or Debtor/Creditor
  final String? voucherNo;

  FinanceTransaction({
    required this.id,
    required this.amount,
    required this.type,
    this.mode = 'personal',
    required this.category,
    required this.account,
    required this.date,
    this.note,
    this.partyName,
    this.voucherNo,
  });

  factory FinanceTransaction.fromJson(Map<String, dynamic> json) {
    return FinanceTransaction(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      amount: (json['amount'] != null) ? double.tryParse(json['amount'].toString()) ?? 0 : 0,
      type: json['type'] ?? 'expense',
      mode: json['mode'] ?? 'personal',
      category: json['category'] ?? 'General',
      account: json['account'] ?? 'Cash',
      date: json['date'] != null ? DateTime.tryParse(json['date']) ?? DateTime.now() : DateTime.now(),
      note: json['note'],
      partyName: json['partyName'] ?? json['party_name'],
      voucherNo: json['voucherNo'] ?? json['voucher_no'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'type': type,
    'mode': mode,
    'category': category,
    'account': account,
    'date': date.toIso8601String(),
    'note': note,
    'partyName': partyName,
    'voucherNo': voucherNo,
  };
}

class BusinessProduct {
  final String id;
  final String name;
  final String category;
  final String unit; // 'PCS', 'KG', 'Dozen', 'Pack', 'Ltr', etc.
  final double stock;
  final double buyPrice;
  final double sellPrice;
  final bool isActive;

  BusinessProduct({
    required this.id,
    required this.name,
    this.category = 'General',
    this.unit = 'PCS',
    required this.stock,
    required this.buyPrice,
    required this.sellPrice,
    this.isActive = true,
  });

  factory BusinessProduct.fromJson(Map<String, dynamic> json) => BusinessProduct(
    id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
    name: json['name'] ?? '',
    category: json['category'] ?? 'General',
    unit: json['unit'] ?? 'PCS',
    stock: (json['stock'] != null) ? double.tryParse(json['stock'].toString()) ?? 0 : 0,
    buyPrice: (json['buyPrice'] != null) ? double.tryParse(json['buyPrice'].toString()) ?? 0 : 0,
    sellPrice: (json['sellPrice'] != null) ? double.tryParse(json['sellPrice'].toString()) ?? 0 : 0,
    isActive: json['isActive'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'unit': unit,
    'stock': stock,
    'buyPrice': buyPrice,
    'sellPrice': sellPrice,
    'isActive': isActive,
  };
}

class BusinessParty {
  final String id;
  final String type; // 'customer' or 'supplier'
  final String name;
  final String phone;
  final String? address;
  final String? email;
  final double openingBalance;
  final double dueBalance; // positive = they owe us (receivable), negative = we owe them (payable)

  BusinessParty({
    required this.id,
    required this.type,
    required this.name,
    required this.phone,
    this.address,
    this.email,
    this.openingBalance = 0,
    this.dueBalance = 0,
  });

  factory BusinessParty.fromJson(Map<String, dynamic> json) => BusinessParty(
    id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
    type: json['type'] ?? 'customer',
    name: json['name'] ?? '',
    phone: json['phone'] ?? '',
    address: json['address'],
    email: json['email'],
    openingBalance: (json['openingBalance'] != null) ? double.tryParse(json['openingBalance'].toString()) ?? 0 : 0,
    dueBalance: (json['dueBalance'] != null) ? double.tryParse(json['dueBalance'].toString()) ?? 0 : 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'name': name,
    'phone': phone,
    'address': address,
    'email': email,
    'openingBalance': openingBalance,
    'dueBalance': dueBalance,
  };
}

class PaymentAccount {
  final String id;
  final String name; // e.g. "ক্যাশ বাক্স", "DBBL - 1087", "bKash - 01796382854"
  final String type; // 'cash', 'bank', 'mfs'
  final String? provider; // e.g. 'bKash', 'Nagad', 'Rocket', 'Islami Bank', 'DBBL'
  final String? accountNumber;
  final double initialBalance;
  final String mode; // 'personal' or 'business'

  PaymentAccount({
    required this.id,
    required this.name,
    required this.type,
    this.provider,
    this.accountNumber,
    this.initialBalance = 0,
    this.mode = 'personal',
  });

  factory PaymentAccount.fromJson(Map<String, dynamic> json) => PaymentAccount(
    id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
    name: json['name'] ?? 'Account',
    type: json['type'] ?? 'cash',
    provider: json['provider'],
    accountNumber: json['accountNumber'],
    initialBalance: (json['initialBalance'] != null) ? double.tryParse(json['initialBalance'].toString()) ?? 0 : 0,
    mode: json['mode'] ?? 'personal',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'provider': provider,
    'accountNumber': accountNumber,
    'initialBalance': initialBalance,
    'mode': mode,
  };
}

class BusinessSaleInvoice {
  final String invoiceNo;
  final String customerName;
  final String customerPhone;
  final String? customerAddress;
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double vat;
  final double delivery;
  final double discount;
  final String discountType; // 'fixed' or 'percentage'
  final double discountValue;
  final double total;
  final double paidAmount;
  final double dueAmount;
  final String paymentMethod; // 'Cash', 'Credit' (বাকি), 'Bank', 'Mobile Banking'
  final String paymentStatus; // 'paid', 'partial', 'due'
  final DateTime date;
  final String status; // 'approved', 'returned'

  BusinessSaleInvoice({
    required this.invoiceNo,
    required this.customerName,
    required this.customerPhone,
    this.customerAddress,
    required this.items,
    required this.subtotal,
    this.vat = 0,
    this.delivery = 0,
    this.discount = 0,
    this.discountType = 'fixed',
    this.discountValue = 0,
    required this.total,
    double? paidAmount,
    double? dueAmount,
    required this.paymentMethod,
    this.paymentStatus = 'paid',
    required this.date,
    this.status = 'approved',
  })  : paidAmount = paidAmount ?? (paymentMethod == 'Credit' ? 0 : total),
        dueAmount = dueAmount ?? (paymentMethod == 'Credit' ? total : 0);

  factory BusinessSaleInvoice.fromJson(Map<String, dynamic> json) {
    final double tot = (json['total'] != null) ? (double.tryParse(json['total'].toString()) ?? 0.0) : 0.0;
    final pm = json['paymentMethod'] ?? 'Cash';
    final pStatus = json['paymentStatus'] ?? (pm == 'Credit' ? 'due' : 'paid');
    final double paid = json['paidAmount'] != null
        ? (double.tryParse(json['paidAmount'].toString()) ?? (pm == 'Credit' ? 0.0 : tot))
        : (pm == 'Credit' ? 0.0 : tot);
    final double due = json['dueAmount'] != null
        ? (double.tryParse(json['dueAmount'].toString()) ?? (tot - paid))
        : (tot - paid);

    return BusinessSaleInvoice(
      invoiceNo: json['invoiceNo'] ?? 'INV-001',
      customerName: json['customerName'] ?? 'Customer',
      customerPhone: json['customerPhone'] ?? '',
      customerAddress: json['customerAddress'],
      items: List<Map<String, dynamic>>.from(json['items'] ?? []),
      subtotal: (json['subtotal'] != null) ? (double.tryParse(json['subtotal'].toString()) ?? 0.0) : 0.0,
      vat: (json['vat'] != null) ? (double.tryParse(json['vat'].toString()) ?? 0.0) : 0.0,
      delivery: (json['delivery'] != null) ? (double.tryParse(json['delivery'].toString()) ?? 0.0) : 0.0,
      discount: (json['discount'] != null) ? (double.tryParse(json['discount'].toString()) ?? 0.0) : 0.0,
      discountType: json['discountType'] ?? 'fixed',
      discountValue: (json['discountValue'] != null) ? (double.tryParse(json['discountValue'].toString()) ?? 0.0) : 0.0,
      total: tot,
      paidAmount: paid,
      dueAmount: due,
      paymentMethod: pm,
      paymentStatus: pStatus,
      date: json['date'] != null ? DateTime.tryParse(json['date']) ?? DateTime.now() : DateTime.now(),
      status: json['status'] ?? 'approved',
    );
  }

  Map<String, dynamic> toJson() => {
    'invoiceNo': invoiceNo,
    'customerName': customerName,
    'customerPhone': customerPhone,
    'customerAddress': customerAddress,
    'items': items,
    'subtotal': subtotal,
    'vat': vat,
    'delivery': delivery,
    'discount': discount,
    'discountType': discountType,
    'discountValue': discountValue,
    'total': total,
    'paidAmount': paidAmount,
    'dueAmount': dueAmount,
    'paymentMethod': paymentMethod,
    'paymentStatus': paymentStatus,
    'date': date.toIso8601String(),
    'status': status,
  };
}

class Budget {
  final String category;
  final double monthlyLimit;

  Budget({required this.category, required this.monthlyLimit});

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
    category: json['category'] ?? '',
    monthlyLimit: (json['monthlyLimit'] != null) ? double.tryParse(json['monthlyLimit'].toString()) ?? 0 : 0,
  );

  Map<String, dynamic> toJson() => {
    'category': category,
    'monthlyLimit': monthlyLimit,
  };
}

class SavingsGoal {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String deadline;

  SavingsGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
  });

  factory SavingsGoal.fromJson(Map<String, dynamic> json) => SavingsGoal(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    targetAmount: (json['targetAmount'] != null) ? double.tryParse(json['targetAmount'].toString()) ?? 0 : 0,
    currentAmount: (json['currentAmount'] != null) ? double.tryParse(json['currentAmount'].toString()) ?? 0 : 0,
    deadline: json['deadline'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'deadline': deadline,
  };

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0;
}

class FinanceCategory {
  final String id;
  final String name;
  final String type; // 'income' or 'expense'
  final String mode; // 'personal' or 'business'
  final String icon;
  final String color;

  FinanceCategory({
    required this.id,
    required this.name,
    required this.type,
    required this.mode,
    this.icon = 'category',
    this.color = '#0284C7',
  });

  factory FinanceCategory.fromJson(Map<String, dynamic> json) => FinanceCategory(
    id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
    name: json['name'] ?? '',
    type: json['type'] ?? 'expense',
    mode: json['mode'] ?? 'personal',
    icon: json['icon'] ?? 'category',
    color: json['color'] ?? '#0284C7',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'mode': mode,
    'icon': icon,
    'color': color,
  };
}

