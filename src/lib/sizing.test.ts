import {describe,it,expect} from 'vitest';
import {sizesFor,sizeLabel,sizeStock,footwearChart} from './sizing';
describe('product sizing',()=>{
 it('uses complete adult, kids, sock and unsized ranges',()=>{
  expect(sizesFor('clothing','jerseys')).toEqual(['XS','S','M','L','XL','XXL','3XL']);
  expect(sizesFor('clothing','socks')).toEqual(['S/M','L/XL']);
  expect(sizesFor('footwear','boots')).toEqual(['38','39','40','41','42','43','44','45','46','47']);
  expect(sizesFor('kids_footwear','boots')).toEqual(['28','29','30','31','32','33','34','35','36','37']);
  expect(sizesFor('kids_clothing','jerseys')).toHaveLength(5);
  expect(sizesFor('none','socks')).toEqual(['One size']);
 });
 it('converts display labels without changing the EU variant',()=>{
  expect(sizeLabel('42','footwear','UK')).toBe('UK 8');
  expect(sizeLabel('42','footwear','US')).toBe('US 9');
  expect(sizeLabel('28','kids_footwear','US')).toBe('US 11C');
  expect(sizeLabel('M','clothing')).toBe('M');
  expect(footwearChart('kids_footwear')).toHaveLength(10);
 });
 it('excludes obsolete variants and preserves zero stock',()=>{
  expect(sizeStock({size_type:'footwear',category:'boots',product_sizes:[{size:'M',stock:8},{size:'42',stock:0},{size:'40',stock:2}]})).toEqual([{size:'40',stock:2},{size:'42',stock:0}]);
 });
});