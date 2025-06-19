import clsx from 'clsx';
import type { ButtonProps } from './Button.types';

// Button is a tiny wrapper around the native `<button>` element. It applies
// Tailwind classes for a basic style but accepts all standard button
// attributes through props.
export default function Button({ className, ...rest }: ButtonProps) {
  return (
    <button
      className={clsx(
        'px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700',
        className
      )}
      {...rest}
    />
  );
}
