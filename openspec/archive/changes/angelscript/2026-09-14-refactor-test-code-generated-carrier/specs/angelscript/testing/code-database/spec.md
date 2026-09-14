## RENAMED Requirements

- FROM: `### Requirement: Embedded original file delivery`
- TO: `### Requirement: Checked-in generated original file delivery`

## MODIFIED Requirements

### Requirement: Checked-in generated original file delivery

The database SHALL obtain authored source containers from deterministic checked-in C++ projections, with one mirrored projection per `.as` file, without runtime author-file fallback, Windows resource identifiers, or implicit generation during ordinary builds.

#### Scenario: Observe a synchronized inventory

- **GIVEN** the author root contains `Language/Counter.as`, the tool subtree may contain test-only `.as` files, and the generated root contains the last synchronized projections

    `CodeGenTool/**` is reserved implementation and test data. It never contributes public FileTags or generated translation units.

- **WHEN** an author runs read-only `check`, edits a source, and then explicitly runs `generate`

    The public commands are `python AngelscriptTestCode/CodeGenTool/codegen.py check` and `python AngelscriptTestCode/CodeGenTool/codegen.py generate`. They resolve repository paths from the tool location rather than the caller's current directory.

- **THEN** the generated root contains exactly one signed, mirrored `.generated.cpp` for each authored `.as`, preserving the authored bytes and extensionless root-relative FileTag

    `Language/Counter.as` becomes `TestCode/Generated/Language/Counter.generated.cpp` and registers `Language/Counter`. Equal projection content is not rewritten.

- **AND** the checked-in translation units register deferred factories through the shared database and parse their bytes only during central activation

    Handwritten C++ providers use the same `FAngelscriptTestCodeRegistration` and remain supported. Query consumers observe the same file/version identities, source bytes, annotations, and authored origin positions regardless of provider style.

- **BUT** missing, changed, stale, colliding, or unsafe output state is never reported as synchronized

    `check` returns failure without mutation. `generate` validates and renders the expected set before writing and deletes only stale signed `.generated.cpp` files beneath the dedicated generated root; other extra files are preserved and reported. Ordinary UBT never invokes Python or scans the author root.

