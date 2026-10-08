import arsenalHome from '@/assets/club-arsenal-home.webp.asset.json';
import arsenalAway from '@/assets/club-arsenal-away.webp.asset.json';
import arsenalKids from '@/assets/club-arsenal-kids.webp.asset.json';
import madridHome from '@/assets/club-madrid-home.webp.asset.json';
import madridAway from '@/assets/club-madrid-away.webp.asset.json';
import bayernHome from '@/assets/club-bayern-home.webp.asset.json';
import bayernAway from '@/assets/club-bayern-away.webp.asset.json';
import interHome from '@/assets/club-inter-home.webp.asset.json';
import interAway from '@/assets/club-inter-away.webp.asset.json';
import psgHome from '@/assets/club-psg-home.webp.asset.json';
import psgAway from '@/assets/club-psg-away.webp.asset.json';

// Real retailer product photos used only for the sample collection, not verified store inventory.
const clubKits:Record<string,Record<string,string>>={
 'arsenal-home-jersey':{'Home · Red / White':arsenalHome.url,'Away · Navy':arsenalAway.url},
 'real-madrid-home':{'Home · White':madridHome.url,'Away · Green':madridAway.url},
 'bayern-home':{'Home · Red':bayernHome.url,'Away · White':bayernAway.url},
 'inter-home':{'Home · Blue / Black':interHome.url,'Away · White':interAway.url},
 'psg-home':{'Home · Blue / Red':psgHome.url,'Away · White':psgAway.url},
 'kids-home-jersey':{'Home · Red / White':arsenalKids.url,'Away · Navy':arsenalAway.url},
};
export function demoKitColors(slug:string){const kits=clubKits[slug];return kits?Object.keys(kits):undefined;}
export function demoKitPhoto(slug:string,color:string){return clubKits[slug]?.[color];}