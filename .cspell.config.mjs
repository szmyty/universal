import { defineConfig } from 'cspell';
import { dirname, resolve } from 'path';
import { fileURLToPath } from 'url';

// Timestamp for unique report filenames
const utcTimestamp = Math.floor(Date.now() / 1000);

function getProjectRoot() {
    // __dirname is not available in ES modules, so use fileURLToPath
    const currentFile = fileURLToPath(import.meta.url);
    // The config file is at the project root
    return dirname(currentFile);
}

const dictionariesDir = resolve(getProjectRoot(), '.vscode/dictionaries');

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
        '/project-words.txt',
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
                "outFile": `reports/cspell/cspell-report-${utcTimestamp}.json`
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
            addWords: false,
        },
        {
            name: "devops-cloud-terms",
            path: resolve(dictionariesDir, "devops-cloud-terms.dictionary"),
            addWords: false,
        },
        {
            name: "frontend-terms",
            path: resolve(dictionariesDir, "frontend-terms.dictionary"),
            addWords: false,
        },
        {
            name: "programming-terms",
            path: resolve(dictionariesDir, "programming-terms.dictionary"),
            addWords: false,
        },
        {
            name: "software-terms",
            path: resolve(dictionariesDir, "software-terms.dictionary"),
            addWords: false,
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
        cacheLocation: "./.cache/cspell",
        cacheStrategy: "content",
        cacheFormat: "universal"
    },
    failFast: true,
    loadDefaultConfiguration: true,
});
