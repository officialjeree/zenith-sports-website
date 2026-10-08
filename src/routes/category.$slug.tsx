import {createFileRoute} from '@tanstack/react-router';
import {CatalogPage,parseSearch} from '@/components/catalog-page';
import {catalogQuery,metadata} from '@/lib/catalog';
export const Route=createFileRoute('/category/$slug')({validateSearch:parseSearch,head:({params})=>metadata(params.slug.replace(/-/g,' ').toUpperCase(),'Shop '+params.slug.replace(/-/g,' ')+' at Zenithsports NG, Lagos. Find your size and gear up.'),loader:({context})=>context.queryClient.ensureQueryData(catalogQuery),errorComponent:()=> <p>Unable to load this collection. Please refresh.</p>,notFoundComponent:()=> <p>Collection not found.</p>,component:Page});
function Page(){return <CatalogPage slug={Route.useParams().slug} search={Route.useSearch()}/>}
