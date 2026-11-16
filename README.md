# প্রিয় ডিল (Priyo Deal) - All-in-One Lifestyle & Finance App for Bangladesh

**Priyo Deal** হলো একটি পূর্ণাঙ্গ লাইফস্টাইল ও ফাইন্যান্স ম্যানেজমেন্ট প্ল্যাটফর্ম। এতে রয়েছে ব্যক্তিগত ও ব্যবসায়িক হিসাব-নিকাশ (Personal & Business Finance), আয়-ব্যয় ট্র্যাকিং, দেনা-পাওনা লেজার, ডক্টর সিরিয়াল বুকিং এবং শপিং ডিল।

---

## 📁 প্রজেক্ট আর্কিটেকচার (Project Structure)

```
priyodeal/
├── priyodeal_app/     # Flutter মোবাইল অ্যাপ (Android, iOS & Web)
│   ├── lib/
│   │   ├── models/    # Data models (Finance, Transactions, Accounts, Categories)
│   │   ├── screens/   # Flutter UI screens (Auth, Finance, Booking, Home, Profile)
│   │   ├── services/  # Business logic & API communication
│   │   └── widgets/   # Reusable UI components
│   └── pubspec.yaml   # Flutter dependencies & app metadata (v1.0.7)
│
├── backend/           # PHP REST API ও ওয়েব ম্যানেজমেন্ট সিস্টেম
│   ├── app/           # api.php, db.php, helpers.php, admin.php
│   ├── views/         # Admin views ও ল্যান্ডিং পেজ
│   └── index.php      # Main routing & entrypoint
│
└── deployer/          # অটোমেটেড সার্ভার ডেপ্লয়মেন্ট স্ক্রিপ্টস (SSH/SFTP)
```

---

## 🌟 প্রধান ফিচারসমূহ (Core Features)

1. **ব্যক্তিগত হিসাব (Personal Finance):**
   - দৈনন্দিন আয়-ব্যয় এন্ট্রি ও ব্যালেন্স ট্র্যাকিং।
   - ব্যাংক, নগদ, বিকাশ ও ক্যাশ একাউন্ট সাপোর্ট।
   - নিজস্ব কাস্টম ক্যাটাগরি তৈরি ও কালার/আইকন সিলেক্টর।
   - ডোনাট চার্ট ও মাসিক আর্থিক বিবরণী।

2. **ব্যবসায়িক হিসাব (Business Finance & POS):**
   - ক্যাশ সেলস ও কাস্টমার বাকি লেনদেন (Dena-Pawna Ledger)।
   - ভাউচার তৈরি ও স্টক ট্র্যাকিং।
   - পার্সোনাল ও বিজনেস মোড সম্পূর্ণ আলাদা ও সুরক্ষিত।

3. **ডাক্তার সিরিয়াল বুকিং (Doctor Serial Booking):**
   - ডাক্তার তালিকা, বিভাগ অনুযায়ী স্পেশালিস্ট সার্চ এবং সরাসরি সিরিয়াল বুকিং।

4. **শপিং ও আকর্ষণীয় ডিল (Shopping & Deals):**
   - সুপার ডিলস, ডিসকাউন্ট অফার ও অর্ডার ম্যানেজমেন্ট।

---

## 🚀 টেকনোলজি স্ট্যাক (Tech Stack)

- **Mobile App:** Flutter / Dart (v3.24+)
- **Backend:** PHP 8.x, MySQL, RESTful API
- **Deployment:** Hostinger VPS / Cloud via SSH2 & SFTP
- **App Version:** `v1.0.7+8`

---

## 📲 অ্যাপ ডাউনলোড (Live APK)

অফিসিয়াল অ্যান্ড্রয়েড রিলিজ APK ডাউনলোড করতে ভিজিট করুন:
👉 [https://teal-aardvark-610899.hostingersite.com/downloads/priyodeal.apk?v=1.0.7](https://teal-aardvark-610899.hostingersite.com/downloads/priyodeal.apk?v=1.0.7)
