import { useRouter } from "@tanstack/react-router";

export function useMapRouteInfo() {
    const router = useRouter();
    const location = router.state.location;

    const match = router.state.matches.at(-1);

    const { category, id, provider, ...otherParams } = match?.params ?? {};
    const query = match?.search ?? {};

    return {
        category,
        id,
        provider: provider ?? query.provider ?? undefined,
        query,
        location,
        pathname: location.pathname,
        routeId: match?.routeId,
    };
}
