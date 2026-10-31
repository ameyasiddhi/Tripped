# Tripped

An anonymous globe where power plant engineers light up the problems they keep running into. Others tap "me too", and the biggest problems glow brightest.

- No account, no name, no ads, no tracking cookies.
- Lamps sit near the poster's country, scattered on purpose, never on a real plant.
- New posts pulse for 24 hours. A "me too" makes a lamp grow and flash.
- Posts with company names, people's names, links or phone numbers are held for review. Three reports take a post down until you check it.
- When someone starts fixing a problem, you can turn its lamp green from the admin page.

## Files

| File | What it is |
|---|---|
| `index.html` | The globe, the post form and the "Top problems" list |
| `admin.html` | Your private review page (held posts, hide, mark as being fixed, emails) |
| `shared.js` | Country list, categories and the database connection |
| `config.js` | Where your two Supabase keys go. Empty = demo mode |
| `supabase/schema.sql` | The database setup, run once in Supabase |

## How it's hosted

- **GitHub** (`ameyasiddhi/tripped`) holds the code.
- **Vercel** hosts the site and redeploys automatically on every push to `main`.
- **Supabase** stores posts, "me too" taps and the optional emails.

## Step 1: Connect Vercel (3 minutes)

1. In Vercel, click **Add New > Project** and **Import** the existing `tripped` repository. Don't use "Clone" or a template, which tries to create a new repo.
2. Framework preset: **Other**. Leave the build command and output directory empty.
3. Click **Deploy**. You get a link like `https://tripped-xxxx.vercel.app`.

Until Supabase is connected, the site runs in **demo mode**: sample posts, and anything you post stays only on your own device. That's enough to show someone how it works.

## Step 2: Create the database (5 minutes)

1. Sign up at supabase.com (free plan) and click **New project**. Pick a region close to your users (Mumbai if most will be in India) and set any database password.
2. When the project is ready, open **SQL Editor > New query**.
3. Open `supabase/schema.sql`, find `YOUR_ADMIN_EMAIL` and replace it with the email you'll use to sign in as admin. Paste the whole file into the editor and click **Run**. Run it only once, or the sample posts will be added twice.

## Step 3: Connect the site to the database (2 minutes)

1. In Supabase, click **Connect** at the top of your project (or open **Settings > API Keys**). Copy the **Project URL** and the **publishable** key (on older projects it's called the **anon / public** key). Never use the secret or service_role key here.
2. Paste the two values between the quotes in `config.js` and push (or send them to Claude to push).
3. Vercel redeploys in about a minute. Reload your site. The "Demo mode" badge disappears, and posts and "me too" taps are now shared with everyone.

The publishable key is designed to be public. The database rules in `schema.sql` decide what it can do: read live posts, create posts, add "me too" and report. It can't read emails, held posts or edit anything.

## Step 4: Turn on your admin page

1. In Supabase, open **Authentication > URL Configuration**.
2. Set **Site URL** to your Vercel link, and under **Redirect URLs** add the same link followed by `/admin.html`, for example `https://tripped-xxxx.vercel.app/admin.html`.
3. Open that admin link, enter your admin email, and click the sign-in link you receive. Open the email on the same device.

From the admin page you can publish or hide held posts, hide live ones, mark a problem as being fixed (its lamp turns green) and see the optional emails people left.

## Before you share it

- The 10 sample posts are tagged "Sample" on the globe. Once you have about 20 real posts, delete them from the admin page, or run `delete from posts where is_sample;` in the SQL Editor.
- Don't seed posts from your own employer's plant, and check your employment contract for IP and conflict-of-interest clauses before launching publicly.
- On the free plan, Supabase pauses a project after a week of low activity, and emails you a warning first. If the site stops loading posts, open the project in the Supabase dashboard and click **Resume project**. Your data is kept.

## Numbers to track for your YC application

Run these in the Supabase SQL Editor:

```sql
-- Real posts, me-toos and countries so far
select count(*) as posts, sum(metoo_count) as metoos, count(distinct country) as countries
from posts where status = 'live' and not is_sample;

-- Posts per day
select date(created_at) as day, count(*) from posts where not is_sample group by 1 order by 1;

-- Engineers who want to hear about a fix (your first customer-discovery calls)
select count(*) from post_contacts;

-- Problems flagged in the most countries
select p.body, count(distinct m.country) as countries, p.metoo_count
from posts p join metoos m on m.post_id = p.id
where p.status = 'live' group by p.id order by countries desc, p.metoo_count desc limit 10;
```

## Known limits of v1

- Screening is a keyword filter, not AI. It catches emails, links, phone numbers, words like "Pvt Ltd" and titles like "Mr." before a name. It won't catch everything, which is what the Report button and your admin page are for.
- There's no server-side rate limit. The site limits one post per minute per device, and the admin page lets you clean up quickly if someone spams it.
- Fonts load from Google Fonts and the country outlines from jsDelivr. If either is blocked, the globe still works with system fonts and without outlines.
