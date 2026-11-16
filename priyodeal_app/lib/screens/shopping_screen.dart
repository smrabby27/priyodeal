import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BusinessItem> _shops = [];
  bool _isLoading = true;

  // Cart
  final List<CartItem> _cart = [];

  // My Orders
  List<OrderItemData> _myOrders = [];
  bool _isLoadingOrders = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final shps = await ApiService.getBusinesses(type: 'shop');

    if (mounted) {
      setState(() {
        _shops = shps;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoadingOrders = true);
    final orders = await ApiService.getUserOrders();
    if (mounted) {
      setState(() {
        _myOrders = orders;
        _isLoadingOrders = false;
      });
    }
  }

  void _addToCart(ProductItem product) {
    setState(() {
      final idx = _cart.indexWhere((item) => item.product.id == product.id);
      if (idx != -1) {
        _cart[idx].quantity++;
      } else {
        _cart.add(CartItem(product: product, quantity: 1));
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.secondary,
        content: Text('${product.name} ব্যাগে যোগ করা হয়েছে!'),
      ),
    );
  }

  void _openCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CartCheckoutSheet(
        cart: _cart,
        onOrderPlaced: () {
          setState(() => _cart.clear());
          _tabController.animateTo(1);
          _loadOrders();
        },
      ),
    );
  }

  void _openShopDetail(BusinessItem shop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ShopProductsSheet(
        shop: shop,
        onAddToCart: _addToCart,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('লোকাল শপিং ও গ্রোসারি'),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: _cart.isEmpty ? null : _openCartSheet,
                icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.textPrimary),
              ),
              if (_cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                    child: Text(
                      '${_cart.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            if (index == 1) _loadOrders();
          },
          indicatorColor: AppColors.secondary,
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'দোকান ও পণ্যসমূহ'),
            Tab(text: 'আমার অর্ডার ও ট্র্যাকিং'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildShopsTab(),
          _buildOrdersTab(),
        ],
      ),
      floatingActionButton: _cart.isNotEmpty
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.secondary,
              onPressed: _openCartSheet,
              icon: const Icon(Icons.shopping_bag_rounded, color: Colors.white),
              label: Text(
                'ব্যাগ দেখুন (${_cart.length} টি) • ৳${_cart.fold<double>(0, (sum, i) => sum + i.total).toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }

  Widget _buildShopsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0284C7), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ক্যাশ অন ডেলিভারি (COD)',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'পণ্য হাতে পেয়ে মূল্য পরিশোধের সুবিধা',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.local_shipping_rounded, color: Colors.white, size: 40),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            'জনপ্রিয় ভেরিফায়েড দোকান',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _shops.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final shop = _shops[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            shop.logo ?? 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=200',
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(shop.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(height: 2),
                              Text(shop.tagline ?? shop.area, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                                  const SizedBox(width: 2),
                                  Text('${shop.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                  const SizedBox(width: 10),
                                  const Text('ডেলিভারি চার্জ: ৳৬০', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _openShopDetail(shop),
                        child: const Text('পণ্য তালিকা ও অর্ডার করুন'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    if (_isLoadingOrders) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_shipping_outlined, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            const Text('আপনার কোনো সক্রিয় অর্ডার নেই', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('পণ্য সিলেক্ট করে ক্যাশ অন ডেলিভারিতে অর্ডার করুন', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _tabController.animateTo(0),
              child: const Text('শপ ব্রাউজ করুন'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _myOrders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = _myOrders[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderCode,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.secondary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: order.status == 'delivered' ? const Color(0xFFECFDF5) : const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: order.status == 'delivered' ? const Color(0xFF065F46) : const Color(0xFF0369A1),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(order.shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text('ডেলিভারি ঠিকানা: ${order.shippingAddress}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('পেমেন্ট: ক্যাশ অন ডেলিভারি (COD)', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  Text(
                    '৳${order.total.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// Bottom Sheet for Shop Profile & Product Catalog
class _ShopProductsSheet extends StatefulWidget {
  final BusinessItem shop;
  final Function(ProductItem) onAddToCart;

  const _ShopProductsSheet({required this.shop, required this.onAddToCart});

  @override
  State<_ShopProductsSheet> createState() => _ShopProductsSheetState();
}

class _ShopProductsSheetState extends State<_ShopProductsSheet> {
  BusinessItem? _fullShop;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final s = await ApiService.getBusinessDetail(widget.shop.id);
    if (mounted) {
      setState(() {
        _fullShop = s ?? widget.shop;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = _fullShop?.products ?? [];

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.shop.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty
                    ? const Center(child: Text('এই দোকানে কোনো পণ্য তালিকাভুক্ত নেই'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: products.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final p = products[index];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    p.image ?? 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=200',
                                    width: 75,
                                    height: 75,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            '৳${p.displayPrice.toStringAsFixed(0)}',
                                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textPrimary),
                                          ),
                                          if (p.discountPrice != null && p.discountPrice! < p.price) ...[
                                            const SizedBox(width: 6),
                                            Text(
                                              '৳${p.price.toStringAsFixed(0)}',
                                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted, decoration: TextDecoration.lineThrough),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondary,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => widget.onAddToCart(p),
                                  child: const Text('যোগ করুন', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// Cart & COD Checkout Bottom Sheet
class _CartCheckoutSheet extends StatefulWidget {
  final List<CartItem> cart;
  final VoidCallback onOrderPlaced;

  const _CartCheckoutSheet({required this.cart, required this.onOrderPlaced});

  @override
  State<_CartCheckoutSheet> createState() => _CartCheckoutSheetState();
}

class _CartCheckoutSheetState extends State<_CartCheckoutSheet> {
  final _nameController = TextEditingController(text: 'Tanvir Ahmed');
  final _phoneController = TextEditingController(text: '01833333333');
  final _addressController = TextEditingController(text: 'House 22, Road 4, Sector 7, Uttara, Dhaka');
  bool _isSubmitting = false;

  double get _subtotal => widget.cart.fold<double>(0, (sum, i) => sum + i.total);
  double get _deliveryFee => 60.0;
  double get _total => _subtotal + _deliveryFee;

  Future<void> _submitOrder() async {
    if (widget.cart.isEmpty) return;
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter delivery address')));
      return;
    }

    setState(() => _isSubmitting = true);
    final businessId = widget.cart.first.product.businessId;

    final res = await ApiService.placeOrder(
      businessId: businessId,
      items: widget.cart,
      shippingName: _nameController.text.trim(),
      shippingPhone: _phoneController.text.trim(),
      shippingAddress: _addressController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (res['success'] == true) {
      Navigator.pop(context);
      widget.onOrderPlaced();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.secondary,
          content: Text('অর্ডার সফল হয়েছে! অর্ডার কোড: ${res['order']['order_code']} (ক্যাশ অন ডেলিভারি)'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Order failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('আপনার শপিং ব্যাগ ও চেকআউট', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('পণ্যসমূহ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  ...widget.cart.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.product.name} (x${item.quantity})',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          '৳${item.total.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  )),

                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('সাবটোটাল', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text('৳${_subtotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ডেলিভারি চার্জ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text('৳${_deliveryFee.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('মোট প্রদেয়', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      Text('৳${_total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.secondary)),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Text('ডেলিভারি ঠিকানা ও তথ্য (ক্যাশ অন ডেলিভারি)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 10),
                  TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'প্রাপকের নাম *')),
                  const SizedBox(height: 10),
                  TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'মোবাইল নাম্বার *')),
                  const SizedBox(height: 10),
                  TextField(controller: _addressController, maxLines: 2, decoration: const InputDecoration(labelText: 'সম্পূর্ণ ডেলিভারি ঠিকানা *')),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                onPressed: _isSubmitting ? null : _submitOrder,
                child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('অর্ডার নিশ্চিত করুন (ক্যাশ অন ডেলিভারি)'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
