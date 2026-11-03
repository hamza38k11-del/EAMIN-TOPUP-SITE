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
2. GitHub-এর `supabase/admin-functions.sql` ফাইলের সম্পূর্ণ SQL পেস্ট করে Run করুন। এটি Add Money approve করলে একই transaction-এ wallet ledger-এ টাকা যোগ করবে; একই request দ্বিতীয়বার credit হবে না।
3. Authentication → Users থেকে নিজের অ্যাকাউন্টের ইমেইল নিশ্চিত করুন।
4. SQL Editor-এ নিচের কমান্ড চালিয়ে নিজের ইমেইল বসিয়ে role admin করুন:

```sql
update public.profiles
set role = 'admin'
where id = (select id from auth.users where email = 'YOUR-LOGIN-EMAIL');
```

5. ওয়েবসাইটের শেষে `/admin.html` যোগ করে Admin প্যানেলে লগইন করুন।

**সতর্কতা:** bKash/Nagad অ্যাপে টাকা সত্যিই এসেছে কি না মিলিয়ে তারপরই Approve করবেন। Transaction ID একা পেমেন্টের প্রমাণ নয়।
