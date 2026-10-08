# Zenith Sports Website

SIZES (important)

Each product has a size_type: "clothing", "footwear", "kids_clothing", "kids_footwear" or "none" (gym equipment, balls, accessories, indoor games).

- Clothing (jerseys, tracksuits, tees, shorts, jackets, socks): selectable size buttons XS, S, M, L, XL, XXL, 3XL. Socks: S/M and L/XL.

- Footwear (boots, slides, trainers, sandals): selectable size buttons EU 38 to 47, with a toggle to switch between EU, UK and US sizes.

- Kids: sizes by age (e.g. 4-5Y, 6-7Y, 8-9Y, 10-11Y, 12-13Y) for clothing, and EU 28 to 37 for footwear.

- Products with size_type "none" show no size selector.

Behavior:

- Sizes appear as clear, tappable buttons (minimum 44px tall). The selected size is highlighted in the brand accent color.

- Each size has its own stock count in the database. Sizes that are out of stock are greyed out with a strikethrough and can't be selected. Show "Only 2 left" when stock is low.

- "Add to Cart" is disabled until a size is chosen, and shows a clear message "Please select a size" if tapped without one.

- The chosen size is saved in the cart, checkout, order record and admin order view.

- Add a "Size Guide" popup with a chart for clothing and a foot-length chart for footwear.

- In the admin dashboard, when adding or editing a product, the owner picks the size type and enters the stock for each size.

- The size filter on category and brand pages shows clothing sizes or shoe sizes depending on the category, and only displays sizes that exist in that category.

HERO SLIDER (lightweight and mobile-friendly)

Directly under the header, build a full-width hero slider with 4 slides themed around the top football leagues: Premier League, La Liga, Bundesliga and Serie A. Each slide has a football-action image of players in motion, a bold headline (e.g. "Premier League Season Kits"), a short subtext and a "Shop Now" button linking to the matching jerseys or boots category.

- Slides auto-advance every 5 seconds with a smooth slide or fade transition, pause on hover/touch, and support swipe on phones. Include small dot indicators and subtle arrows (arrows hidden on mobile).

- Add a slow, subtle parallax or zoom on the image, using CSS transforms only.

- PERFORMANCE: use CSS and a lightweight approach, with no heavy animation library and no video. Serve images in WebP, sized separately for mobile and desktop (max about 150KB each), load only the first slide immediately and lazy-load the others. Reserve the slide height to prevent layout shift. Respect "prefers-reduced-motion" by disabling auto-slide.

- Directly below the hero, add a thin horizontally scrolling strip of league and club shortcut chips (Premier League, La Liga, Bundesliga, Serie A, Ligue 1) that link to filtered jersey pages. Use text chips, not logos.

- On mobile, the hero should be about 60 to 70% of the screen height with text readable over a dark gradient overlay.

This project was built with [Lovable](https://lovable.dev).

## Build with Lovable

Continue developing this project in the [Lovable editor](https://lovable.dev/projects/88d6a1ee-6067-4405-9519-c5c74302b64a).

- **Ship faster**: describe what you want to build and Lovable handles the code.
- **Stay in sync**: every change made in Lovable is committed straight to this repository.
- **Full ownership**: this code is yours. Push to `main` on GitHub and your changes sync back into Lovable, ready for your next prompt.

## Development

Prefer working locally? You need Node.js and npm — [install with nvm](https://github.com/nvm-sh/nvm#installing-and-updating).

```sh
git clone <this-repository-url>
cd <repository-name>
npm i
npm run dev
```
