import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { clothingSizes, kidsClothingSizes, footwearChart } from '@/lib/sizing';

export function SizeGuide({ open, onOpenChange, type, category }: { open: boolean; onOpenChange: (open: boolean) => void; type: string; category: string }) {
  const shoe = type.includes('footwear');
  const socks = category === 'socks';
  const kids = type === 'kids_clothing';
  const headers = shoe ? ['EU', 'UK', 'US', 'Foot length (cm)'] : socks ? ['Size', 'EU shoe size'] : ['Size', 'Chest (cm)', 'Waist (cm)'];
  const rows = shoe ? footwearChart(type) : socks ? [['S/M', '38–42'], ['L/XL', '43–47']] : (kids ? kidsClothingSizes : clothingSizes).map((size, i) => [size, kids ? `${58 + i * 6}–${64 + i * 6}` : `${80 + i * 8}–${88 + i * 8}`, kids ? `${54 + i * 4}–${58 + i * 4}` : `${64 + i * 8}–${72 + i * 8}`]);
  return <Dialog open={open} onOpenChange={onOpenChange}><DialogContent className="size-guide"><DialogHeader><DialogTitle className="font-display text-3xl">{shoe ? 'FOOTWEAR' : socks ? 'SOCKS' : kids ? 'KIDS CLOTHING' : 'CLOTHING'} SIZE GUIDE</DialogTitle></DialogHeader><p className="text-xs text-muted-foreground">Approximate measurements; fit varies by brand.{shoe && (type === 'kids_footwear' ? ' US children’s / youth sizes; K and C denote children’s sizes.' : ' US sizes use men’s sizing.')}</p><div className="size-guide-table"><table><thead><tr>{headers.map(h => <th key={h} scope="col">{h}</th>)}</tr></thead><tbody>{rows.map(row => <tr key={row[0]}>{row.map((cell, i) => <td key={i}>{cell}</td>)}</tr>)}</tbody></table></div></DialogContent></Dialog>;
}