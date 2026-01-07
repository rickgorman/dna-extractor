# DNA Extractor

Extract codebase DNA for AI assistants.

## Usage

```
/dna-extractor <path-to-project|url-to-repo>
```

## Options

```
--level=snapshot|skeleton|standard|comprehensive
--output=<filename>
--help
```

## Output

Two files in cwd:
- `PROJECT_DNA.md` - initial extraction
- `PROJECT_DNA_REFINED.md` - after 5 refinement passes
