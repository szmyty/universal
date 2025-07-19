import CategoryCarousel from '@/components/CategoryCarousel';
import { blogCategoryGroups } from '@/data/blogCategories';

export default function Blog() {
  return (
    <div className="space-y-8">
      <h1 className="text-3xl font-bold">Blog Categories</h1>
      {blogCategoryGroups.map((group) => (
        <section key={group.name} className="space-y-2">
          <h2 className="text-2xl font-semibold">{group.name}</h2>
          <CategoryCarousel categories={group.categories} />
        </section>
      ))}
    </div>
  );
}
