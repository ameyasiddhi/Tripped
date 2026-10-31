-- Extra sample posts for Europe, the United States, Canada and Australia.
-- They're tagged "Sample" on the globe and start with 0 me-toos.
-- Paste into Supabase > SQL Editor > New query and click Run (once).

insert into public.posts(body, category, plant_type, country, region, lat, lon, is_sample, metoo_count, created_at) values
-- Europe
('Getting a crane for a gearbox or blade swap takes 6 to 8 weeks. The turbine just sits idle meanwhile.', 'om', 'wind', 'Germany', 'Lower Saxony', 52.9, 8.9, true, 0, now() - interval '2 days'),
('Soiling losses climb fast every summer, but cleaning crews are booked out for weeks.', 'manpower', 'solar', 'Spain', 'Andalusia', 37.6, -4.6, true, 0, now() - interval '5 days'),
('Coal units now cycle every day to follow renewables. Boiler tube failures have doubled and the maintenance plan still assumes baseload.', 'om', 'thermal', 'Poland', null, 51.4, 19.2, true, 0, now() - interval '3 days'),
('Outage know-how sits with a handful of people close to retirement. Nothing they know is written down in a usable way.', 'manpower', 'nuclear', 'France', null, 45.9, 4.4, true, 0, now() - interval '9 days'),
('Curtailment instructions arrive with minutes of warning, and ramp schedules get rebuilt over the phone.', 'other', 'gas', 'Netherlands', null, 51.9, 5.3, true, 0, now() - interval '6 days'),
('Sediment builds up at the intake every winter. Flushing permits take months to approve.', 'compliance', 'hydro', 'Italy', 'Lombardy', 46.1, 10.1, true, 0, now() - interval '11 days'),
('Offshore access windows are short. A crew transfer cancelled at 6 am wastes the whole day.', 'om', 'wind', 'United Kingdom', null, 54.2, -1.3, true, 0, now() - interval '18 hours'),
('Control system spares for our 1990s units are obsolete. We buy them second-hand from other plants.', 'spares', 'hydro', 'Sweden', null, 63.2, 15.6, true, 0, now() - interval '4 days'),
-- United States
('Gas turbine output drops 10 to 15% on hot afternoons, exactly when demand peaks.', 'om', 'gas', 'United States', 'Arizona', 33.6, -112.3, true, 0, now() - interval '2 days'),
('The plant retires in 3 years, so nobody approves repairs. Equipment runs until it fails.', 'procurement', 'thermal', 'United States', 'Ohio', 40.2, -82.6, true, 0, now() - interval '7 days'),
('Our solar-plus-storage project has waited 4 years in the interconnection queue for a grid study.', 'compliance', 'solar', 'United States', 'California', 36.4, -119.6, true, 0, now() - interval '10 days'),
('Main bearing failures across the fleet, and a replacement has a 9-month lead time.', 'spares', 'wind', 'United States', 'Iowa', 42.1, -93.7, true, 0, now() - interval '5 days'),
('Paperwork for a like-for-like part replacement takes longer than the repair itself.', 'compliance', 'nuclear', 'United States', 'Pennsylvania', 40.7, -77.3, true, 0, now() - interval '12 days'),
-- Canada
('Ice builds up on the intake trash racks every winter. Clearing it is manual and risky.', 'om', 'hydro', 'Canada', 'Quebec', 48.3, -71.8, true, 0, now() - interval '3 days'),
('Cold starts at -35 C trip units on low fuel gas temperature. The heaters were sized for -20 C.', 'om', 'gas', 'Canada', 'Alberta', 52.6, -113.4, true, 0, now() - interval '8 days'),
('Refurbishment outages need hundreds of skilled trades, and we compete for the same welders as every other big project.', 'manpower', 'nuclear', 'Canada', 'Ontario', 44.4, -79.9, true, 0, now() - interval '6 days'),
('The plant is 4 hours from the nearest town. Hiring and keeping operators is the hardest part of the job.', 'manpower', 'hydro', 'Canada', 'British Columbia', 50.7, -122.1, true, 0, now() - interval '14 days'),
-- Australia
('Minimum load keeps getting pushed lower because of rooftop solar. Our mills and burners were never designed for it.', 'om', 'thermal', 'Australia', 'New South Wales', -32.6, 150.3, true, 0, now() - interval '4 days'),
('Inverters derate in 45 C heat, right when prices are highest.', 'om', 'solar', 'Australia', 'Queensland', -23.7, 148.4, true, 0, now() - interval '20 hours'),
('Grid connection standards changed mid-project, and retesting cost us months.', 'compliance', 'wind', 'Australia', 'Victoria', -37.4, 143.2, true, 0, now() - interval '9 days'),
('Fly-in fly-out rosters burn people out. High turnover means we are always retraining.', 'manpower', 'gas', 'Australia', 'Western Australia', -22.3, 117.8, true, 0, now() - interval '13 days'),
('Battery cells are degrading faster than the warranty model. Proving it to the supplier takes months of data.', 'other', 'other', 'Australia', 'South Australia', -34.2, 139.1, true, 0, now() - interval '7 days');
