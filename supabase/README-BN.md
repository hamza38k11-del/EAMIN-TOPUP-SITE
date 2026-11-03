# EAMIN TOP-UP — Database setup (বাংলা)

এই ফোল্ডারে Supabase ডেটাবেসের নিরাপদ প্রাথমিক কাঠামো রাখা হয়েছে।

## কী তৈরি হবে
- গ্রাহকের প্রোফাইল
- পণ্যের প্যাকেজ ও দাম
- অর্ডার এবং অর্ডারের অবস্থা
- Add Money অনুরোধ
- Wallet লেনদেনের হিসাব
- গ্রাহকের Top-up Codes
- Row Level Security (RLS): গ্রাহক শুধু নিজের তথ্য দেখতে পারবে; অ্যাডমিনের জন্য আলাদা অনুমতি

## চালু করার ধাপ
1. https://supabase.com এ একটি project তৈরি করতে হবে।
2. Project → SQL Editor → New query খুলুন।
3. `schema.sql` ফাইলের সম্পূর্ণ লেখা পেস্ট করে Run করুন।
4. Authentication → Users থেকে নিজের অ্যাডমিন অ্যাকাউন্ট তৈরি করুন।
5. সেই ব্যবহারকারীর UUID কপি করে SQL Editor-এ নিচের কমান্ড চালান:
   `update public.profiles set role = 'admin' where id = 'YOUR_AUTH_USER_UUID';`
6. Project Settings → API থেকে Project URL এবং anon/publishable key নিতে হবে।

## নিরাপত্তা
- `service_role` key কখনো ওয়েবসাইটে, GitHub-এ বা কাউকে পাঠাবেন না।
- শুধু Project URL এবং anon/publishable key frontend-এ ব্যবহার করা যায়; RLS চালু রাখুন।
- পেমেন্টের Transaction ID লেখা মানেই পেমেন্ট যাচাই নয়। অ্যাডমিনকে bKash/Nagad-এ টাকা মিলিয়ে অনুমোদন দিতে হবে।
- এই schema একা লাইভ wallet/payment automation চালু করে না; ওয়েবসাইটে Supabase সংযোগ এবং অ্যাডমিন UI-ও যুক্ত করতে হবে।
