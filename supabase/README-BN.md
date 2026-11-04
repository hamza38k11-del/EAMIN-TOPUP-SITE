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


## অ্যাডমিন প্যানেল চালু (নতুন)

1. Supabase → SQL Editor → New query খুলুন।
2. নিচে দেওয়া নতুন `supabase/guest-orders.sql` migration চালালে Guest table এবং Registered wallet approval function—দুটিই তৈরি হবে। পুরোনো `admin-functions.sql` আলাদা করে চালানোর দরকার নেই।
3. Authentication → Users থেকে নিজের অ্যাকাউন্টের ইমেইল নিশ্চিত করুন।
4. SQL Editor-এ নিচের কমান্ড চালিয়ে নিজের ইমেইল বসিয়ে role admin করুন:

```sql
update public.profiles
set role = 'admin'
where id = (select id from auth.users where email = 'YOUR-LOGIN-EMAIL');
```

5. ওয়েবসাইটের শেষে `/admin.html` যোগ করে Admin প্যানেলে লগইন করুন।

**সতর্কতা:** bKash/Nagad অ্যাপে টাকা সত্যিই এসেছে কি না মিলিয়ে তারপরই Approve করবেন। Transaction ID একা পেমেন্টের প্রমাণ নয়।


## Guest Order ও Guest Add Money Admin-এ দেখাতে (নতুন)

1. Supabase Dashboard → SQL Editor → New query খুলুন।
2. GitHub-এর `supabase/guest-orders.sql` ফাইলের সম্পূর্ণ SQL কপি করে Run করুন। এটি Guest order এবং Guest Add Money-এর জন্য আলাদা টেবিল ও RLS নিরাপত্তা তৈরি করবে।
3. Authentication → Users-এ আপনার Admin ইমেইল দিয়ে Email/Password user তৈরি করুন (ইমেইল নিশ্চিত করুন)।
4. SQL Editor-এ নিচের SQL চালান (আপনার Admin ইমেইলটি বসান):

```sql
update public.profiles
set role = 'admin'
where id = (select id from auth.users where email = 'nehalmozumdee@gmail.com');
```

5. Admin প্যানেল খুলুন: https://hamza38k11-del.github.io/EAMIN-TOPUP-SITE/admin.html
6. ঐ Admin email ও password দিয়ে লগইন করুন। এরপর Refresh চাপলে Guest ও Registered order/request দেখা যাবে।

**মনে রাখবেন:** Guest Add Money অনুমোদন করলে শুধু request-এর status বদলাবে; Guest-এর wallet balance স্বয়ংক্রিয়ভাবে বাড়বে না। bKash/Nagad-এ টাকা হাতে যাচাই করে তারপর status পরিবর্তন করবেন। SQL migration Run না করা পর্যন্ত Guest checkout database-এ জমা হবে না।
