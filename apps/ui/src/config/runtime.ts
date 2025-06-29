export const isAuthEnabled = (): boolean => {
    // return import.meta.env.MOCK_AUTH === "false";
    return true; // Always enable auth for now
};

export const config = {
    api: {
        hostname: import.meta.env.API_HOSTNAME,
        port: import.meta.env.API_PORT,
        prefix: import.meta.env.API_PREFIX,
        protocol: "https",
        get baseUrl() {
            return `${this.protocol}://${this.hostname}:${this.port}${this.prefix}`;
        },
    },
};
