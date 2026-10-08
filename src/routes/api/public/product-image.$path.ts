import { createFileRoute } from '@tanstack/react-router';
import { createClient } from '@supabase/supabase-js';
import fallbackImage from '@/assets/jersey.webp';

// Uploaded photos come from storage; anything missing redirects to the bundled jersey image.
const fallback = (request: Request) =>
  new Response(null, {
    status: 302,
    headers: { Location: new URL(fallbackImage, request.url).toString(), 'Cache-Control': 'public, max-age=300' },
  });

export const Route = createFileRoute('/api/public/product-image/$path')({
  server: {
    handlers: {
      GET: async ({ params, request }) => {
        if (!/^[a-f0-9-]+\.(png|jpe?g|webp|avif)$/i.test(params.path)) return fallback(request);
        const url = process.env['SUPABASE_URL'];
        const key = process.env['SUPABASE_PUBLISHABLE_KEY'];
        if (!url || !key) return fallback(request);
        try {
          const db = createClient(url, key, { auth: { persistSession: false }, accessToken: async () => null });
          const { data, error } = await db.storage.from('product-images').download(params.path);
          if (error || !data) return fallback(request);
          return new Response(data, {
            headers: { 'Content-Type': data.type || 'image/webp', 'Cache-Control': 'public, max-age=86400' },
          });
        } catch {
          return fallback(request);
        }
      },
    },
  },
});
