import arsenalHome from '@/assets/club-arsenal-home.webp';
import arsenalAway from '@/assets/club-arsenal-away.webp';
import arsenalKids from '@/assets/club-arsenal-kids.webp';
import madridHome from '@/assets/club-madrid-home.webp';
import madridAway from '@/assets/club-madrid-away.webp';
import bayernHome from '@/assets/club-bayern-home.webp';
import bayernAway from '@/assets/club-bayern-away.webp';
import interHome from '@/assets/club-inter-home.webp';
import interAway from '@/assets/club-inter-away.webp';
import psgHome from '@/assets/club-psg-home.webp';
import psgAway from '@/assets/club-psg-away.webp';

// Real retailer product photos used only for the sample collection, not verified store inventory.
const clubKits:Record<string,Record<string,string>>={
 'arsenal-home-jersey':{'Home · Red / White':arsenalHome,'Away · Navy':arsenalAway},
 'real-madrid-home':{'Home · White':madridHome,'Away · Green':madridAway},
 'bayern-home':{'Home · Red':bayernHome,'Away · White':bayernAway},
 'inter-home':{'Home · Blue / Black':interHome,'Away · White':interAway},
 'psg-home':{'Home · Blue / Red':psgHome,'Away · White':psgAway},
 'kids-home-jersey':{'Home · Red / White':arsenalKids,'Away · Navy':arsenalAway},
};
export function demoKitColors(slug:string){const kits=clubKits[slug];return kits?Object.keys(kits):undefined;}
export function demoKitPhoto(slug:string,color:string){return clubKits[slug]?.[color];}