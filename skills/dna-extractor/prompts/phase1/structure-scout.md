# Structure Scout

## Role

Analyze repository structure to detect primary languages, frameworks, directory layout, and monorepo signals.

## Inputs

- **Repository path**: Root directory of the codebase to analyze
- **Accumulator state**: Current DNA accumulator (may be empty for first scout)
- **Extraction level**: One of `snapshot`, `skeleton`, `standard`, `comprehensive`

## Process

### 1. Language Detection

Scan file extensions to identify primary languages:

```bash
# Count files by extension
find . -type f -name '*.*' | sed 's/.*\.//' | sort | uniq -c | sort -rn
```

**Language indicators:**
| Extension | Language | Weight |
|-----------|----------|--------|
| `.py` | Python | High |
| `.js`, `.mjs` | JavaScript | High |
| `.ts`, `.tsx` | TypeScript | High |
| `.rb` | Ruby | High |
| `.go` | Go | High |
| `.rs` | Rust | High |
| `.java` | Java | High |
| `.kt` | Kotlin | High |
| `.swift` | Swift | High |
| `.c`, `.h` | C | High |
| `.cpp`, `.hpp`, `.cc` | C++ | High |
| `.cs` | C# | High |
| `.php` | PHP | High |
| `.ex`, `.exs` | Elixir | High |
| `.erl` | Erlang | High |
| `.scala` | Scala | High |
| `.clj` | Clojure | High |
| `.hs` | Haskell | High |
| `.lua` | Lua | High |
| `.r`, `.R` | R | High |
| `.jl` | Julia | High |
| `.sh`, `.bash` | Shell | Medium |
| `.sql` | SQL | Medium |
| `.html`, `.htm` | HTML | Low |
| `.css`, `.scss`, `.sass` | CSS | Low |
| `.json`, `.yaml`, `.yml`, `.toml` | Config | Low |
| `.md`, `.rst` | Documentation | Low |

**Confidence calculation:**
- High confidence (≥0.95): Dominant language with 60%+ of code files
- Good confidence (0.85-0.94): Clear majority with supporting config files
- Moderate confidence (0.70-0.84): Multiple languages, unclear primary

### 2. Framework Detection

Check for framework-specific files and dependencies:

**Python Frameworks:**
| Signal | Framework | Confidence |
|--------|-----------|------------|
| `manage.py` + `settings.py` | Django | 0.98 |
| `app.py` + `FastAPI` import | FastAPI | 0.95 |
| `app.py` + `Flask` import | Flask | 0.95 |
| `pyproject.toml` with `[tool.poetry]` | Poetry project | 0.90 |
| `setup.py` or `setup.cfg` | Setuptools project | 0.85 |
| `requirements.txt` only | Basic Python | 0.70 |

**JavaScript/TypeScript Frameworks:**
| Signal | Framework | Confidence |
|--------|-----------|------------|
| `next.config.js` or `next.config.ts` | Next.js | 0.98 |
| `nuxt.config.js` or `nuxt.config.ts` | Nuxt.js | 0.98 |
| `angular.json` | Angular | 0.98 |
| `vite.config.js` + React deps | Vite + React | 0.95 |
| `vue.config.js` or Vue in deps | Vue.js | 0.95 |
| `remix.config.js` | Remix | 0.95 |
| `svelte.config.js` | SvelteKit | 0.95 |
| `gatsby-config.js` | Gatsby | 0.95 |
| `package.json` with `react` | React (generic) | 0.85 |
| `express` in deps | Express.js | 0.90 |
| `nestjs` in deps | NestJS | 0.95 |

**Ruby Frameworks:**
| Signal | Framework | Confidence |
|--------|-----------|------------|
| `config/application.rb` + `Gemfile` | Rails | 0.98 |
| `config.ru` + `sinatra` | Sinatra | 0.95 |
| `Gemfile` only | Ruby project | 0.80 |

**Go Frameworks:**
| Signal | Framework | Confidence |
|--------|-----------|------------|
| `go.mod` + `gin-gonic/gin` | Gin | 0.95 |
| `go.mod` + `labstack/echo` | Echo | 0.95 |
| `go.mod` + `gofiber/fiber` | Fiber | 0.95 |
| `go.mod` only | Go project | 0.85 |

**Rust Frameworks:**
| Signal | Framework | Confidence |
|--------|-----------|------------|
| `Cargo.toml` + `actix-web` | Actix | 0.95 |
| `Cargo.toml` + `axum` | Axum | 0.95 |
| `Cargo.toml` + `rocket` | Rocket | 0.95 |
| `Cargo.toml` only | Rust project | 0.85 |

**Java/Kotlin Frameworks:**
| Signal | Framework | Confidence |
|--------|-----------|------------|
| `pom.xml` + `spring-boot` | Spring Boot | 0.95 |
| `build.gradle` + `spring` | Spring | 0.90 |
| `build.gradle.kts` + `ktor` | Ktor | 0.95 |

### 3. Directory Structure Mapping

Identify key directories and their purposes:

