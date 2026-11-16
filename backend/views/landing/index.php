<!DOCTYPE html>
<html lang="bn" class="scroll-smooth">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Priyo Deal (প্রিয় ডিল) – ডাক্তার বুকিং, লোকাল শপিং ও পার্সোনাল হিসাব</title>
    <link rel="icon" type="image/png" href="/assets/images/app-logo.png">
    <link rel="apple-touch-icon" href="/assets/images/app-logo.png">
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Hind+Siliguri:wght@400;500;600;700&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Lucide Icons -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        body {
            font-family: 'Plus Jakarta Sans', 'Hind Siliguri', sans-serif;
        }
        .gradient-brand {
            background: linear-gradient(135deg, #0d9488 0%, #0284c7 50%, #4f46e5 100%);
        }
        .gradient-badge {
            background: linear-gradient(135deg, #f0fdf4 0%, #e0f2fe 100%);
        }
    </style>
</head>
<body class="bg-slate-50 text-slate-800 antialiased selection:bg-teal-500 selection:text-white pb-16 sm:pb-0">

    <!-- Top Notice Bar -->
    <div class="bg-slate-900 text-slate-300 text-xs py-2 px-4">
        <div class="max-w-7xl mx-auto flex flex-wrap justify-between items-center gap-2">
            <div class="flex items-center gap-2">
                <span class="inline-flex items-center px-2 py-0.5 rounded text-[10px] font-bold bg-teal-500/20 text-teal-300 border border-teal-500/30">Official Release v1.0.7</span>
                <span>Priyo Deal Version 1.0.7 is live! All-in-One Android App for Bangladesh.</span>
            </div>
            <div class="flex items-center gap-4">
                <a href="mailto:priyodealbd@gmail.com" class="hover:text-white transition flex items-center gap-1">
                    <i data-lucide="mail" class="w-3.5 h-3.5"></i> priyodealbd@gmail.com
                </a>
                <a href="/admin" class="hover:text-teal-400 font-semibold transition flex items-center gap-1">
                    <i data-lucide="shield" class="w-3.5 h-3.5"></i> Admin Portal
                </a>
            </div>
        </div>
    </div>

    <!-- Navigation -->
    <nav class="sticky top-0 z-50 bg-white/90 backdrop-blur-md border-b border-slate-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-20 flex items-center justify-between">
            <div class="flex items-center gap-3">
                <img src="/assets/images/app-logo.png" alt="Priyo Deal Logo" class="w-12 h-12 rounded-2xl shadow-md border border-slate-100 object-cover">
                <div>
                    <span class="text-2xl font-extrabold tracking-tight bg-gradient-to-r from-teal-700 via-sky-700 to-indigo-800 bg-clip-text text-transparent">Priyo Deal</span>
                    <span class="block text-[11px] font-bold text-slate-400 uppercase tracking-wider">প্রিয় ডিল • অল-ইন-ওয়ান</span>
                </div>
            </div>

            <div class="hidden md:flex items-center gap-8 font-medium text-sm text-slate-600">
                <a href="#modules" class="hover:text-teal-600 transition">মডিউলসমূহ</a>
                <a href="#finance" class="hover:text-teal-600 transition">ব্যক্তিগত ও ব্যবসা হিসাব</a>
                <a href="#doctors" class="hover:text-teal-600 transition">ডাক্তার ডিরেক্টরি</a>
                <a href="#shops" class="hover:text-teal-600 transition">শপ ও প্রোডাক্টস</a>
                <a href="#partner-modal" onclick="document.getElementById('partner-modal').classList.remove('hidden')" class="hover:text-teal-600 transition">ভেন্ডর রেজিস্ট্রেশন</a>
            </div>

            <div class="flex items-center gap-3">
                <a href="/downloads/priyodeal.apk?v=1.0.7" download="priyodeal-v1.0.7.apk" class="inline-flex items-center gap-2 bg-gradient-to-r from-teal-600 to-sky-600 text-white px-5 py-2.5 rounded-xl font-bold text-sm shadow-md shadow-teal-600/20 hover:from-teal-700 hover:to-sky-700 transition active:scale-95">
                    <i data-lucide="download" class="w-4 h-4"></i>
                    <span>APK ডাউনলোড (v1.0.7)</span>
                </a>
            </div>
        </div>
    </nav>

    <!-- Hero Section -->
    <header class="relative overflow-hidden pt-12 pb-20 lg:pt-20 lg:pb-32 bg-white">
        <div class="absolute inset-0 bg-[radial-gradient(#e2e8f0_1px,transparent_1px)] [background-size:24px_24px] opacity-40"></div>
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative">
            <div class="grid lg:grid-cols-12 gap-12 items-center">
                
                <div class="lg:col-span-7 space-y-6 text-center lg:text-left">
                    <div class="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full border border-teal-200 gradient-badge text-teal-800 text-xs font-bold">
                        <span class="flex h-2 w-2 rounded-full bg-teal-500 animate-pulse"></span>
                        ১টি অ্যাপেই ৩টি শক্তিশালী সমাধান • ১০০% ফ্রি
                    </div>

                    <h1 class="text-4xl sm:text-5xl lg:text-6xl font-extrabold tracking-tight text-slate-900 leading-tight">
                        ডাক্তার বুকিং, শপিং ও নিজের হিসাব — <br class="hidden sm:inline">
                        <span class="bg-gradient-to-r from-teal-600 via-sky-600 to-indigo-600 bg-clip-text text-transparent">সব এক অ্যাপে প্রিয় ডিল!</span>
                    </h1>

                    <p class="text-lg text-slate-600 leading-relaxed max-w-2xl">
                        লাইন ধরার দিন শেষ! ঘরে বসেই সেরা বিশেষজ্ঞ ডাক্তারদের চেম্বার সিরিয়াল দিন, আশেপাশের বিশ্বস্ত দোকান থেকে ক্যাশ অন ডেলিভারিতে অর্ডার করুন এবং অফলাইনে নিজের বা ব্যবসার আয়-ব্যয়ের হিসাব রাখুন ১০০% নিরাপদে ও সম্পূর্ণ ফ্রিতে।
                    </p>

                    <!-- CTAs -->
                    <div class="flex flex-col sm:flex-row items-center gap-4 pt-4 justify-center lg:justify-start">
                        <a href="/downloads/priyodeal.apk?v=1.0.7" download="priyodeal-v1.0.7.apk" class="w-full sm:w-auto inline-flex items-center justify-center gap-3 bg-slate-900 hover:bg-slate-800 text-white px-8 py-4 rounded-2xl font-bold shadow-xl shadow-slate-900/15 transition active:scale-95 border border-slate-700">
                            <img src="/assets/images/app-logo.png" alt="Priyo Deal" class="w-9 h-9 rounded-xl shadow-md object-cover">
                            <div class="text-left">
                                <span class="block text-[11px] font-normal text-teal-400 leading-none">Android 8.0+ (Latest Release)</span>
                                <span class="text-base font-extrabold">Download APK (v1.0.7)</span>
                            </div>
                        </a>

                        <a href="#partner-modal" onclick="document.getElementById('partner-modal').classList.remove('hidden')" class="w-full sm:w-auto inline-flex items-center justify-center gap-2 bg-teal-50 hover:bg-teal-100 text-teal-800 border border-teal-200 px-6 py-4 rounded-2xl font-bold transition">
                            <i data-lucide="briefcase" class="w-5 h-5"></i>
                            <span>ডাক্তার বা শপ যুক্ত করুন</span>
                        </a>
                    </div>

                    <!-- Trust Stats -->
                    <div class="grid grid-cols-3 gap-6 pt-8 border-t border-slate-100 max-w-lg mx-auto lg:mx-0">
                        <div>
                            <div class="text-2xl lg:text-3xl font-extrabold text-slate-900">৫০+</div>
                            <div class="text-xs text-slate-500 font-medium">বিশেষজ্ঞ ডাক্তার</div>
                        </div>
                        <div>
                            <div class="text-2xl lg:text-3xl font-extrabold text-slate-900">১০০+</div>
                            <div class="text-xs text-slate-500 font-medium">ভেরিফায়েড দোকান</div>
                        </div>
                        <div>
                            <div class="text-2xl lg:text-3xl font-extrabold text-teal-600">১০০%</div>
                            <div class="text-xs text-slate-500 font-medium">প্রাইভেট ফ্রি হিসাব খাতা</div>
                        </div>
                    </div>
                </div>

                <!-- Phone Visual Mockup -->
                <div class="lg:col-span-5 flex justify-center">
                    <div class="relative w-72 sm:w-80 rounded-[44px] p-3 bg-slate-900 shadow-2xl shadow-indigo-900/20 border-4 border-slate-800">
                        <div class="bg-white rounded-[36px] overflow-hidden border border-slate-200">
                            <!-- App Top Header -->
                            <div class="bg-gradient-to-r from-teal-600 to-sky-600 p-4 text-white">
                                <div class="flex items-center justify-between text-xs pb-3">
                                    <span class="font-bold flex items-center gap-1.5">
                                        <img src="/assets/images/app-logo.png" class="w-5 h-5 rounded-md object-cover">
                                        ঢাকা, বাংলাদেশ
                                    </span>
                                    <span class="bg-white/20 px-2 py-0.5 rounded-full text-[10px] font-bold">v1.0.7 Active</span>
                                </div>
                                <h3 class="text-lg font-bold">স্বাগতম, প্রিয় ডিলে!</h3>
                                <p class="text-xs text-teal-100">আজ আপনি কোন সেবাটি নিতে চান?</p>
                            </div>

                            <!-- App Content Sample -->
                            <div class="p-3 space-y-3 bg-slate-50 text-xs">
                                <!-- 3 modules pill -->
                                <div class="grid grid-cols-3 gap-2">
                                    <div class="bg-white p-2 rounded-xl text-center border border-slate-200 shadow-sm">
                                        <div class="w-8 h-8 mx-auto bg-teal-100 text-teal-700 rounded-lg flex items-center justify-center mb-1">
                                            <i data-lucide="stethoscope" class="w-4 h-4"></i>
                                        </div>
                                        <span class="font-bold block text-[10px]">ডাক্তার</span>
                                    </div>
                                    <div class="bg-white p-2 rounded-xl text-center border border-slate-200 shadow-sm">
                                        <div class="w-8 h-8 mx-auto bg-sky-100 text-sky-700 rounded-lg flex items-center justify-center mb-1">
                                            <i data-lucide="shopping-bag" class="w-4 h-4"></i>
                                        </div>
                                        <span class="font-bold block text-[10px]">শপিং</span>
                                    </div>
                                    <div class="bg-white p-2 rounded-xl text-center border border-slate-200 shadow-sm">
                                        <div class="w-8 h-8 mx-auto bg-indigo-100 text-indigo-700 rounded-lg flex items-center justify-center mb-1">
                                            <i data-lucide="wallet" class="w-4 h-4"></i>
                                        </div>
                                        <span class="font-bold block text-[10px]">হিসাব</span>
                                    </div>
                                </div>

                                <!-- Doctor Card -->
                                <div class="bg-white p-2.5 rounded-xl border border-slate-200 shadow-sm flex items-center gap-2.5">
                                    <img src="https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=150" class="w-12 h-12 rounded-lg object-cover">
                                    <div class="flex-1">
                                        <div class="font-bold text-slate-800 text-[11px]">Prof. Dr. Rafiqul Hasan</div>
                                        <div class="text-[10px] text-teal-700 font-semibold">Medicine Specialist</div>
                                        <div class="text-[9px] text-slate-400">Square Hospital • ৳১০০০</div>
                                    </div>
                                    <span class="bg-teal-600 text-white text-[9px] px-2 py-1 rounded-md font-bold">সিরিয়াল</span>
                                </div>

                                <!-- Product Card -->
                                <div class="bg-white p-2.5 rounded-xl border border-slate-200 shadow-sm flex items-center gap-2.5">
                                    <img src="https://images.unsplash.com/photo-1542838132-92c53300491e?w=150" class="w-12 h-12 rounded-lg object-cover">
                                    <div class="flex-1">
                                        <div class="font-bold text-slate-800 text-[11px]">Dhaka Fresh Mart</div>
                                        <div class="text-[10px] text-emerald-600 font-semibold">১ ঘণ্টায় ফ্রি ডেলিভারি</div>
                                        <div class="text-[9px] text-slate-400">ক্যাশ অন ডেলিভারি (COD)</div>
                                    </div>
                                    <span class="bg-sky-600 text-white text-[9px] px-2 py-1 rounded-md font-bold">অর্ডার</span>
                                </div>

                                <!-- Finance Widget -->
                                <div class="bg-gradient-to-r from-slate-900 to-indigo-900 p-2.5 rounded-xl text-white">
                                    <div class="flex justify-between items-center text-[10px] text-slate-300">
                                        <span>ক্যাশ ও ব্যাংক ব্যালেন্স</span>
                                        <span class="text-teal-400 font-bold">১০০% অফলাইন</span>
                                    </div>
                                    <div class="text-sm font-extrabold text-white mt-1">৳ ৩৪,৫২০.০০</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </header>

    <!-- 3 Core Modules Showcase -->
    <section id="modules" class="py-20 bg-slate-100/60 border-y border-slate-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center max-w-3xl mx-auto mb-16">
                <span class="text-xs font-bold uppercase tracking-wider text-teal-700 bg-teal-100 px-3 py-1 rounded-full">স্মার্ট লাইফস্টাইল ইকোসিস্টেম</span>
                <h2 class="text-3xl sm:text-4xl font-extrabold text-slate-900 mt-3">এক অ্যাপে যা যা পাচ্ছেন</h2>
                <p class="text-slate-600 mt-3">প্রতিদিনের জরুরি চিকিৎসা, দরকারি শপিং এবং ব্যক্তিগত ও ব্যবসায়ের টাকার হিসাব — সবই এক ছাদের নিচে।</p>
            </div>

            <div class="grid md:grid-cols-3 gap-8">
                <!-- Module 1: Doctor Booking -->
                <div class="bg-white p-8 rounded-3xl border border-slate-200 shadow-sm hover:shadow-xl transition-all duration-300 group">
                    <div class="w-14 h-14 rounded-2xl bg-teal-100 text-teal-700 flex items-center justify-center mb-6 group-hover:scale-110 transition">
                        <i data-lucide="stethoscope" class="w-7 h-7"></i>
                    </div>
                    <span class="text-xs font-bold text-teal-600 uppercase tracking-wider">মডিউল ১</span>
                    <h3 class="text-xl font-bold text-slate-900 mt-1 mb-3">ডাক্তার অ্যাপয়েন্টমেন্ট বুকিং</h3>
                    <p class="text-slate-600 text-sm leading-relaxed mb-4">
                        বিএমডিসি ভেরিফায়েড বিশেষজ্ঞ ডাক্তার খুঁজুন। চেম্বার, ভিজিটিং দিন ও রিয়েল-টাইম টাইম-স্লট বেছে নিয়ে তাৎক্ষণিক সিরিয়াল নিন। হাসপাতালে গিয়ে ভিজিটের ফি পরিশোধ করুন।
                    </p>
                    <ul class="space-y-2 text-xs text-slate-600 font-medium border-t border-slate-100 pt-4">
                        <li class="flex items-center gap-2"><i data-lucide="check-circle-2" class="w-4 h-4 text-teal-600"></i> কোনো ডাবল বুকিং নেই (সার্ভার লক)</li>
                        <li class="flex items-center gap-2"><i data-lucide="check-circle-2" class="w-4 h-4 text-teal-600"></i> ডিজিটাল সিরিয়াল নাম্বার ও কনফার্মেশন</li>
                        <li class="flex items-center gap-2"><i data-lucide="check-circle-2" class="w-4 h-4 text-teal-600"></i> পরিবার ও আত্মীয়দের জন্য বুকিং সুবিধা</li>
                    </ul>
                </div>

                <!-- Module 2: Shopping & COD -->
                <div class="bg-white p-8 rounded-3xl border border-slate-200 shadow-sm hover:shadow-xl transition-all duration-300 group">
                    <div class="w-14 h-14 rounded-2xl bg-sky-100 text-sky-700 flex items-center justify-center mb-6 group-hover:scale-110 transition">
                        <i data-lucide="shopping-cart" class="w-7 h-7"></i>
                    </div>
                    <span class="text-xs font-bold text-sky-600 uppercase tracking-wider">মডিউল ২</span>
                    <h3 class="text-xl font-bold text-slate-900 mt-1 mb-3">লোকাল শপ ও গ্রোসারি শপিং</h3>
                    <p class="text-slate-600 text-sm leading-relaxed mb-4">
                        আপনার এলাকার বিশ্বস্ত দোকান থেকে গ্রোসারি, ওষুধ, ফ্যাশন ও গ্যাজেটস কিনুন। সম্পূর্ণ ক্যাশ অন ডেলিভারি (COD) পেমেন্টে পণ্য হাতে পেয়ে মূল্য পরিশোধের সুবিধা।
                    </p>
                    <ul class="space-y-2 text-xs text-slate-600 font-medium border-t border-slate-100 pt-4">
                        <li class="flex items-center gap-2"><i data-lucide="check-circle-2" class="w-4 h-4 text-sky-600"></i> দোকান ও পণ্য ভিত্তিক স্বচ্ছ ক্যাটাগরি</li>
                        <li class="flex items-center gap-2"><i data-lucide="check-circle-2" class="w-4 h-4 text-sky-600"></i> ক্যাশ অন ডেলিভারি (পণ্য পেয়ে টাকা দিন)</li>
                        <li class="flex items-center gap-2"><i data-lucide="check-circle-2" class="w-4 h-4 text-sky-600"></i> রিয়েল-টাইম অর্ডার ট্র্যাকিং ও ইনভয়েস</li>
                    </ul>
                </div>

                <!-- Module 3: Personal & Business Finance -->
                <div class="bg-white p-8 rounded-3xl border-2 border-emerald-500/30 shadow-lg hover:shadow-2xl transition-all duration-300 group relative overflow-hidden">
                    <div class="absolute top-4 right-4 bg-emerald-500 text-white text-[10px] font-extrabold uppercase px-2.5 py-1 rounded-full shadow-md">
                        ১০০% ফ্রি
                    </div>
                    <div class="w-14 h-14 rounded-2xl bg-emerald-100 text-emerald-700 flex items-center justify-center mb-6 group-hover:scale-110 transition">
                        <i data-lucide="calculator" class="w-7 h-7"></i>
                    </div>
                    <span class="text-xs font-bold text-emerald-600 uppercase tracking-wider">মডিউল ৩ • সম্পূর্ণ ফ্রি</span>
                    <h3 class="text-xl font-bold text-slate-900 mt-1 mb-3">ব্যক্তিগত ও ব্যবসায়িক হিসাব</h3>
                    <p class="text-slate-600 text-sm leading-relaxed mb-4">
                        কোনো পেমেন্ট বা সাবস্ক্রিপশন ছাড়াই আজীবন ব্যবহার করুন! নিজের আয়-ব্যয়, ক্যাশ বুক, দেনা-পাওনা, ব্যবসা প্রতিষ্ঠানের বিক্রয় ভাউচার (POS), স্টক ইনভেন্টরি ও কাস্টমার লেজার সম্পূর্ণ ফ্রিতে পরিচালনা করুন।
                    </p>
                    <ul class="space-y-2 text-xs text-slate-600 font-medium border-t border-slate-100 pt-4">
                        <li class="flex items-center gap-2"><i data-lucide="check-circle-2" class="w-4 h-4 text-emerald-600"></i> ব্যক্তিগত ও ব্যবসায়িক ডুয়াল মোড সুইচ</li>
                        <li class="flex items-center gap-2"><i data-lucide="check-circle-2" class="w-4 h-4 text-emerald-600"></i> ক্যাশ, ব্যাংক ও এমএফএস ব্যালেন্স ট্র্যাকিং</li>
                        <li class="flex items-center gap-2"><i data-lucide="check-circle-2" class="w-4 h-4 text-emerald-600"></i> বিক্রয় ভাউচার (POS), ডিসকাউন্ট ও কাস্টমার লেজার</li>
                        <li class="flex items-center gap-2"><i data-lucide="check-circle-2" class="w-4 h-4 text-emerald-600"></i> এক ক্লিকে অফিশিয়াল পিডিএফ ও শেয়ার</li>
                    </ul>
                </div>
            </div>
        </div>
    </section>

    <!-- Dedicated Finance & Business Accounting Section (100% FREE) -->
    <section id="finance" class="py-24 bg-slate-900 text-white relative overflow-hidden">
        <div class="absolute inset-0 bg-[radial-gradient(#334155_1px,transparent_1px)] [background-size:24px_24px] opacity-20"></div>
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
            
            <div class="text-center max-w-3xl mx-auto mb-16">
                <span class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-emerald-500/20 text-emerald-300 font-extrabold text-xs mb-3 border border-emerald-500/30">
                    <span class="w-2 h-2 rounded-full bg-emerald-400 animate-ping"></span>
                    সম্পূর্ণ ফ্রি ফিচারসমূহ • আজীবন ০৳
                </span>
                <h2 class="text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight">
                    ব্যক্তিগত আয়-ব্যয় ও ব্যবসা প্রতিষ্ঠানের <br>
                    <span class="bg-gradient-to-r from-emerald-400 via-teal-300 to-sky-400 bg-clip-text text-transparent">ডিজিটাল ক্যাশ বই ও স্টক খাতা</span>
                </h2>
                <p class="text-slate-400 text-base mt-4 leading-relaxed">
                    কোনো ধরনের পেমেন্ট বা সাবস্ক্রিপশন চার্জ ছাড়াই ব্যবহার করুন। ব্যক্তিগত দৈনন্দিন খরচের ট্র্যাক রাখা থেকে শুরু করে ব্যবসা প্রতিষ্ঠানের বিক্রয় ভাউচার (POS), দেনা-পাওনা ও কাস্টমার লেজার — সবই থাকবে আপনার হাতের মুঠোয়।
                </p>
            </div>

            <!-- Free Modules 6-Grid Feature Showcase -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                <!-- 1. Cash Book -->
                <div class="bg-slate-800/80 border border-slate-700/80 rounded-3xl p-7 hover:border-emerald-500/50 transition duration-300">
                    <div class="w-12 h-12 rounded-2xl bg-emerald-500/10 text-emerald-400 flex items-center justify-center mb-5 border border-emerald-500/20">
                        <i data-lucide="book-open" class="w-6 h-6"></i>
                    </div>
                    <h3 class="text-xl font-bold text-white mb-2">ক্যাশ বই (দৈনিক আয়-ব্যয়)</h3>
                    <p class="text-slate-400 text-xs leading-relaxed mb-4">
                        প্রতিদিনের নগদ লেনদেন নিমিষেই যোগ করুন। ক্যাটাগরি, তারিখ ও বিবরণ সহ মোট আয়, ব্যয় এবং নিখুঁত বর্তমান ব্যালেন্স স্বয়ংক্রিয়ভাবে হিসাব থাকবে।
                    </p>
                    <span class="inline-block text-[11px] font-bold text-emerald-400">ব্যালেন্স নেগেটিভ রোধ সিকিউরিটি সহ</span>
                </div>

                <!-- 2. Bank & MFS Accounts -->
                <div class="bg-slate-800/80 border border-slate-700/80 rounded-3xl p-7 hover:border-emerald-500/50 transition duration-300">
                    <div class="w-12 h-12 rounded-2xl bg-teal-500/10 text-teal-400 flex items-center justify-center mb-5 border border-teal-500/20">
                        <i data-lucide="credit-card" class="w-6 h-6"></i>
                    </div>
                    <h3 class="text-xl font-bold text-white mb-2">ব্যাংক ও মোবাইল ব্যাংকিং (MFS)</h3>
                    <p class="text-slate-400 text-xs leading-relaxed mb-4">
                        একাধিক ব্যাংক ও বিকাশ, নগদ, রকেট অ্যাকাউন্ট ম্যানেজ করুন। এক অ্যাকাউন্ট থেকে অন্য অ্যাকাউন্টে ফান্ড ট্রান্সফার ও ব্যালেন্স ট্র্যাকিং।
                    </p>
                    <span class="inline-block text-[11px] font-bold text-teal-400">ডাইনামিক অ্যাকাউন্ট সিলেক্টর</span>
                </div>

                <!-- 3. POS Billing -->
                <div class="bg-slate-800/80 border border-slate-700/80 rounded-3xl p-7 hover:border-emerald-500/50 transition duration-300">
                    <div class="w-12 h-12 rounded-2xl bg-sky-500/10 text-sky-400 flex items-center justify-center mb-5 border border-sky-500/20">
                        <i data-lucide="receipt" class="w-6 h-6"></i>
                    </div>
                    <h3 class="text-xl font-bold text-white mb-2">বিক্রয় ভাউচার (POS Billing)</h3>
                    <p class="text-slate-400 text-xs leading-relaxed mb-4">
                        দ্রুত পণ্য সিলেক্ট করে ডিজিটাল ইনভয়েস তৈরি করুন। ডিসকাউন্ট (ফিক্সড/শতাংশ), ভ্যাট, ডেলিভারি চার্জ ও আংশিক বাকি স্বয়ংক্রিয়ভাবে যুক্ত হবে।
                    </p>
                    <span class="inline-block text-[11px] font-bold text-sky-400">প্রোডাক্ট গ্রিড ও কাস্টমার বুকিং</span>
                </div>

                <!-- 4. Customer Due Ledger -->
                <div class="bg-slate-800/80 border border-slate-700/80 rounded-3xl p-7 hover:border-emerald-500/50 transition duration-300">
                    <div class="w-12 h-12 rounded-2xl bg-indigo-500/10 text-indigo-400 flex items-center justify-center mb-5 border border-indigo-500/20">
                        <i data-lucide="users" class="w-6 h-6"></i>
                    </div>
                    <h3 class="text-xl font-bold text-white mb-2">দেনা-পাওনা ও কাস্টমার লেজার</h3>
                    <p class="text-slate-400 text-xs leading-relaxed mb-4">
                        কাদের কাছে কত বাকি আছে তার সিঙ্গেল কাস্টমার লেজার ভিউ। মোট ক্রয়, পরিশোধিত ও বাকি ট্র্যাকিং এবং সহজে বাকি আদায়ের সুবিধা।
                    </p>
                    <span class="inline-block text-[11px] font-bold text-indigo-400">সিঙ্গেল কাস্টমার খতিয়ান ভিউ</span>
                </div>

                <!-- 5. Stock Inventory -->
                <div class="bg-slate-800/80 border border-slate-700/80 rounded-3xl p-7 hover:border-emerald-500/50 transition duration-300">
                    <div class="w-12 h-12 rounded-2xl bg-amber-500/10 text-amber-400 flex items-center justify-center mb-5 border border-amber-500/20">
                        <i data-lucide="boxes" class="w-6 h-6"></i>
                    </div>
                    <h3 class="text-xl font-bold text-white mb-2">স্টক ও ইনভেন্টরি ম্যানেজমেন্ট</h3>
                    <p class="text-slate-400 text-xs leading-relaxed mb-4">
                        দোকানের মোট পণ্যের পরিমাণ, ক্রয় ও বিক্রয় মূল্য এবং রিয়েল-টাইম স্টক আপডেট। কোনো পণ্য বিক্রি হলে স্বয়ংক্রিয়ভাবে স্টক মাইনাস হয়।
                    </p>
                    <span class="inline-block text-[11px] font-bold text-amber-400">লো-স্টক এলার্ট সহ</span>
                </div>

                <!-- 6. PDF Statement & Share -->
                <div class="bg-slate-800/80 border border-slate-700/80 rounded-3xl p-7 hover:border-emerald-500/50 transition duration-300">
                    <div class="w-12 h-12 rounded-2xl bg-rose-500/10 text-rose-400 flex items-center justify-center mb-5 border border-rose-500/20">
                        <i data-lucide="file-text" class="w-6 h-6"></i>
                    </div>
                    <h3 class="text-xl font-bold text-white mb-2">অফিশিয়াল PDF স্টেটমেন্ট</h3>
                    <p class="text-slate-400 text-xs leading-relaxed mb-4">
                        ক্যাশ বুক স্টেটমেন্ট, কাস্টমার লেজার বা দেনা-পাওনা রিপোর্ট এক ক্লিকেই প্রিভিউ করুন এবং এ৪ ফরম্যাটে ডাউনলোড বা সরাসরি শেয়ার করুন।
                    </p>
                    <span class="inline-block text-[11px] font-bold text-rose-400">১ ক্লিকে ডাউনলোড ও প্রিন্ট</span>
                </div>
            </div>

            <!-- Free Pricing Callout -->
            <div class="mt-16 bg-gradient-to-r from-emerald-950 via-teal-950 to-slate-950 p-8 sm:p-10 rounded-3xl border border-emerald-500/30 flex flex-col md:flex-row items-center justify-between gap-8">
                <div class="space-y-2 text-center md:text-left">
                    <div class="flex items-center justify-center md:justify-start gap-2">
                        <span class="px-2.5 py-0.5 rounded-full text-xs font-bold bg-emerald-500 text-slate-950">৳০ ফ্রি প্ল্যান</span>
                        <span class="text-emerald-400 text-xs font-bold">সকল মডিউল সম্পূর্ণ উন্মুক্ত</span>
                    </div>
                    <h3 class="text-2xl sm:text-3xl font-extrabold text-white">কোনো সাবস্ক্রিপশন ফি বা পেমেন্ট ছাড়াই ব্যবহার করুন</h3>
                    <p class="text-xs text-slate-300 max-w-xl">
                        আমাদের লক্ষ্য প্রতিটি সাধারণ মানুষ ও ক্ষুদ্র ব্যবসায়ীর হিসাব সহজ করা। কোনো ক্রেডিট কার্ড বা বিকাশ পেমেন্ট গেটওয়ে প্রয়োজন নেই।
                    </p>
                </div>

                <a href="/downloads/priyodeal.apk?v=1.0.7" download="priyodeal-v1.0.7.apk" class="inline-flex items-center gap-3 bg-gradient-to-r from-emerald-500 to-teal-500 hover:from-emerald-400 hover:to-teal-400 text-slate-950 px-8 py-4 rounded-2xl font-extrabold shadow-xl shadow-emerald-500/20 transition active:scale-95 whitespace-nowrap text-sm">
                    <i data-lucide="download" class="w-5 h-5"></i>
                    <span>ফ্রি অ্যাপ ইনস্টল করুন (v1.0.7)</span>
                </a>
            </div>

        </div>
    </section>

    <!-- Featured Doctors Directory -->
    <section id="doctors" class="py-20 bg-white">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex flex-col sm:flex-row justify-between items-start sm:items-end mb-12 gap-4">
                <div>
                    <span class="text-xs font-bold uppercase tracking-wider text-teal-700 bg-teal-100 px-3 py-1 rounded-full">স্বাস্থ্য সেবা</span>
                    <h2 class="text-3xl font-extrabold text-slate-900 mt-2">সেরা বিশেষজ্ঞ ডাক্তারবৃন্দ</h2>
                    <p class="text-slate-500 text-sm mt-1">বিএমডিসি ভেরিফায়েড প্রখ্যাত পরামর্শকগণ</p>
                </div>
                <a href="/downloads/priyodeal.apk?v=1.0.7" download="priyodeal-v1.0.7.apk" class="text-teal-700 font-bold text-sm inline-flex items-center gap-1 hover:gap-2 transition">
                    <span>অ্যাপে সব ৫০+ ডাক্তার দেখুন</span>
                    <i data-lucide="arrow-right" class="w-4 h-4"></i>
                </a>
            </div>

            <div class="grid sm:grid-cols-2 lg:grid-cols-4 gap-6">
                <!-- Doc 1 -->
                <div class="bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-sm hover:shadow-lg transition">
                    <img src="https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400" class="w-full h-48 object-cover">
                    <div class="p-5">
                        <span class="text-[10px] font-bold text-teal-700 uppercase bg-teal-50 px-2 py-0.5 rounded">Medicine</span>
                        <h4 class="font-bold text-slate-900 mt-2 text-base">Prof. Dr. Rafiqul Hasan</h4>
                        <p class="text-xs text-slate-500">MBBS (DMC), FCPS (Medicine)</p>
                        <div class="mt-4 pt-3 border-t border-slate-100 flex items-center justify-between text-xs">
                            <span class="font-bold text-slate-900">ভিজিট: ৳১,০০০</span>
                            <span class="text-amber-500 font-bold flex items-center gap-1">★ 4.9</span>
                        </div>
                    </div>
                </div>

                <!-- Doc 2 -->
                <div class="bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-sm hover:shadow-lg transition">
                    <img src="https://images.unsplash.com/photo-1594824813627-2c5e533b827e?w=400" class="w-full h-48 object-cover">
                    <div class="p-5">
                        <span class="text-[10px] font-bold text-sky-700 uppercase bg-sky-50 px-2 py-0.5 rounded">Cardiology</span>
                        <h4 class="font-bold text-slate-900 mt-2 text-base">Dr. Farhana Chowdhury</h4>
                        <p class="text-xs text-slate-500">MBBS, MD (Cardiology), NICVD</p>
                        <div class="mt-4 pt-3 border-t border-slate-100 flex items-center justify-between text-xs">
                            <span class="font-bold text-slate-900">ভিজিট: ৳১,২০০</span>
                            <span class="text-amber-500 font-bold flex items-center gap-1">★ 4.8</span>
                        </div>
                    </div>
                </div>

                <!-- Doc 3 -->
                <div class="bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-sm hover:shadow-lg transition">
                    <img src="https://images.unsplash.com/photo-153736891.0.6-700350fe46c7?w=400" class="w-full h-48 object-cover">
                    <div class="p-5">
                        <span class="text-[10px] font-bold text-indigo-700 uppercase bg-indigo-50 px-2 py-0.5 rounded">Pediatrics</span>
                        <h4 class="font-bold text-slate-900 mt-2 text-base">Dr. Mahbubur Rahman</h4>
                        <p class="text-xs text-slate-500">MBBS, DCH, FCPS (Pediatrics)</p>
                        <div class="mt-4 pt-3 border-t border-slate-100 flex items-center justify-between text-xs">
                            <span class="font-bold text-slate-900">ভিজিট: ৳৮০০</span>
                            <span class="text-amber-500 font-bold flex items-center gap-1">★ 4.9</span>
                        </div>
                    </div>
                </div>

                <!-- Doc 4 -->
                <div class="bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-sm hover:shadow-lg transition">
                    <img src="https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400" class="w-full h-48 object-cover">
                    <div class="p-5">
                        <span class="text-[10px] font-bold text-purple-700 uppercase bg-purple-50 px-2 py-0.5 rounded">Dermatology</span>
                        <h4 class="font-bold text-slate-900 mt-2 text-base">Dr. Sadia Sultana</h4>
                        <p class="text-xs text-slate-500">MBBS, DDV, FCPS (Dermatology)</p>
                        <div class="mt-4 pt-3 border-t border-slate-100 flex items-center justify-between text-xs">
                            <span class="font-bold text-slate-900">ভিজিট: ৳৯০০</span>
                            <span class="text-amber-500 font-bold flex items-center gap-1">★ 4.7</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Popular Shops & Products -->
    <section id="shops" class="py-20 bg-slate-50 border-t border-slate-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex flex-col sm:flex-row justify-between items-start sm:items-end mb-12 gap-4">
                <div>
                    <span class="text-xs font-bold uppercase tracking-wider text-sky-700 bg-sky-100 px-3 py-1 rounded-full">অনলাইন শপিং</span>
                    <h2 class="text-3xl font-extrabold text-slate-900 mt-2">জনপ্রিয় শপ ও সেরা অফার</h2>
                    <p class="text-slate-500 text-sm mt-1">১০০% আসল পণ্য ও ক্যাশ অন ডেলিভারি</p>
                </div>
                <a href="/downloads/priyodeal.apk?v=1.0.7" download="priyodeal-v1.0.7.apk" class="text-sky-700 font-bold text-sm inline-flex items-center gap-1 hover:gap-2 transition">
                    <span>অ্যাপে সব পণ্য দেখুন</span>
                    <i data-lucide="arrow-right" class="w-4 h-4"></i>
                </a>
            </div>

            <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-8">
                <!-- Shop 1 -->
                <div class="bg-white rounded-3xl p-6 border border-slate-200 shadow-sm hover:shadow-lg transition">
                    <div class="flex items-center gap-4 mb-4">
                        <img src="https://images.unsplash.com/photo-1542838132-92c53300491e?w=200" class="w-16 h-16 rounded-2xl object-cover">
                        <div>
                            <h4 class="font-bold text-slate-900 text-lg">Dhaka Fresh Mart</h4>
                            <span class="text-xs text-slate-500">বনানী, ঢাকা • ডেলিভারি চার্জ ৳৬০</span>
                        </div>
                    </div>
                    <div class="bg-slate-50 p-3 rounded-2xl space-y-2 mb-4 text-xs">
                        <div class="flex justify-between items-center">
                            <span>প্রাণ খাঁটি সরিষার তেল (১ লিটার)</span>
                            <span class="font-bold text-slate-900">৳ ২৯০</span>
                        </div>
                        <div class="flex justify-between items-center">
                            <span>চাষী চিনিগুঁড়া সুগন্ধি চাল (১ কেজি)</span>
                            <span class="font-bold text-slate-900">৳ ১২৫</span>
                        </div>
                        <div class="flex justify-between items-center">
                            <span>ফার্ম ফ্রেশ লাল ডিম (১ ডজন)</span>
                            <span class="font-bold text-slate-900">৳ ১৪৫</span>
                        </div>
                    </div>
                    <a href="/downloads/priyodeal.apk?v=1.0.7" download="priyodeal-v1.0.7.apk" class="block text-center w-full py-2.5 rounded-xl bg-teal-50 hover:bg-teal-100 text-teal-800 font-bold text-xs transition">
                        অর্ডার করতে অ্যাপ নামান
                    </a>
                </div>

                <!-- Shop 2 -->
                <div class="bg-white rounded-3xl p-6 border border-slate-200 shadow-sm hover:shadow-lg transition">
                    <div class="flex items-center gap-4 mb-4">
                        <img src="https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200" class="w-16 h-16 rounded-2xl object-cover">
                        <div>
                            <h4 class="font-bold text-slate-900 text-lg">Green Care Pharmacy</h4>
                            <span class="text-xs text-slate-500">ধানমন্ডি ২৭, ঢাকা • ২৪ ঘণ্টা খোলা</span>
                        </div>
                    </div>
                    <div class="bg-slate-50 p-3 rounded-2xl space-y-2 mb-4 text-xs">
                        <div class="flex justify-between items-center">
                            <span>নাপা এক্সট্রা ট্যাবলেট (১০০ টি)</span>
                            <span class="font-bold text-slate-900">৳ ২৪০</span>
                        </div>
                        <div class="flex justify-between items-center">
                            <span>স্যাভলন অ্যান্টিসেপটিক লিকুইড</span>
                            <span class="font-bold text-slate-900">৳ ৩৬০</span>
                        </div>
                        <div class="flex justify-between items-center">
                            <span>অ্যাকিউ-চেক সুগার মাপার মেশিন</span>
                            <span class="font-bold text-slate-900">৳ ১,৯৫০</span>
                        </div>
                    </div>
                    <a href="/downloads/priyodeal.apk?v=1.0.7" download="priyodeal-v1.0.7.apk" class="block text-center w-full py-2.5 rounded-xl bg-sky-50 hover:bg-sky-100 text-sky-800 font-bold text-xs transition">
                        ওষুধ অর্ডার করুন
                    </a>
                </div>

                <!-- Shop 3 -->
                <div class="bg-white rounded-3xl p-6 border border-slate-200 shadow-sm hover:shadow-lg transition">
                    <div class="flex items-center gap-4 mb-4">
                        <img src="https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=200" class="w-16 h-16 rounded-2xl object-cover">
                        <div>
                            <h4 class="font-bold text-slate-900 text-lg">Bengal Tech Hub</h4>
                            <span class="text-xs text-slate-500">মাল্টিপ্ল্যান সেন্টার • অফিসিয়াল ওয়ারেন্টি</span>
                        </div>
                    </div>
                    <div class="bg-slate-50 p-3 rounded-2xl space-y-2 mb-4 text-xs">
                        <div class="flex justify-between items-center">
                            <span>Oraimo 20000mAh পাওয়ার ব্যাংক</span>
                            <span class="font-bold text-slate-900">৳ ১,৬৫০</span>
                        </div>
                        <div class="flex justify-between items-center">
                            <span>হায়লো সোলার প্রো স্মার্ট ওয়াচ</span>
                            <span class="font-bold text-slate-900">৳ ২,৯৯৯</span>
                        </div>
                        <div class="flex justify-between items-center">
                            <span>রিয়েলমি বাডস টি১১০ ওয়্যারলেস</span>
                            <span class="font-bold text-slate-900">৳ ১,৮৫০</span>
                        </div>
                    </div>
                    <a href="/downloads/priyodeal.apk?v=1.0.7" download="priyodeal-v1.0.7.apk" class="block text-center w-full py-2.5 rounded-xl bg-indigo-50 hover:bg-indigo-100 text-indigo-800 font-bold text-xs transition">
                        গ্যাজেট কিনুন
                    </a>
                </div>
            </div>
        </div>
    </section>

    <!-- Partner Registration Modal -->
    <div id="partner-modal" class="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-sm hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-3xl max-w-lg w-full p-8 relative shadow-2xl border border-slate-200 max-h-[90vh] overflow-y-auto">
            <button onclick="document.getElementById('partner-modal').classList.add('hidden')" class="absolute top-6 right-6 text-slate-400 hover:text-slate-600">
                <i data-lucide="x" class="w-6 h-6"></i>
            </button>

            <div class="mb-6">
                <span class="text-xs font-bold text-teal-600 uppercase tracking-wider">পার্টনারশিপ</span>
                <h3 class="text-2xl font-extrabold text-slate-900 mt-1">ডাক্তার বা দোকান হিসেবে যুক্ত হোন</h3>
                <p class="text-slate-500 text-xs mt-1">আপনার তথ্য জমা দিন, আমাদের টিম অতি দ্রুত আপনার সাথে যোগাযোগ করবে।</p>
            </div>

            <form id="vendor-apply-form" class="space-y-4">
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">আবেদনের ধরন</label>
                    <select name="type" required class="w-full px-4 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:border-teal-500 bg-slate-50">
                        <option value="doctor">বিশেষজ্ঞ ডাক্তার (Doctor)</option>
                        <option value="shop">দোকান / মার্চেন্ট (Shop)</option>
                    </select>
                </div>

                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">নাম (Name / Organization)</label>
                    <input type="text" name="name" required placeholder="ডা. রফিকুল হাসান / ঢাকা ফ্রেশ মার্ট" class="w-full px-4 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:border-teal-500">
                </div>

                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">মোবাইল নম্বর (Phone)</label>
                    <input type="tel" name="phone" required placeholder="01700000000" class="w-full px-4 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:border-teal-500">
                </div>

                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">ঠিকানা / চেম্বার লোকেশন</label>
                    <input type="text" name="address" required placeholder="বাড়ি #১২, রোড #৪, ধানমন্ডি, ঢাকা" class="w-full px-4 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:border-teal-500">
                </div>

                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">বিবরণ / স্পেশালাইজেশন</label>
                    <textarea name="description" rows="2" placeholder="এমবিবিএস, এফসিপিএস অথবা গ্রোসারি পণ্যের দোকান" class="w-full px-4 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:border-teal-500"></textarea>
                </div>

                <div id="vendor-msg" class="hidden text-xs p-3 rounded-xl"></div>

                <button type="submit" class="w-full py-3.5 bg-gradient-to-r from-teal-600 to-sky-600 hover:from-teal-700 hover:to-sky-700 text-white font-bold rounded-xl shadow-lg shadow-teal-600/20 transition">
                    আবেদন জমা দিন
                </button>
            </form>
        </div>
    </div>

    <!-- Download App Banner Section -->
    <section class="py-20 bg-slate-900 text-white relative overflow-hidden">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
            <div class="bg-gradient-to-r from-teal-900/40 via-sky-900/40 to-indigo-900/40 border border-slate-700/60 p-8 sm:p-12 rounded-[32px] flex flex-col md:flex-row items-center justify-between gap-8 backdrop-blur-md">
                <div class="flex items-center gap-6 max-w-xl text-center md:text-left flex-col md:flex-row">
                    <img src="/assets/images/app-logo.png" alt="Priyo Deal" class="w-20 h-20 rounded-3xl shadow-2xl border-2 border-teal-500/40 object-cover shrink-0">
                    <div>
                        <span class="inline-block px-3 py-1 rounded-full bg-teal-500/20 text-teal-300 font-bold text-xs mb-3">সবার জন্য ১০০% উন্মুক্ত</span>
                        <h2 class="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">দেরি না করে আজই নামিয়ে নিন প্রিয় ডিল অ্যাপ!</h2>
                        <p class="text-slate-300 text-sm mt-2 leading-relaxed">
                            আপনার অ্যান্ড্রয়েড ফোনে সরাসরি ইন্সটল করুন এবং উপভোগ করুন ডাক্তার বুকিং, অনলাইন শপিং ও প্রাইভেট ফিন্যান্স ম্যানেজারের অনন্য অভিজ্ঞতা।
                        </p>
                    </div>
                </div>
                <div class="flex flex-col sm:flex-row items-center gap-4">
                    <a href="/downloads/priyodeal.apk?v=1.0.7" download="priyodeal-v1.0.7.apk" class="inline-flex items-center gap-3 bg-teal-500 hover:bg-teal-400 text-slate-950 px-8 py-4 rounded-2xl font-bold shadow-xl shadow-teal-500/20 transition active:scale-95 text-base whitespace-nowrap">
                        <i data-lucide="download" class="w-6 h-6"></i>
                        <div class="text-left">
                            <span class="block text-[10px] uppercase font-bold text-teal-950">Android Package</span>
                            <span class="font-extrabold">Download APK (v1.0.7)</span>
                        </div>
                    </a>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="bg-slate-950 text-slate-400 py-16 border-t border-slate-800 text-sm">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="grid grid-cols-1 md:grid-cols-4 gap-10 pb-12 border-b border-slate-800">
                <div class="space-y-4">
                    <div class="flex items-center gap-3 text-white font-extrabold text-xl">
                        <img src="/assets/images/app-logo.png" alt="Priyo Deal Logo" class="w-8 h-8 rounded-xl object-cover">
                        <span>Priyo Deal</span>
                    </div>
                    <p class="text-xs text-slate-400 leading-relaxed">
                        প্রিয় ডিল (Priyo Deal) - বাংলাদেশের প্রথম ৩-ইন-১ লাইফস্টাইল অ্যাপ। সেবা, শপিং ও হিসাব এক ঠিকানায়।
                    </p>
                    <div class="text-xs text-slate-500">
                        Developer: <span class="text-teal-400 font-semibold">Md. Rabby Islam</span>
                    </div>
                </div>

                <div>
                    <h5 class="text-white font-bold text-xs uppercase tracking-wider mb-4">কুইক লিংকস</h5>
                    <ul class="space-y-2 text-xs">
                        <li><a href="#modules" class="hover:text-white transition">অ্যাপ ফিচারসমূহ</a></li>
                        <li><a href="#finance" class="hover:text-white transition">হিসাব খাতা</a></li>
                        <li><a href="#doctors" class="hover:text-white transition">ডাক্তার তালিকা</a></li>
                        <li><a href="#shops" class="hover:text-white transition">শপ ডিরেক্টরি</a></li>
                        <li><a href="/downloads/priyodeal.apk?v=1.0.7" download="priyodeal-v1.0.7.apk" class="hover:text-teal-400 font-bold transition">Android APK ডাউনলোড</a></li>
                    </ul>
                </div>

                <div>
                    <h5 class="text-white font-bold text-xs uppercase tracking-wider mb-4">ভেন্ডর ও পার্টনার</h5>
                    <ul class="space-y-2 text-xs">
                        <li><a href="#partner-modal" onclick="document.getElementById('partner-modal').classList.remove('hidden')" class="hover:text-white transition">ডাক্তার প্রোফাইল আবেদন</a></li>
                        <li><a href="#partner-modal" onclick="document.getElementById('partner-modal').classList.remove('hidden')" class="hover:text-white transition">শপ ও মার্চেন্ট আবেদন</a></li>
                        <li><a href="/admin" class="hover:text-teal-400 transition font-semibold">এডমিন ও ভেন্ডর লগইন</a></li>
                    </ul>
                </div>

                <div>
                    <h5 class="text-white font-bold text-xs uppercase tracking-wider mb-4">যোগাযোগ ও সাপোর্ট</h5>
                    <ul class="space-y-2 text-xs">
                        <li class="flex items-center gap-2"><i data-lucide="mail" class="w-4 h-4 text-teal-400"></i> priyodealbd@gmail.com</li>
                        <li class="flex items-center gap-2"><i data-lucide="phone" class="w-4 h-4 text-teal-400"></i> +880 1700-000000</li>
                        <li class="flex items-center gap-2"><i data-lucide="globe" class="w-4 h-4 text-teal-400"></i> www.priyodeal.com.bd</li>
                        <li class="flex items-center gap-2"><i data-lucide="map-pin" class="w-4 h-4 text-teal-400"></i> ঢাকা, বাংলাদেশ</li>
                    </ul>
                </div>
            </div>

            <div class="pt-8 flex flex-col sm:flex-row justify-between items-center text-xs text-slate-500 gap-4">
                <div>&copy; 2026 Priyo Deal. All rights reserved. Platform by Md. Rabby Islam.</div>
                <div class="flex gap-6">
                    <a href="/admin" class="hover:text-slate-300">Admin Login</a>
                    <a href="#privacy" class="hover:text-slate-300">Privacy Policy</a>
                    <a href="#terms" class="hover:text-slate-300">Terms of Service</a>
                </div>
            </div>
        </div>
    </footer>

    <!-- Sticky Bottom Download Bar for Mobile -->
    <div class="fixed bottom-0 inset-x-0 z-50 bg-white/95 backdrop-blur-md border-t border-slate-200 py-2.5 px-4 sm:hidden flex items-center justify-between shadow-2xl">
        <div class="flex items-center gap-2.5">
            <img src="/assets/images/app-logo.png" class="w-10 h-10 rounded-xl shadow border border-slate-100 object-cover">
            <div>
                <div class="font-bold text-xs text-slate-900">Priyo Deal (v1.0.7)</div>
                <div class="text-[10px] text-teal-600 font-semibold">ফ্রি অ্যান্ড্রয়েড অ্যাপ • ২২.৯ MB</div>
            </div>
        </div>
        <a href="/downloads/priyodeal.apk?v=1.0.7" download="priyodeal-v1.0.7.apk" class="inline-flex items-center gap-1.5 bg-gradient-to-r from-teal-600 to-sky-600 text-white px-4 py-2 rounded-xl text-xs font-bold shadow-md shadow-teal-600/30 active:scale-95">
            <i data-lucide="download" class="w-3.5 h-3.5"></i>
            <span>ডাউনলোড</span>
        </a>
    </div>

    <script>
        lucide.createIcons();

        // Vendor form async submission
        const form = document.getElementById('vendor-apply-form');
        const msg = document.getElementById('vendor-msg');
        form.addEventListener('submit', async (e) => {
            e.preventDefault();
            msg.className = 'text-xs p-3 rounded-xl bg-slate-100 text-slate-700 block';
            msg.innerText = 'আবেদন পাঠানো হচ্ছে...';
            
            const formData = new FormData(form);
            const data = Object.fromEntries(formData.entries());
            try {
                const res = await fetch('/api/v1/vendor/apply', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify(data)
                });
                const result = await res.json();
                if (result.success) {
                    msg.className = 'text-xs p-3 rounded-xl bg-teal-50 text-teal-800 font-bold block';
                    msg.innerText = 'ধন্যবাদ! আপনার আবেদন সফলভাবে জমা হয়েছে। এডমিন অনুমোদনের পর ডিরেক্টরিতে প্রদর্শিত হবে।';
                    form.reset();
                } else {
                    msg.className = 'text-xs p-3 rounded-xl bg-rose-50 text-rose-800 font-bold block';
                    msg.innerText = result.message || 'ত্রুটি ঘটেছে, আবার চেষ্টা করুন।';
                }
            } catch (err) {
                msg.className = 'text-xs p-3 rounded-xl bg-rose-50 text-rose-800 font-bold block';
                msg.innerText = 'সার্ভারে সংযোগে সমস্যা। একটু পরে আবার চেষ্টা করুন।';
            }
        });
    </script>
</body>
</html>
