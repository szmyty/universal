import { render, screen } from '@testing-library/react';
import Button from './Button';

// Basic smoke test to ensure the component renders.
// It checks that the provided children are displayed in the document.

test('renders button with children', () => {
  render(<Button>Click Me</Button>);
  expect(screen.getByRole('button')).toHaveTextContent('Click Me');
});
