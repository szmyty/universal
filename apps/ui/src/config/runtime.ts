export const isAuthEnabled = (): boolean => {
    return import.meta.env.VITE_ENABLE_AUTH === "true";
};
