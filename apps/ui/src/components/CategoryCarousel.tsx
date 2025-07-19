import CategoryCard from './CategoryCard';
import type { BlogCategory } from '@/data/blogCategories';
import { motion } from 'framer-motion';

export interface CategoryCarouselProps {
  categories: BlogCategory[];
}

export default function CategoryCarousel({ categories }: CategoryCarouselProps) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true }}
      className="flex space-x-4 overflow-x-auto pb-2"
    >
      {categories.map((cat) => (
        <CategoryCard key={cat.name} category={cat} />
      ))}
    </motion.div>
  );
}
