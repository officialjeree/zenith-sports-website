CREATE OR REPLACE FUNCTION public.save_product_inventory(p_product jsonb, p_sizes jsonb, p_id uuid DEFAULT NULL) RETURNS uuid LANGUAGE plpgsql SECURITY INVOKER SET search_path = public AS $$
DECLARE saved_id uuid := COALESCE(p_id, gen_random_uuid()); size_type_value text := p_product->>'size_type'; allowed_sizes text[]; submitted_size text;
BEGIN
IF NOT public.is_store_admin() THEN RAISE EXCEPTION 'Owner access required'; END IF;
allowed_sizes := CASE WHEN size_type_value='none' THEN ARRAY['One size'] WHEN size_type_value='footwear' THEN ARRAY['38','39','40','41','42','43','44','45','46','47'] WHEN size_type_value='kids_footwear' THEN ARRAY['28','29','30','31','32','33','34','35','36','37'] WHEN p_product->>'category'='socks' AND size_type_value IN ('clothing','kids_clothing') THEN ARRAY['S/M','L/XL'] WHEN size_type_value='clothing' THEN ARRAY['XS','S','M','L','XL','XXL','3XL'] WHEN size_type_value='kids_clothing' THEN ARRAY['4-5Y','6-7Y','8-9Y','10-11Y','12-13Y'] ELSE NULL END;
IF allowed_sizes IS NULL OR jsonb_typeof(p_sizes) <> 'array' OR jsonb_array_length(p_sizes) <> cardinality(allowed_sizes) THEN RAISE EXCEPTION 'Enter stock for every valid size'; END IF;
IF (SELECT count(DISTINCT value->>'size') FROM jsonb_array_elements(p_sizes)) <> cardinality(allowed_sizes) THEN RAISE EXCEPTION 'Duplicate or missing sizes'; END IF;
FOR submitted_size IN SELECT value->>'size' FROM jsonb_array_elements(p_sizes) LOOP
IF submitted_size IS NULL OR NOT submitted_size = ANY(allowed_sizes) THEN RAISE EXCEPTION 'Invalid size'; END IF;
END LOOP;
INSERT INTO public.products(id,name,slug,brand,category,price,sale_price,size_type,image_key,images,colors,description,league)
VALUES(saved_id,p_product->>'name',p_product->>'slug',p_product->>'brand',p_product->>'category',(p_product->>'price')::integer,(p_product->>'sale_price')::integer,size_type_value,p_product->>'image_key',p_product->'images',ARRAY(SELECT jsonb_array_elements_text(p_product->'colors')),p_product->>'description',p_product->>'league')
ON CONFLICT(id) DO UPDATE SET name=EXCLUDED.name,slug=EXCLUDED.slug,brand=EXCLUDED.brand,category=EXCLUDED.category,price=EXCLUDED.price,sale_price=EXCLUDED.sale_price,size_type=EXCLUDED.size_type,image_key=EXCLUDED.image_key,images=EXCLUDED.images,colors=EXCLUDED.colors,description=EXCLUDED.description,league=EXCLUDED.league;
DELETE FROM public.product_sizes WHERE product_id=saved_id AND NOT size=ANY(allowed_sizes);
INSERT INTO public.product_sizes(product_id,size,stock) SELECT saved_id,value->>'size',(value->>'stock')::integer FROM jsonb_array_elements(p_sizes) ON CONFLICT(product_id,size) DO UPDATE SET stock=EXCLUDED.stock;
RETURN saved_id;
END $$;
REVOKE ALL ON FUNCTION public.save_product_inventory(jsonb,jsonb,uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.save_product_inventory(jsonb,jsonb,uuid) TO authenticated;