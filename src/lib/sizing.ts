export const sizeTypes = ['clothing', 'footwear', 'kids_clothing', 'kids_footwear', 'none'] as const;
export type SizeType = typeof sizeTypes[number];
export type SizeSystem = 'EU' | 'UK' | 'US';
export const clothingSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', '3XL'];
export const kidsClothingSizes = ['4-5Y', '6-7Y', '8-9Y', '10-11Y', '12-13Y'];
export const sockSizes = ['S/M', 'L/XL'];
export function sizesFor(type: string, category: string): string[] {
  if (type === 'none') return ['One size'];
  if (type === 'footwear') return Array.from({ length: 10 }, (_, i) => String(i + 38));
  if (type === 'kids_footwear') return Array.from({ length: 10 }, (_, i) => String(i + 28));
  if (category === 'socks') return sockSizes;
  return type === 'kids_clothing' ? kidsClothingSizes : clothingSizes;
}
// Approximate unisex conversions. Adult US uses men's sizing; brands may vary.
const adultShoes = [
  ['38', '5', '6', '23.5'], ['39', '5.5', '6.5', '24.0'],
  ['40', '6.5', '7.5', '25.0'], ['41', '7', '8', '25.5'],
  ['42', '8', '9', '26.5'], ['43', '9', '10', '27.5'],
  ['44', '9.5', '10.5', '28.0'], ['45', '10.5', '11.5', '29.0'],
  ['46', '11', '12', '29.5'], ['47', '12', '13', '30.5'],
];
const kidsShoes = [
  ['28', '10K', '11C', '17.0'], ['29', '11K', '12C', '17.5'],
  ['30', '11.5K', '12.5C', '18.0'], ['31', '12.5K', '13.5C', '19.0'],
  ['32', '13K', '1Y', '19.5'], ['33', '1', '2Y', '20.0'],
  ['34', '2', '3Y', '21.0'], ['35', '2.5', '3.5Y', '21.5'],
  ['36', '3.5', '4.5Y', '22.5'], ['37', '4', '5Y', '23.0'],
];
export function footwearChart(type: string) { return type === 'kids_footwear' ? kidsShoes : adultShoes; }
export function sizeLabel(size: string, type: string, system: SizeSystem = 'EU') {
  if (!type.includes('footwear')) return size;
  const row = footwearChart(type).find(row => row[0] === size);
  return `${system} ${system === 'EU' ? size : row?.[system === 'UK' ? 1 : 2] ?? size}`;
}
export function sizeStock<T extends { size: string; stock: number }>(product: { size_type: string; category: string; product_sizes: T[] }): T[] {
  return sizesFor(product.size_type, product.category).flatMap(size => {
    const row = product.product_sizes.find(row => row.size === size);
    return row ? [row] : [];
  });
}