<!-- LOVABLE:BEGIN -->
> [!IMPORTANT]
> This project is connected to [Lovable](https://lovable.dev). Avoid rewriting
> published git history — force pushing, or rebasing/amending/squashing commits
> that are already pushed — as it rewrites history on Lovable's side and the
> user will likely lose their project history.
>
> Commits you push to the connected branch sync back to Lovable and show up in
> the editor, so keep the branch in a working state.
<!-- LOVABLE:END -->

## Store architecture
- Jersey home/away choices use a canonical kit-and-color label in the existing color field so cart and order views retain both; illustrative color photos never override uploaded product photos.
- Use TanStack leaf routes for storefront collections and information pages; each defines its own share metadata for direct sharing.
- Public catalog reads use an anonymous server client with RLS; privileged mutations use authenticated owner-role checks.
- Guest cart access uses a high-entropy capability token hashed in storage; order creation locks cart and size inventory atomically to prevent overselling.
- Persist canonical EU footwear sizes in carts and orders; display-unit switching never changes the stored variant.
- Centralize size ranges and conversion charts in the sizing module; replace product and size inventory together in an owner-authorized transaction to avoid obsolete variants after size-type changes.
- Use CSS-only league slides with separate optimized desktop/mobile WebP assets to keep the first screen lightweight.
- Owner permissions live only in user_roles and RLS, never browser storage or profile metadata.
- Keep public product photo serving behind a controlled storage read endpoint when workspace settings prohibit public buckets.
