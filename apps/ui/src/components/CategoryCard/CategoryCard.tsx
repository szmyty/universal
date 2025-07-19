import { motion } from 'framer-motion';
import type { BlogCategory } from '@/data/blogCategories';

export interface CategoryCardProps {
  category: BlogCategory;
}

export default function CategoryCard({ category }: CategoryCardProps) {
  return (
    <motion.div
      whileHover={{ scale: 1.05 }}
      className="relative w-40 h-24 flex-shrink-0 rounded overflow-hidden shadow"
    >
      <img
        src={category.image || '/assets/categories/placeholder.jpg'}
        alt={category.name}
        className="absolute inset-0 w-full h-full object-cover"
      />
      <div className="absolute inset-0 bg-black/40 flex items-end transition-opacity hover:bg-black/30">
        <span className="text-white p-2 text-sm font-semibold">
          {category.name}
        </span>
      </div>
    </motion.div>
  );
}
