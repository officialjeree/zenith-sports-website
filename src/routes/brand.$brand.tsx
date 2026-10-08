import {createFileRoute} from '@tanstack/react-router';
import {CatalogPage,parseSearch} from '@/components/catalog-page';
import {catalogQuery,metadata} from '@/lib/catalog';
export const Route=createFileRoute('/brand/$brand')({validateSearch:parseSearch,head:({params})=>metadata(params.brand.replace(/-/g,' ').toUpperCase(),'Explore '+params.brand.replace(/-/g,' ')+' sportswear and equipment at Zenithsports NG, Lagos.'),loader:({context})=>context.queryClient.ensureQueryData(catalogQuery),errorComponent:()=> <p>Unable to load this brand. Please refresh.</p>,notFoundComponent:()=> <p>Brand not found.</p>,component:Page});
function Page(){return <CatalogPage brand={Route.useParams().brand} search={Route.useSearch()}/>}
