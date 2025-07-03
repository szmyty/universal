// SPDX-License-Identifier: MIT
// Copyright ...

import { config } from "@/config";
import DropboxProvider from "./dropbox/dropbox-provider";
import CartoProvider from "./carto/carto-provider";
import FoursquareProvider from "./foursquare/foursquare-provider";

const DROPBOX_CLIENT_NAME = "Kepler.gl Demo App";

// Destructure short vars from config.keplergl
const {
    dropbox: { clientId: dropboxClientId },
    carto: { clientId: cartoClientId },
    foursquare: {
        clientId: foursquareClientId,
        domain: foursquareDomain,
        apiUrl: foursquareApiUrl,
        userMapsUrl: foursquareUserMapsUrl,
    },
} = config.keplergl;

export const DEFAULT_CLOUD_PROVIDER = "dropbox" as const;

export const CLOUD_PROVIDERS = [
    new FoursquareProvider({
        clientId: foursquareClientId,
        authDomain: foursquareDomain,
        apiURL: foursquareApiUrl,
        userMapsURL: foursquareUserMapsUrl,
    }),
    new DropboxProvider(dropboxClientId, DROPBOX_CLIENT_NAME),
    new CartoProvider(cartoClientId),
];

// Optional: strongly typed cloud provider names
export type CloudProviderName = "dropbox" | "carto" | "foursquare";

export function getCloudProvider(providerName: CloudProviderName) {
    const cloudProvider = CLOUD_PROVIDERS.find((p) => p.name === providerName);
    if (!cloudProvider) {
        throw new Error(`Unknown cloud provider: ${providerName}`);
    }
    return cloudProvider;
}
