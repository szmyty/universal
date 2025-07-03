export type Config = {
    api: {
        hostname: string;
        port: string;
        prefix: string;
        protocol: string;
        baseUrl: string;
        user: string;
    };
    keplergl: {
        mapbox: {
            accessToken: string;
            exportToken: string;
        };
        dropbox: {
            clientId: string;
        };
        carto: {
            clientId: string;
        };
        foursquare: {
            clientId: string;
            domain: string;
            apiUrl: string;
            userMapsUrl: string;
        };
        openAI: {
            token: string;
        };
    };
};
