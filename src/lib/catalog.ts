import { queryOptions } from '@tanstack/react-query';
import { getCatalog } from './store.functions';
import jersey from '@/assets/jersey.webp';
import boots from '@/assets/boots.webp';
import trainers from '@/assets/trainers.webp';
import tracksuit from '@/assets/tracksuit.webp';
import dumbbell from '@/assets/dumbbell.webp';
import ball from '@/assets/ball.webp';
export const catalogQuery=queryOptions({queryKey:['catalog'],queryFn:()=>getCatalog(),staleTime:30000});
export type Product=Awaited<ReturnType<typeof getCatalog>>[number];
const images:Record<string,string>={jersey,boots,trainers,tracksuit,dumbbell,ball};
export const productImage=(p:Product)=>{const custom=p.images as string[];return custom?.[0]||images[p.image_key]||jersey;};
export const price=(p:Product)=>p.sale_price??p.price;
export const money=(value:number)=>'₦'+value.toLocaleString('en-NG');
export const brands=['Nike','Adidas','Under Armour','Puma','New Balance','Umbro'];
export const leagues=['Premier League','La Liga','Bundesliga','Serie A','Ligue 1'];
export const slugify=(s:string)=>s.toLowerCase().replace(/ & /g,'-').replace(/ /g,'-');
export const groups:Record<string,string[]>={Football:['Jerseys','Boots','Footballs','Socks','Shin Guards','Goalkeeper Gloves'],Clothing:['Tracksuits','Jerseys','Tees','Shorts','Socks','Jackets'],Footwear:['Slides','Boots','Trainers','Sandals'],'Gym & Fitness':['Weights & Dumbbells','Mats','Resistance Bands','Gym Bags'],'Indoor Games':['Snooker','Table Tennis','Board Games'],Outdoor:['Tennis','Running','Cycling','Camping']};
export function metadata(title:string,description:string){return {meta:[{title:title+' | Zenithsports NG'},{name:'description',content:description},{property:'og:title',content:title+' | Zenithsports NG'},{property:'og:description',content:description},{property:'og:type',content:'website'},{name:'twitter:card',content:'summary_large_image'}]};}
