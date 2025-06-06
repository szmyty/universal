import { defineConfig } from 'cspell';
import { dirname, resolve } from 'path';
import { fileURLToPath } from 'url';

// Timestamp for unique report filenames
const utcTimestamp = Math.floor(Date.now() / 1000);

// Get the project root directory
function getProjectRoot() {
    // __dirname is not available in ES modules, so use fileURLToPath
    const currentFile = fileURLToPath(import.meta.url);
    // The config file is at the project root
    return dirname(currentFile);
}

// Directory where custom dictionaries are stored
const dictionariesDir = resolve(getProjectRoot(), '.vscode/dictionaries');

// Directory where reports will be saved
const reportsDir = resolve(getProjectRoot(), 'reports/cspell');

// Directory where cache will be stored
const cacheDir = resolve(getProjectRoot(), '.cache/cspell');

// Define the CSpell configuration
export default defineConfig({
    $schema: "https://raw.githubusercontent.com/streetsidesoftware/cspell/main/cspell.schema.json",
    version: '0.2',
    language: "en",
    name: "Project CSpell Configuration",
    description: "CSpell configuration for the project",
    enabled: true,
    allowCompoundWords: false,
    caseSensitive: false,
    userWords: ["cspell"],
    globRoot: '.',
    files: [
        "src/**/*.{ts,tsx,js,jsx,vue}",      // Frontend source
        "scripts/**/*.{ts,js,sh}",           // Utility scripts
        "tests/**/*.{ts,tsx,js,jsx}",        // Tests
        "**/*.{md,markdown}",                // Markdown
        "**/*.{json,yaml,yml}",              // Config files
        "**/*.{html,css,scss,less}",         // Web styles/templates
        ".github/**/*.{yml,yaml}",           // GitHub Actions
        "*.{md,json,yml}",                   // Root files
    ],
    enableGlobDot: true,
    ignorePaths: [
        `${dictionariesDir}/**/*.dictionary`, // Ignore custom dictionaries
        '/backend-terms.txt',
        '**/node_modules/**',
        '**/dist/**',
        '**/build/**',
        '**/.next/**',
        '**/.vercel/**',
        '**/.turbo/**',
        '**/coverage/**',
        '**/out/**',
        '**/tmp/**',
        '**/temp/**',
        '**/logs/**',
        '**/log/**',
        '**/vendor/**',
        '**/bower_components/**',
        "**/pnpm-lock.yaml"
    ],
    noConfigSearch: true,
    readonly: false,
    reporters: [
        [
            "@cspell/cspell-json-reporter", {
                "outFile": `${reportsDir}/cspell-report-${utcTimestamp}.json`
            }
        ]
    ],
    useGitignore: true,
    gitignoreRoot: [],
    validateDirectives: true,
    dictionaryDefinitions: [
        {
            name: "project-words",
            path: resolve(dictionariesDir, "project-words.dictionary"),
            addWords: true,
        },
        {
            name: "backend-terms",
            path: resolve(dictionariesDir, "backend-terms.dictionary"),
            addWords: true,
        },
        {
            name: "devops-cloud-terms",
            path: resolve(dictionariesDir, "devops-cloud-terms.dictionary"),
            addWords: true,
        },
        {
            name: "frontend-terms",
            path: resolve(dictionariesDir, "frontend-terms.dictionary"),
            addWords: true,
        },
        {
            name: "programming-terms",
            path: resolve(dictionariesDir, "programming-terms.dictionary"),
            addWords: true,
        },
        {
            name: "software-terms",
            path: resolve(dictionariesDir, "software-terms.dictionary"),
            addWords: true,
        },
    ],
    dictionaries: [
        "project-words",
        "backend-terms",
        "devops-cloud-terms",
        "frontend-terms",
        "programming-terms",
        "software-terms"
    ],
    cache: {
        useCache: true,
        cacheLocation: cacheDir,
        cacheStrategy: "content",
        cacheFormat: "universal"
    },
    failFast: true,
    loadDefaultConfiguration: true,
});
