import red from '@/assets/jersey-red.webp';
import white from '@/assets/jersey-white.webp';
import blue from '@/assets/jersey-blue.webp';
import black from '@/assets/jersey-black.webp';
import navy from '@/assets/jersey-navy.webp';
import yellow from '@/assets/jersey-yellow.webp';

const photos:Record<string,string>={red,white,blue,black,navy,yellow};
export function kitOption(value:string){const parts=value.split(' · ');return {kit:parts.length>1?parts[0]??'Home':'Home',color:parts.length>1?parts.slice(1).join(' · '):value,value};}
export function jerseyPhoto(category:string,color:string){return category==='jerseys'?photos[kitOption(color).color.toLowerCase()]:undefined;}