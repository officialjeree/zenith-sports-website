import { createServerFn } from '@tanstack/react-start';
import { getRequest } from '@tanstack/react-start/server';
import { z } from 'zod';
import { requireSupabaseAuth } from '@/integrations/supabase/auth-middleware';

const pausedPath = 'ai-brand-access-paused.json';
export const identifyJerseyBrand = createServerFn({ method: 'POST' })
  .middleware([requireSupabaseAuth])
  .inputValidator(z.object({ path: z.string().regex(/^[0-9a-f-]{36}\.(jpg|jpeg|png|webp)$/i) }))
  .handler(async ({ data, context }) => {
    const { data: role, error: roleError } = await context.supabase.from('user_roles').select('role')
      .eq('user_id', context.userId).eq('role', 'admin').maybeSingle();
    if (roleError || !role) throw new Error('Owner access required');
    const bucket = context.supabase.storage.from('product-images');
    const { data: paused } = await bucket.download(pausedPath);
    if (paused) return { brand: null, message: 'Photo recognition is paused after an access denial. Restore AI access and remove the pause marker before trying again.' };
    const apiKey = process.env['LOVABLE_API_KEY'];
    if (!apiKey) return { brand: null, message: 'Photo recognition is not configured on this host. Add the server-only LOVABLE_API_KEY; you can still choose the brand manually.' };
    const [{ data: image, error: photoError }, { data: brands, error: brandError }] = await Promise.all([
      bucket.download(data.path), context.supabase.from('brands').select('name'),
    ]);
    if (photoError || !image || brandError) throw new Error('Unable to read the uploaded photo or store brands');
    if (!['image/jpeg', 'image/png', 'image/webp'].includes(image.type) || image.size === 0 || image.size > 5 * 1024 * 1024) {
      throw new Error('Use a JPG, PNG or WebP photo smaller than 5 MB');
    }
    const { recognizeJerseyBrand, brandRecognitionError } = await import('./jersey-brand.server');
    try {
      const output = await recognizeJerseyBrand(getRequest(), apiKey, image, (brands ?? []).map(b => b.name));
      const match = (brands ?? []).find(b => b.name.toLowerCase() === output.brand?.trim().toLowerCase());
      if (!match || output.confidence < .85) return { brand: null, message: 'No clear matching manufacturer logo found. Please choose the brand manually.' };
      return { brand: match.name, message: `Detected ${match.name}. Review the brand before saving.` };
    } catch (error) {
      const failure = brandRecognitionError(error);
      if (failure.status === 403) {
        const { error: pauseError } = await bucket.upload(pausedPath, new Blob([JSON.stringify({ message: failure.message })], { type: 'application/json' }), { upsert: true });
        if (pauseError) throw new Error('AI access denied; unable to persist the pause. Do not retry until access is restored.');
      }
      return { brand: null, message: failure.message };
    }
  });