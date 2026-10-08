import { createContext,useContext,useState,useEffect,type ReactNode } from 'react';
import { useServerFn } from '@tanstack/react-start';
import { toast } from 'sonner';
import { readCart,writeCart,type CartItem } from '@/lib/store.functions';
import { supabase } from '@/integrations/supabase/client';
import type { Product } from '@/lib/catalog';
type StoreState={items:CartItem[];token:string;cartOpen:boolean;setCartOpen:(v:boolean)=>void;add:(p:Product,size:string,color:string,quantity:number)=>Promise<void>;update:(index:number,quantity:number)=>Promise<void>;clear:()=>void;wishlist:string[];toggleWish:(id:string)=>Promise<void>;user:{id:string;email?:string}|null};
const StoreContext=createContext<StoreState|null>(null);
export function StoreProvider({children}:{children:ReactNode}){
 const [items,setItems]=useState<CartItem[]>([]),[token,setToken]=useState(''),[cartOpen,setCartOpen]=useState(false),[wishlist,setWishlist]=useState<string[]>([]),[user,setUser]=useState<{id:string;email?:string}|null>(null);
 const read=useServerFn(readCart),write=useServerFn(writeCart);
 useEffect(()=>{let t=localStorage.getItem('zenith-bag-token');if(!t){t=crypto.randomUUID();localStorage.setItem('zenith-bag-token',t);}setToken(t);read({data:{token:t}}).then(setItems).catch(()=>toast.error('Unable to restore your bag'));const refresh=async()=>{const {data}=await supabase.auth.getUser();setUser(data.user);if(data.user){const {data:wishes}=await supabase.from('wishlists').select('product_id').eq('user_id',data.user.id);setWishlist(wishes?.map(w=>w.product_id)??[]);}else setWishlist([]);};void refresh();const {data:subscription}=supabase.auth.onAuthStateChange(event=>{if(['SIGNED_IN','SIGNED_OUT','USER_UPDATED'].includes(event))void refresh();});return()=>subscription.subscription.unsubscribe();},[]);
 async function persist(next:CartItem[]){await write({data:{token,items:next}});setItems(next);}
 async function add(p:Product,size:string,color:string,quantity:number){if(!token)return;const next=[...items];const index=next.findIndex(i=>i.product_id===p.id&&i.size===size&&i.color===color);if(index>=0)next[index]={...next[index],quantity:next[index].quantity+quantity};else next.push({product_id:p.id,size,color,quantity});try{await persist(next);setCartOpen(true);toast.success('Added to your bag');}catch(e){toast.error(e instanceof Error?e.message:'Unable to add item');}}
 async function update(index:number,quantity:number){try{await persist(items.flatMap((item,i)=>i===index?(quantity>0?[{...item,quantity}]:[]):[item]));}catch(e){toast.error(e instanceof Error?e.message:'Unable to update bag');}}
 async function toggleWish(id:string){if(!user){toast('Sign in to save your favourites');return;}const exists=wishlist.includes(id);const result=exists?await supabase.from('wishlists').delete().eq('user_id',user.id).eq('product_id',id):await supabase.from('wishlists').insert({user_id:user.id,product_id:id});if(result.error){toast.error('Unable to save favourite');return;}setWishlist(exists?wishlist.filter(v=>v!==id):[...wishlist,id]);toast.success(exists?'Removed from wishlist':'Saved to wishlist');}
 return <StoreContext.Provider value={{items,token,cartOpen,setCartOpen,add,update,clear:()=>setItems([]),wishlist,toggleWish,user}}>{children}</StoreContext.Provider>;
}
export function useStore(){const context=useContext(StoreContext);if(!context)throw new Error('Missing store context');return context;}
