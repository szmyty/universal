export const isAuthEnabled = (): boolean => {
    // return import.meta.env.MOCK_AUTH === "false";
    return true; // Always enable auth for now
};

export const config = {
    api: {
        hostname: import.meta.env.FQDN,
        port: import.meta.env.WEB_HTTPS_PORT,
        prefix: import.meta.env.API_PREFIX,
        protocol: "https",
        get baseUrl() {
            return `${this.protocol}://${this.hostname}:${this.port}${this.prefix}`;
        },
        get user() {
            return `${this.baseUrl}/me`;
        },
    },
};
