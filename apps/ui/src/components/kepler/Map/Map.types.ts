export type MapProps = {
    isAiAssistantPanelOpen: boolean;
    isSqlPanelOpen: boolean;
    query: { sql?: string };
    keplerGlGetState: (...args: unknown[]) => unknown;
    cloudProvidersConfig: { MAPBOX_TOKEN: string };
    cloudProviders: unknown;
    messages: Record<string, string>;
    onExportFileSuccess: (...args: unknown[]) => void;
    onLoadCloudMapSuccess: (...args: unknown[]) => void;
    onViewStateChange: (...args: unknown[]) => void;
};
