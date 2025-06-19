import type { ButtonHTMLAttributes } from "react";

// Props accepted by the Button component.
export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
    // Optional CSS class names to apply in addition to the defaults.
    className?: string;
}
