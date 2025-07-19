export interface BlogCategory {
  name: string;
  image: string;
}

export interface BlogCategoryGroup {
  name: string;
  categories: BlogCategory[];
}

export const blogCategoryGroups: BlogCategoryGroup[] = [
  {
    name: "Mental & Cognitive",
    categories: [
      { name: "psychology", image: "/assets/categories/psychology.jpg" },
      { name: "neurology", image: "/assets/categories/neurology.jpg" },
      { name: "cognitive science", image: "/assets/categories/cognitive-science.jpg" },
      { name: "behavioral science", image: "/assets/categories/behavioral-science.jpg" },
      { name: "identity", image: "/assets/categories/identity.jpg" },
      { name: "habit formation", image: "/assets/categories/habit-formation.jpg" },
      { name: "self-discipline", image: "/assets/categories/self-discipline.jpg" },
    ],
  },
  {
    name: "Spiritual & Transpersonal",
    categories: [
      { name: "spirituality", image: "/assets/categories/spirituality.jpg" },
      { name: "metaphysics", image: "/assets/categories/metaphysics.jpg" },
      { name: "consciousness studies", image: "/assets/categories/consciousness-studies.jpg" },
      { name: "shadow work", image: "/assets/categories/shadow-work.jpg" },
      { name: "archetypes", image: "/assets/categories/archetypes.jpg" },
      { name: "ritual", image: "/assets/categories/ritual.jpg" },
      { name: "alchemy", image: "/assets/categories/alchemy.jpg" },
      { name: "dreamwork", image: "/assets/categories/dreamwork.jpg" },
    ],
  },
  {
    name: "Body & Embodiment",
    categories: [
      { name: "meditation", image: "/assets/categories/meditation.jpg" },
      { name: "breathwork", image: "/assets/categories/breathwork.jpg" },
      { name: "somatics", image: "/assets/categories/somatics.jpg" },
      { name: "healing", image: "/assets/categories/healing.jpg" },
    ],
  },
  {
    name: "Philosophical & Reflective",
    categories: [
      { name: "philosophy", image: "/assets/categories/philosophy.jpg" },
      { name: "existentialism", image: "/assets/categories/existentialism.jpg" },
      { name: "ethics", image: "/assets/categories/ethics.jpg" },
      { name: "symbolism", image: "/assets/categories/symbolism.jpg" },
      { name: "journaling", image: "/assets/categories/journaling.jpg" },
      { name: "downloads", image: "/assets/categories/downloads.jpg" },
      { name: "synapse", image: "/assets/categories/synapse.jpg" },
    ],
  },
  {
    name: "Systems & External",
    categories: [
      { name: "systems thinking", image: "/assets/categories/systems-thinking.jpg" },
      { name: "technology", image: "/assets/categories/technology.jpg" },
      { name: "information theory", image: "/assets/categories/information-theory.jpg" },
    ],
  },
];
