const payment=document.querySelector('#payment');
const payNumber=document.querySelector('#payNumber');
const numbers={'bKash Personal':'01768483444','Nagad Personal':'01626635977'};
const toast=document.querySelector('#toast');
function notify(message){toast.textContent=message;toast.classList.add('show');clearTimeout(window.toastTimer);window.toastTimer=setTimeout(()=>toast.classList.remove('show'),2300)}
payment.addEventListener('change',()=>{payNumber.textContent=numbers[payment.value]||'পেমেন্ট মাধ্যম নির্বাচন করুন'});
document.querySelectorAll('.choose').forEach(button=>button.addEventListener('click',()=>{document.querySelector('#service').value=button.dataset.service;document.querySelector('#order').scrollIntoView({behavior:'smooth'});}));
document.querySelector('#copyBtn').addEventListener('click',async()=>{const value=numbers[payment.value];if(!value)return notify('আগে পেমেন্ট মাধ্যম নির্বাচন করুন');try{await navigator.clipboard.writeText(value);notify('পেমেন্ট নম্বর কপি হয়েছে ✓')}catch{notify('নম্বর: '+value)}});
document.querySelector('#menu').addEventListener('click',()=>document.querySelector('.nav nav').classList.toggle('open'));
document.querySelectorAll('.nav nav a').forEach(a=>a.addEventListener('click',()=>document.querySelector('.nav nav').classList.remove('open')));
document.querySelector('#year').textContent=new Date().getFullYear();
document.querySelector('#orderForm').addEventListener('submit',event=>{event.preventDefault();const service=document.querySelector('#service').value;const pkg=document.querySelector('#package').value.trim();const uid=document.querySelector('#uid').value.trim();const player=document.querySelector('#player').value.trim()||'দেওয়া হয়নি';const method=payment.value;const trx=document.querySelector('#trx').value.trim();const customer=document.querySelector('#customer').value.trim();const phone=numbers[method];if(!phone)return notify('পেমেন্ট মাধ্যম নির্বাচন করুন');const orderId='RDX'+Date.now().toString().slice(-8);const message=['RDX EAMIN TOP-UP — NEW ORDER','Order ID: '+orderId,'Service: '+service,'Package: '+pkg,'Player UID: '+uid,'Player Name: '+player,'Payment: '+method,'Payment Number: '+phone,'Transaction ID: '+trx,'Customer WhatsApp: '+customer].join('\n');window.open('https://wa.me/8801768434444?text='+encodeURIComponent(message),'_blank');});
