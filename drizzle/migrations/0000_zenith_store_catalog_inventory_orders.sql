CREATE TABLE public.user_roles(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,role text NOT NULL CHECK(role IN ('admin','customer')),UNIQUE(user_id,role));
GRANT SELECT ON public.user_roles TO authenticated; GRANT ALL ON public.user_roles TO service_role;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
CREATE POLICY own_roles ON public.user_roles FOR SELECT TO authenticated USING(user_id=auth.uid());
CREATE FUNCTION public.is_store_admin() RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path=public AS $$ SELECT EXISTS(SELECT 1 FROM public.user_roles WHERE user_id=auth.uid() AND role='admin') $$;
CREATE TABLE public.profiles(id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,full_name text NOT NULL DEFAULT '',addresses jsonb NOT NULL DEFAULT '[]');
GRANT SELECT,INSERT,UPDATE ON public.profiles TO authenticated; GRANT ALL ON public.profiles TO service_role;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY own_profile ON public.profiles FOR ALL TO authenticated USING(id=auth.uid()) WITH CHECK(id=auth.uid());
CREATE FUNCTION public.create_store_profile() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path=public AS $$ BEGIN INSERT INTO public.profiles(id,full_name) VALUES(NEW.id,COALESCE(NEW.raw_user_meta_data->>'full_name','')); RETURN NEW; END $$;
CREATE TRIGGER store_profile_signup AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.create_store_profile();
CREATE TABLE public.categories(slug text PRIMARY KEY,name text NOT NULL);
GRANT SELECT ON public.categories TO anon; GRANT ALL ON public.categories TO authenticated,service_role;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY categories_read ON public.categories FOR SELECT TO anon,authenticated USING(true);
CREATE POLICY categories_admin ON public.categories FOR ALL TO authenticated USING(public.is_store_admin()) WITH CHECK(public.is_store_admin());
CREATE TABLE public.brands(slug text PRIMARY KEY,name text NOT NULL);
GRANT SELECT ON public.brands TO anon; GRANT ALL ON public.brands TO authenticated,service_role;
ALTER TABLE public.brands ENABLE ROW LEVEL SECURITY;
CREATE POLICY brands_read ON public.brands FOR SELECT TO anon,authenticated USING(true);
CREATE POLICY brands_admin ON public.brands FOR ALL TO authenticated USING(public.is_store_admin()) WITH CHECK(public.is_store_admin());
CREATE TABLE public.products(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),slug text NOT NULL UNIQUE,name text NOT NULL,brand text NOT NULL,category text NOT NULL,league text,price integer NOT NULL CHECK(price>=0),sale_price integer CHECK(sale_price>=0),size_type text NOT NULL DEFAULT 'none' CHECK(size_type IN ('clothing','footwear','kids_clothing','kids_footwear','none')),image_key text NOT NULL DEFAULT 'jersey',images jsonb NOT NULL DEFAULT '[]',colors text[] NOT NULL DEFAULT ARRAY['Black'],description text NOT NULL DEFAULT '',best_seller boolean NOT NULL DEFAULT false,active boolean NOT NULL DEFAULT true,created_at timestamptz NOT NULL DEFAULT now());
GRANT SELECT ON public.products TO anon; GRANT ALL ON public.products TO authenticated,service_role;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
CREATE POLICY products_read ON public.products FOR SELECT TO anon,authenticated USING(active OR public.is_store_admin());
CREATE POLICY products_admin ON public.products FOR ALL TO authenticated USING(public.is_store_admin()) WITH CHECK(public.is_store_admin());
CREATE TABLE public.product_sizes(product_id uuid NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,size text NOT NULL,stock integer NOT NULL DEFAULT 0 CHECK(stock>=0),PRIMARY KEY(product_id,size));
GRANT SELECT ON public.product_sizes TO anon; GRANT ALL ON public.product_sizes TO authenticated,service_role;
ALTER TABLE public.product_sizes ENABLE ROW LEVEL SECURITY;
CREATE POLICY sizes_read ON public.product_sizes FOR SELECT TO anon,authenticated USING(EXISTS(SELECT 1 FROM public.products p WHERE p.id=product_id AND p.active));
CREATE POLICY sizes_admin ON public.product_sizes FOR ALL TO authenticated USING(public.is_store_admin()) WITH CHECK(public.is_store_admin());
CREATE TABLE public.carts(token_hash text PRIMARY KEY,items jsonb NOT NULL DEFAULT '[]',updated_at timestamptz NOT NULL DEFAULT now());
GRANT ALL ON public.carts TO service_role; ALTER TABLE public.carts ENABLE ROW LEVEL SECURITY;
CREATE TABLE public.wishlists(user_id uuid NOT NULL,product_id uuid NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,PRIMARY KEY(user_id,product_id));
GRANT ALL ON public.wishlists TO authenticated,service_role; ALTER TABLE public.wishlists ENABLE ROW LEVEL SECURITY;
CREATE POLICY own_wishlist ON public.wishlists FOR ALL TO authenticated USING(user_id=auth.uid()) WITH CHECK(user_id=auth.uid());
CREATE TABLE public.orders(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),order_number text NOT NULL UNIQUE,token_hash text NOT NULL,user_id uuid,email text NOT NULL,customer_name text NOT NULL,phone text NOT NULL,address jsonb NOT NULL,delivery_method text NOT NULL CHECK(delivery_method IN ('pickup','lagos','nationwide')),payment_method text NOT NULL CHECK(payment_method IN ('pickup','paystack')),status text NOT NULL DEFAULT 'Pending' CHECK(status IN ('Pending','Paid','Shipped','Delivered','Cancelled')),subtotal integer NOT NULL,total integer NOT NULL,payment_reference text UNIQUE,created_at timestamptz NOT NULL DEFAULT now());
GRANT SELECT,UPDATE ON public.orders TO authenticated; GRANT ALL ON public.orders TO service_role; ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY orders_owner_read ON public.orders FOR SELECT TO authenticated USING(user_id=auth.uid() OR public.is_store_admin());
CREATE POLICY orders_admin_write ON public.orders FOR UPDATE TO authenticated USING(public.is_store_admin()) WITH CHECK(public.is_store_admin());
CREATE TABLE public.order_items(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),order_id uuid NOT NULL REFERENCES public.orders(id),product_id uuid,name text NOT NULL,size text NOT NULL,color text NOT NULL,quantity integer NOT NULL,unit_price integer NOT NULL);
GRANT SELECT ON public.order_items TO authenticated; GRANT ALL ON public.order_items TO service_role; ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY items_owner_read ON public.order_items FOR SELECT TO authenticated USING(EXISTS(SELECT 1 FROM public.orders o WHERE o.id=order_id AND (o.user_id=auth.uid() OR public.is_store_admin())));
CREATE TABLE public.reviews(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),product_id uuid NOT NULL REFERENCES public.products(id),user_id uuid NOT NULL,rating integer NOT NULL CHECK(rating BETWEEN 1 AND 5),body text NOT NULL,created_at timestamptz NOT NULL DEFAULT now());
GRANT SELECT ON public.reviews TO anon; GRANT SELECT,INSERT,UPDATE,DELETE ON public.reviews TO authenticated; GRANT ALL ON public.reviews TO service_role; ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
CREATE POLICY reviews_read ON public.reviews FOR SELECT TO anon,authenticated USING(true);
CREATE POLICY reviews_own ON public.reviews FOR ALL TO authenticated USING(user_id=auth.uid()) WITH CHECK(user_id=auth.uid());
CREATE TABLE public.contact_messages(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),name text NOT NULL,email text NOT NULL,message text NOT NULL,created_at timestamptz NOT NULL DEFAULT now());
GRANT SELECT ON public.contact_messages TO authenticated; GRANT ALL ON public.contact_messages TO service_role; ALTER TABLE public.contact_messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY contacts_admin ON public.contact_messages FOR SELECT TO authenticated USING(public.is_store_admin());
CREATE FUNCTION public.place_pickup_order(p_hash text,p_email text,p_name text,p_phone text,p_address jsonb) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=public AS $$
DECLARE c public.carts; item jsonb; prod public.products; available integer; qty integer; amount integer:=0; oid uuid:=gen_random_uuid(); num text:='ZN-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10));
BEGIN
SELECT * INTO c FROM public.carts WHERE token_hash=p_hash FOR UPDATE;
IF c IS NULL OR jsonb_array_length(c.items)=0 THEN RAISE EXCEPTION 'Your bag is empty'; END IF;
FOR item IN SELECT value FROM jsonb_array_elements(c.items) ORDER BY value->>'product_id',value->>'size' LOOP
qty:=(item->>'quantity')::integer; IF qty<1 OR qty>20 THEN RAISE EXCEPTION 'Invalid quantity'; END IF;
SELECT * INTO prod FROM public.products WHERE id=(item->>'product_id')::uuid AND active;
IF prod IS NULL THEN RAISE EXCEPTION 'Product unavailable'; END IF;
SELECT stock INTO available FROM public.product_sizes WHERE product_id=prod.id AND size=item->>'size' FOR UPDATE;
IF available IS NULL OR available<qty THEN RAISE EXCEPTION 'Not enough stock for % size %',prod.name,item->>'size'; END IF;
UPDATE public.product_sizes SET stock=stock-qty WHERE product_id=prod.id AND size=item->>'size';
amount:=amount+COALESCE(prod.sale_price,prod.price)*qty;
END LOOP;
INSERT INTO public.orders(id,order_number,token_hash,email,customer_name,phone,address,delivery_method,payment_method,subtotal,total) VALUES(oid,num,p_hash,p_email,p_name,p_phone,p_address,'pickup','pickup',amount,amount);
FOR item IN SELECT value FROM jsonb_array_elements(c.items) LOOP
SELECT * INTO prod FROM public.products WHERE id=(item->>'product_id')::uuid;
INSERT INTO public.order_items(order_id,product_id,name,size,color,quantity,unit_price) VALUES(oid,prod.id,prod.name,item->>'size',item->>'color',(item->>'quantity')::integer,COALESCE(prod.sale_price,prod.price));
END LOOP;
UPDATE public.carts SET items='[]',updated_at=now() WHERE token_hash=p_hash;
RETURN jsonb_build_object('id',oid,'order_number',num,'total',amount);
END $$;
REVOKE ALL ON FUNCTION public.place_pickup_order(text,text,text,text,jsonb) FROM PUBLIC,anon,authenticated; GRANT EXECUTE ON FUNCTION public.place_pickup_order(text,text,text,text,jsonb) TO service_role;
INSERT INTO public.categories(slug,name) VALUES('jerseys','Jerseys'),('boots','Football Boots'),('footballs','Footballs'),('tracksuits','Tracksuits'),('tees','Tees'),('shorts','Shorts'),('socks','Socks'),('jackets','Jackets'),('slides','Slides'),('trainers','Trainers'),('sandals','Sandals'),('weights-dumbbells','Weights & Dumbbells'),('mats','Mats'),('resistance-bands','Resistance Bands'),('gym-bags','Gym Bags'),('snooker','Snooker'),('table-tennis','Table Tennis'),('board-games','Board Games'),('tennis','Tennis'),('running','Running'),('cycling','Cycling'),('camping','Camping'),('shin-guards','Shin Guards'),('goalkeeper-gloves','Goalkeeper Gloves');
INSERT INTO public.brands(slug,name) VALUES('nike','Nike'),('adidas','Adidas'),('under-armour','Under Armour'),('puma','Puma'),('new-balance','New Balance'),('umbro','Umbro');
INSERT INTO public.products(slug,name,brand,category,league,price,sale_price,size_type,image_key,colors,best_seller,description) VALUES
('arsenal-home-jersey','Arsenal Home Jersey','Adidas','jerseys','Premier League',28000,NULL,'clothing','jersey',ARRAY['Red'],true,'Lightweight match-day jersey with breathable fabric. Sample catalog item; confirm availability with the store.'),
('mercurial-vapor-boots','Mercurial Vapor Football Boots','Nike','boots',NULL,65000,55000,'footwear','boots',ARRAY['Volt'],true,'Lightweight boots made for speed on firm ground. Sample catalog item.'),
('real-madrid-home','Real Madrid Home Jersey','Adidas','jerseys','La Liga',30000,NULL,'clothing','jersey',ARRAY['White'],true,'Breathable football jersey. Sample catalog item.'),
('bayern-home','Bayern Munich Home Jersey','Adidas','jerseys','Bundesliga',28000,NULL,'clothing','jersey',ARRAY['Red'],false,'Match-day football jersey. Sample catalog item.'),
('inter-home','Inter Milan Home Jersey','Nike','jerseys','Serie A',30000,NULL,'clothing','jersey',ARRAY['Blue'],false,'Football jersey. Sample catalog item.'),
('psg-home','Paris Saint-Germain Home Jersey','Nike','jerseys','Ligue 1',29000,NULL,'clothing','jersey',ARRAY['Blue'],false,'Football jersey. Sample catalog item.'),
('puma-future-boots','Future Match Football Boots','Puma','boots',NULL,58000,NULL,'footwear','boots',ARRAY['Volt'],true,'Firm ground football boots. Sample catalog item.'),
('umbro-match-ball','Neo Match Football','Umbro','footballs',NULL,18000,NULL,'none','ball',ARRAY['White'],true,'Match football. Sample catalog item.'),
('adidas-training-tracksuit','Essential Training Tracksuit','Adidas','tracksuits',NULL,48000,42000,'clothing','tracksuit',ARRAY['Black'],true,'Two-piece training set. Sample catalog item.'),
('ua-performance-tee','Performance Training Tee','Under Armour','tees',NULL,22000,NULL,'clothing','jersey',ARRAY['Black'],false,'Training tee. Sample catalog item.'),
('nike-training-shorts','Dri-FIT Training Shorts','Nike','shorts',NULL,18000,NULL,'clothing','tracksuit',ARRAY['Black'],false,'Training shorts. Sample catalog item.'),
('umbro-socks','Match Football Socks','Umbro','socks',NULL,5000,NULL,'clothing','tracksuit',ARRAY['Black'],false,'Football socks. Sample catalog item.'),
('puma-jacket','Team Training Jacket','Puma','jackets',NULL,36000,NULL,'clothing','tracksuit',ARRAY['Black'],false,'Training jacket. Sample catalog item.'),
('adidas-slides','Adilette Comfort Slides','Adidas','slides',NULL,24000,NULL,'footwear','trainers',ARRAY['Black'],true,'Comfort slides. Sample catalog item.'),
('new-balance-trainers','Fresh Foam Running Trainers','New Balance','trainers',NULL,72000,62000,'footwear','trainers',ARRAY['Black'],true,'Running trainers. Sample catalog item.'),
('nike-sandals','Everyday Sport Sandals','Nike','sandals',NULL,25000,NULL,'footwear','trainers',ARRAY['Black'],false,'Sport sandals. Sample catalog item.'),
('adjustable-dumbbell','Adjustable Dumbbell 10kg','Under Armour','weights-dumbbells',NULL,45000,NULL,'none','dumbbell',ARRAY['Black'],true,'Adjustable dumbbell. Sample catalog item.'),
('training-mat','Fitness Training Mat','Adidas','mats',NULL,15000,NULL,'none','dumbbell',ARRAY['Black'],false,'Exercise mat. Sample catalog item.'),
('resistance-band-set','Resistance Band Set','Puma','resistance-bands',NULL,12000,NULL,'none','dumbbell',ARRAY['Black'],false,'Resistance bands. Sample catalog item.'),
('gym-duffel','Training Duffel Bag','Nike','gym-bags',NULL,32000,NULL,'none','tracksuit',ARRAY['Black'],false,'Gym bag. Sample catalog item.'),
('table-tennis-set','Table Tennis Bat Set','Umbro','table-tennis',NULL,12000,NULL,'none','ball',ARRAY['Red'],false,'Table tennis set. Sample catalog item.'),
('chess-set','Classic Chess Set','Umbro','board-games',NULL,15000,NULL,'none','ball',ARRAY['Black'],false,'Board game set. Sample catalog item.'),
('kids-home-jersey','Kids Home Football Jersey','Adidas','jerseys','Premier League',18000,NULL,'kids_clothing','jersey',ARRAY['Red'],false,'Kids football jersey. Sample catalog item.'),
('kids-football-boots','Kids Future Football Boots','Puma','boots',NULL,35000,NULL,'kids_footwear','boots',ARRAY['Volt'],false,'Kids football boots. Sample catalog item.');
INSERT INTO public.product_sizes(product_id,size,stock) SELECT p.id,s,CASE WHEN s IN ('XS','38','28') THEN 0 WHEN s IN ('M','42','8-9Y') THEN 2 ELSE 8 END FROM public.products p CROSS JOIN LATERAL unnest(CASE WHEN p.category='socks' THEN ARRAY['S/M','L/XL'] WHEN p.size_type='clothing' THEN ARRAY['XS','S','M','L','XL','XXL','3XL'] WHEN p.size_type='footwear' THEN ARRAY['38','39','40','41','42','43','44','45','46','47'] WHEN p.size_type='kids_clothing' THEN ARRAY['4-5Y','6-7Y','8-9Y','10-11Y','12-13Y'] WHEN p.size_type='kids_footwear' THEN ARRAY['28','29','30','31','32','33','34','35','36','37'] ELSE ARRAY['One size'] END) s;