// Shared data and database helpers for Tripped (used by index.html and admin.html).
(function () {
  // name, lat, lon, spread (degrees of random scatter so lamps never sit on a real plant)
  const COUNTRIES = [
    ["Algeria",28,2,4],["Argentina",-35,-64,4],["Australia",-25,134,6],["Austria",47.5,14.5,1],
    ["Bangladesh",23.7,90.3,1],["Belgium",50.6,4.6,0.6],["Bhutan",27.4,90.4,0.5],["Brazil",-12,-51,6],
    ["Bulgaria",42.7,25.3,1],["Canada",55,-100,7],["Chile",-32,-71,2],["China",33,105,6],
    ["Colombia",4.5,-74,2],["Czechia",49.8,15.5,1],["Denmark",56,9.5,0.8],["Egypt",26.5,30,3],
    ["Ethiopia",8.6,39.5,3],["Finland",63,26,2],["France",46.5,2.5,2.5],["Germany",51.2,10.4,2],
    ["Ghana",7.9,-1.1,1.5],["Greece",39.3,22,1.2],["Hungary",47.2,19.4,1],["India",22,79,5],
    ["Indonesia",-2.5,115,6],["Iran",32.5,54,4],["Iraq",33,43.7,2],["Ireland",53.2,-8,1],
    ["Israel",31.4,35,0.4],["Italy",42.8,12.5,2],["Japan",36.5,138,2.5],["Jordan",31.2,36.5,0.8],
    ["Kazakhstan",48,67,6],["Kenya",0.2,37.9,2.5],["Kuwait",29.3,47.6,0.4],["Malaysia",3.8,102,2.5],
    ["Mexico",23.6,-102.5,5],["Morocco",31.8,-6.8,2.5],["Mozambique",-18,35,3],["Myanmar",21,96,3],
    ["Nepal",28.3,84,1.2],["Netherlands",52.2,5.4,0.7],["New Zealand",-41.5,173,2],["Nigeria",9.1,8.7,3],
    ["Norway",61,9,2],["Oman",21,57,2],["Pakistan",29.5,69.5,4],["Peru",-9.5,-75,3],
    ["Philippines",12.5,122,3],["Poland",52,19.4,2],["Portugal",39.6,-8,1],["Qatar",25.3,51.2,0.3],
    ["Romania",45.9,24.9,1.5],["Russia",57,60,10],["Saudi Arabia",24,45,4],["Singapore",1.35,103.8,0.1],
    ["South Africa",-29,25,3.5],["South Korea",36.4,127.8,1.2],["Spain",40.2,-3.6,2.5],["Sri Lanka",7.8,80.7,0.8],
    ["Sweden",62,16,3],["Switzerland",46.8,8.2,0.6],["Taiwan",23.7,121,0.8],["Tanzania",-6.3,34.8,3],
    ["Thailand",15.5,101,3],["Turkey",39,35,3.5],["Uganda",1.4,32.3,1.5],["Ukraine",49,32,3],
    ["United Arab Emirates",24,54,1],["United Kingdom",53.5,-2,2],["United States",39,-98,9],
    ["Uzbekistan",41.4,64.5,2.5],["Vietnam",16,107.8,3],["Zambia",-13.5,28,3],["Zimbabwe",-19,29.8,2]
  ];
  const COUNTRY = {};
  COUNTRIES.forEach(c => COUNTRY[c[0]] = { name: c[0], lat: c[1], lon: c[2], spread: c[3] });

  const TZ = {
    "Asia/Kolkata":"India","Asia/Calcutta":"India","Asia/Dhaka":"Bangladesh","Asia/Karachi":"Pakistan",
    "Asia/Kathmandu":"Nepal","Asia/Colombo":"Sri Lanka","Asia/Jakarta":"Indonesia","Asia/Makassar":"Indonesia",
    "Asia/Shanghai":"China","Asia/Tokyo":"Japan","Asia/Seoul":"South Korea","Asia/Singapore":"Singapore",
    "Asia/Kuala_Lumpur":"Malaysia","Asia/Bangkok":"Thailand","Asia/Ho_Chi_Minh":"Vietnam","Asia/Manila":"Philippines",
    "Asia/Dubai":"United Arab Emirates","Asia/Riyadh":"Saudi Arabia","Asia/Qatar":"Qatar","Asia/Kuwait":"Kuwait",
    "Asia/Muscat":"Oman","Asia/Tehran":"Iran","Asia/Baghdad":"Iraq","Asia/Taipei":"Taiwan","Asia/Yangon":"Myanmar",
    "Asia/Almaty":"Kazakhstan","Asia/Tashkent":"Uzbekistan","Asia/Thimphu":"Bhutan","Asia/Jerusalem":"Israel",
    "Asia/Amman":"Jordan","Europe/London":"United Kingdom","Europe/Dublin":"Ireland","Europe/Berlin":"Germany",
    "Europe/Paris":"France","Europe/Madrid":"Spain","Europe/Rome":"Italy","Europe/Amsterdam":"Netherlands",
    "Europe/Brussels":"Belgium","Europe/Warsaw":"Poland","Europe/Prague":"Czechia","Europe/Vienna":"Austria",
    "Europe/Zurich":"Switzerland","Europe/Stockholm":"Sweden","Europe/Oslo":"Norway","Europe/Copenhagen":"Denmark",
    "Europe/Helsinki":"Finland","Europe/Lisbon":"Portugal","Europe/Athens":"Greece","Europe/Bucharest":"Romania",
    "Europe/Sofia":"Bulgaria","Europe/Budapest":"Hungary","Europe/Kyiv":"Ukraine","Europe/Kiev":"Ukraine",
    "Europe/Istanbul":"Turkey","Europe/Moscow":"Russia","Africa/Johannesburg":"South Africa","Africa/Lagos":"Nigeria",
    "Africa/Nairobi":"Kenya","Africa/Cairo":"Egypt","Africa/Accra":"Ghana","Africa/Casablanca":"Morocco",
    "Africa/Algiers":"Algeria","Africa/Addis_Ababa":"Ethiopia","Africa/Dar_es_Salaam":"Tanzania",
    "Africa/Kampala":"Uganda","Africa/Lusaka":"Zambia","Africa/Harare":"Zimbabwe","Africa/Maputo":"Mozambique",
    "Australia/Sydney":"Australia","Australia/Melbourne":"Australia","Australia/Perth":"Australia",
    "Australia/Brisbane":"Australia","Pacific/Auckland":"New Zealand","America/Sao_Paulo":"Brazil",
    "America/Argentina/Buenos_Aires":"Argentina","America/Santiago":"Chile","America/Bogota":"Colombia",
    "America/Lima":"Peru","America/Mexico_City":"Mexico","America/Toronto":"Canada","America/Vancouver":"Canada",
    "America/New_York":"United States","America/Chicago":"United States","America/Denver":"United States",
    "America/Los_Angeles":"United States","America/Phoenix":"United States"
  };

  function guessCountry() {
    try { return TZ[Intl.DateTimeFormat().resolvedOptions().timeZone] || ""; } catch (e) { return ""; }
  }

  const CATEGORIES = {
    spares:      { label: "Spares",      color: "#EF9F27" },
    om:          { label: "O&M",         color: "#E24B4A" },
    procurement: { label: "Procurement", color: "#378ADD" },
    manpower:    { label: "Manpower",    color: "#AFA9EC" },
    compliance:  { label: "Compliance",  color: "#5DCAA5" },
    other:       { label: "Other",       color: "#B4B2A9" }
  };
  const PLANT_TYPES = { thermal: "Thermal", hydro: "Hydro", solar: "Solar", wind: "Wind", gas: "Gas", nuclear: "Nuclear", other: "Other" };

  // Same screening rules as the database, so people get instant feedback before posting.
  function screen(t) {
    const s = (t || "").toLowerCase();
    if (/[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}/.test(s)) return "an email address";
    if (/(https?:\/\/|www\.|\.(com|in|org|net|io)\b)/.test(s)) return "a link";
    if (/\d[\d\s-]{8,}\d/.test(t || "")) return "a phone or long number";
    if (/\b(pvt|ltd|limited|llp|inc|corp|corporation|gmbh|llc|plc)\b/.test(s)) return "a company name";
    if (/\b(Mr|Mrs|Ms|Dr|Shri|Smt|Sir)\.?\s+[A-Z]/.test(t || "")) return "a person's name";
    return null;
  }

  const cfg = window.TRIPPED_CONFIG || {};
  const LIVE = !!(cfg.supabaseUrl && cfg.supabaseAnonKey);
  const base = (cfg.supabaseUrl || "").replace(/\/+$/, "");

  async function req(path, opts, token) {
    // The public key goes in the apikey header; a signed-in admin's token goes in Authorization.
    const headers = Object.assign({ apikey: cfg.supabaseAnonKey, "Content-Type": "application/json" },
      token ? { Authorization: "Bearer " + token } : {}, (opts && opts.headers) || {});
    const res = await fetch(base + path, Object.assign({}, opts, { headers }));
    const text = await res.text();
    let data = null;
    try { data = text ? JSON.parse(text) : null; } catch (e) { data = text; }
    if (!res.ok) throw new Error((data && (data.message || data.msg || data.error_description)) || res.statusText || "Request failed");
    return data;
  }
  const rpc = (fn, body, token) => req("/rest/v1/rpc/" + fn, { method: "POST", body: JSON.stringify(body) }, token);

  window.Tripped = { COUNTRIES, COUNTRY, CATEGORIES, PLANT_TYPES, guessCountry, screen, LIVE, req, rpc, cfg };
})();
