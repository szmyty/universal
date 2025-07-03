import type { Config } from "./config.types";

const env: ImportMetaEnv = import.meta.env;

export const config: Config = {
    api: {
        hostname: env.FQDN,
        port: env.WEB_HTTPS_PORT,
        prefix: env.API_PREFIX,
        protocol: "https",
        get baseUrl() {
            return `${this.protocol}://${this.hostname}:${this.port}${this.prefix}`;
        },
        get user() {
            return `${this.baseUrl}/me`;
        },
    },
    keplergl: {
        mapbox: {
            accessToken: env.MapboxAccessToken,
            exportToken: env.MapboxExportToken,
        },
        dropbox: {
            clientId: env.DropboxClientId,
        },
        carto: {
            clientId: env.CartoClientId,
        },
        foursquare: {
            clientId: env.FoursquareClientId,
            domain: env.FoursquareDomain,
            apiUrl: env.FoursquareAPIURL,
            userMapsUrl: env.FoursquareUserMapsURL,
        },
        openAI: {
            token: env.OpenAIToken,
        },
    },
};
