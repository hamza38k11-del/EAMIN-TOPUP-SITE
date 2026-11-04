const allowedOrigin = "https://hamza38k11-del.github.io";
const corsHeaders = {
  "Access-Control-Allow-Origin": allowedOrigin,
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Max-Age": "86400",
  "Vary": "Origin",
};

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json; charset=utf-8" },
  });
}

function findName(data: any): string {
  const direct = [
    data?.nickname, data?.username, data?.name,
    data?.AccountInfo?.AccountName, data?.accountInfo?.accountName,
    data?.basicInfo?.nickname, data?.basic_info?.nickname,
    data?.data?.nickname, data?.data?.AccountInfo?.AccountName,
    data?.result?.nickname,
  ];
  const found = direct.find((v) => typeof v === "string" && v.trim());
  if (found) return found.trim();
  if (data && typeof data === "object") {
    for (const [key, value] of Object.entries(data)) {
      if (["nickname", "accountname", "username"].includes(key.toLowerCase()) &&
          typeof value === "string" && value.trim()) return value.trim();
      if (value && typeof value === "object") {
        const nested = findName(value);
        if (nested) return nested;
      }
    }
  }
  return "";
}

Deno.serve(async (req) => {
  const origin = req.headers.get("origin");
  if (req.method === "OPTIONS") {
    if (origin && origin !== allowedOrigin) return new Response("Forbidden", { status: 403 });
    return new Response("ok", { headers: corsHeaders });
  }
  if (origin && origin !== allowedOrigin) return json({ error: "origin_not_allowed" }, 403);
  if (req.method !== "GET") return json({ error: "method_not_allowed" }, 405);

  const uid = new URL(req.url).searchParams.get("uid")?.trim() ?? "";
  if (!/^\\d{5,15}$/.test(uid)) return json({ error: "invalid_uid" }, 400);

  const endpoints = [
    `https://api2.nftoken.info/checkbanned?id=${encodeURIComponent(uid)}`,
    `https://api2.nftoken.info/get?uid=${encodeURIComponent(uid)}&region=BD`,
    `https://api2.nftoken.info/player-info?uid=${encodeURIComponent(uid)}`,
  ];

  for (const endpoint of endpoints) {
    try {
      const response = await fetch(endpoint, {
        headers: { "Accept": "application/json", "User-Agent": "EAMIN-TOPUP/1.0" },
        signal: AbortSignal.timeout(6500),
      });
      if (!response.ok) continue;
      const data = await response.json();
      const name = findName(data);
      if (name) return json({ success: true, uid, name });
    } catch (_error) {
      // Try the next documented API endpoint.
    }
  }
  return json({ success: false, error: "player_lookup_unavailable" }, 502);
});
