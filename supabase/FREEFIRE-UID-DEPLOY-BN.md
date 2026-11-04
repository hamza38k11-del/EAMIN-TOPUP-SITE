# Free Fire UID নাম দেখানোর সার্ভার ফাংশন

ওয়েবসাইট থেকে সরাসরি Free Fire API কল করলে API সার্ভারের CORS নীতির কারণে ব্রাউজার উত্তর পড়তে নাও পারে। তাই `supabase/functions/freefire-player/index.ts`-এ সার্ভার-সাইড ফাংশন যোগ করা হয়েছে।

## গুরুত্বপূর্ণ
GitHub-এ ফাইল যোগ হলেই Supabase-এ ফাংশন চালু হয় না। একবার Supabase Dashboard থেকে এটি deploy করতে হবে।

## Deploy করার ধাপ
1. Supabase Dashboard খুলুন: https://supabase.com/dashboard/project/jaldowgrjugtessgcgnf/functions
2. **Deploy a new function** / **Create function** নির্বাচন করুন।
3. Function name দিন: `freefire-player`
4. GitHub-এর `supabase/functions/freefire-player/index.ts` ফাইলের সম্পূর্ণ কোড কপি করে function editor-এ পেস্ট করুন।
5. Deploy চাপুন।

এই ফাংশনটি শুধু EAMIN TOP-UP-এর GitHub Pages origin থেকে অনুরোধ গ্রহণ করে এবং UID-এর জন্য নাম খোঁজে। এটি Free Fire/Garena-এর অফিসিয়াল API নয়; তৃতীয় পক্ষের API-এর প্রাপ্যতার ওপর ফল নির্ভর করবে।

Deploy সম্পন্ন হলে ওয়েবসাইটের ফ্রন্টএন্ডকে Edge Function endpoint-এ পরিবর্তন করতে হবে। Deploy শেষ হলে আমাকে জানালে আমি পরের কোড পরিবর্তন করে দেব।