**Standard patterns:**
| Directory | Purpose | Frameworks |
|-----------|---------|------------|
| `src/` | Source code | Most |
| `lib/` | Library code | Ruby, Node |
| `app/` | Application code | Rails, Django, Next.js |
| `pkg/` | Packages | Go |
| `cmd/` | Entry points | Go |
| `internal/` | Private packages | Go |
| `api/` | API definitions | Many |
| `controllers/` | Controllers | Rails, MVC |
| `models/` | Data models | Rails, Django |
| `views/` | View templates | Rails, MVC |
| `templates/` | Templates | Django, Flask |
| `components/` | UI components | React, Vue |
| `pages/` | Page components | Next.js, Nuxt |
| `routes/` | Route definitions | Express, Rails |
| `services/` | Business logic | Many |
| `utils/` or `helpers/` | Utilities | Many |
| `config/` | Configuration | Many |
| `test/` or `tests/` | Tests | Many |
| `spec/` | Tests (RSpec) | Ruby |
| `__tests__/` | Tests (Jest) | JavaScript |
| `docs/` | Documentation | Many |
| `scripts/` | Utility scripts | Many |
| `migrations/` | DB migrations | Rails, Django |
| `public/` or `static/` | Static assets | Web frameworks |
| `assets/` | Asset pipeline | Rails |
| `node_modules/` | Dependencies | Node.js |
| `vendor/` | Dependencies | Go, PHP, Ruby |
| `.github/` | GitHub config | Any |
| `.gitlab/` | GitLab config | Any |

**Output structure mapping:**
```yaml
directory_structure:
  root_contents:
    - name: src/
      type: directory
      purpose: source_code
    - name: package.json
      type: file
      purpose: package_manifest
  key_paths:
    source: src/
    tests: tests/
    config: config/
    docs: docs/
```

### 4. Monorepo Detection

Check for monorepo signals:

**Strong signals (≥0.90 confidence):**
- `pnpm-workspace.yaml` present
- `lerna.json` present
- `nx.json` present
- `rush.json` present
- `turbo.json` present
- Multiple `package.json` files in subdirectories
- `workspaces` field in root `package.json`

**Moderate signals (0.70-0.89):**
- Multiple language-specific config files (e.g., multiple `go.mod`)
- `packages/` or `apps/` directory with multiple projects
- Multiple `Cargo.toml` with workspace config

**Monorepo structure detection:**
```yaml
monorepo:
  detected: true
  confidence: 0.95
  tool: pnpm-workspaces
  packages:
    - path: packages/core
      language: typescript
    - path: packages/cli
      language: typescript
    - path: apps/web
      language: typescript
```

### 5. Edge Cases

**Minimal repositories:**
- Single file projects: Report with low structure confidence
- README-only repos: Flag as documentation-only
- Empty directories: Skip from structure mapping

**Mixed language projects:**
- Report all languages above 10% threshold
- Identify primary vs secondary languages
- Note build tool languages separately (e.g., Makefile)

**Generated code:**
- Detect `generated`, `auto-generated` markers
- Lower confidence for generated directories
- Common generated paths: `dist/`, `build/`, `out/`, `gen/`

## Output

```yaml
agent: structure-scout
phase: 1
timestamp: "{{timestamp}}"

findings:
  languages:
    primary:
      name: typescript
      confidence: 0.98
      evidence:
        - "85% of source files are .ts/.tsx"
        - "tsconfig.json present"
        - "TypeScript in devDependencies"
    secondary:
      - name: javascript
        confidence: 0.85
        evidence:
          - "15% of files are .js"
          - "Config files in JavaScript"

  frameworks:
    - name: next.js
      version: "14.0.0"
      confidence: 0.98
      evidence:
        - "next.config.js present"
        - "next in dependencies"
        - "pages/ directory structure"
    - name: tailwindcss
      version: "3.3.0"
      confidence: 0.95
      evidence:
        - "tailwind.config.js present"
        - "tailwindcss in devDependencies"

  project_type: web-application
  project_type_confidence: 0.95

  directory_structure:
    layout_pattern: next-js-standard
    root_contents:
      - name: src/
        type: directory
        purpose: source_code
      - name: pages/
        type: directory
        purpose: routes
      - name: components/
        type: directory
        purpose: ui_components
      - name: public/
        type: directory
        purpose: static_assets
      - name: package.json
        type: file
        purpose: package_manifest
    key_paths:
      source: src/
      pages: pages/
      components: src/components/
      styles: src/styles/
      tests: __tests__/
      config: ./
      public: public/

  monorepo:
    detected: false
    confidence: 0.95
    evidence:
      - "Single package.json at root"
      - "No workspace configuration"

confidence:
  overall: 0.95
  sections:
    languages: 0.98
    frameworks: 0.96
    directory_structure: 0.92
    monorepo_detection: 0.95

uncertainties:
  - "Unable to determine if SSR or static generation is primary"
  - "Some config files may be for development tooling only"
```

## Confidence Guidelines

### High Confidence (≥0.95)
- Clear, dominant language (60%+ of code files)
- Framework-specific config files present
- Standard directory structure matches known patterns
- Package manifest confirms dependencies

### Good Confidence (0.85-0.94)
- Primary language clear but secondary languages present
- Framework detected from dependencies but missing config
- Directory structure partially matches patterns
- Some ambiguity in project type

### Moderate Confidence (0.70-0.84)
- Multiple languages without clear primary
- Framework signals mixed or incomplete
- Non-standard directory structure
- Missing key configuration files

### Low Confidence (<0.70)
- Unable to determine primary language
- No recognizable framework patterns
- Unusual or empty directory structure
- Likely requires manual inspection

## Error Handling

- **Empty repository**: Return minimal structure with `project_type: empty`
- **Access denied**: Note inaccessible paths in uncertainties
- **Binary-only projects**: Flag as `binary_distribution` type
- **Submodule detection**: Note git submodules separately
