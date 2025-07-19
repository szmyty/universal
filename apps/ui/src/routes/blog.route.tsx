import { createRoute } from '@tanstack/react-router';
import { rootRoute } from './index';
import { lazy, Suspense } from 'react';
import { PageLoader } from '@universal/components';

const LazyBlog = lazy(() => import('../pages/Blog').then((m) => ({ default: m.default })));

export const blogRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/blog',
  component: () => (
    <Suspense fallback={<PageLoader />}>
      <LazyBlog />
    </Suspense>
  ),
});
