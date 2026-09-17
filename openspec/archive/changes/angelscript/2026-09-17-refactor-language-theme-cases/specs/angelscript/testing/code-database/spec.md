## MODIFIED Requirements

### Requirement: Path identity and complete versions

The database SHALL identify files by root-relative slash-normalized Tag without .as and versions by an explicit per-file Tag, storing complete source without parent-based reconstruction. Zero or more versions MAY omit Parent. A VersionTag spelled `root` SHALL have no privilege.

#### Scenario: Read a sibling directly

- **GIVEN** Language/Counter has full bodies first=`int X=0;`, left=`int X=1;` and right=`int X=2;` and none of those versions names a Parent
- **WHEN** right is requested after left
- **THEN** right returns `int X=2;` without changing left

    File Version=v1 describes metadata format, not a source node. Parent and topic metadata do not schedule execution.

#### Scenario: Admit two parentless versions

- **GIVEN** a v1 container whose cases open with `@begin alpha` and `@begin beta` and neither header has `@parent`
- **WHEN** the file is parsed and built
- **THEN** both VersionTags are retrievable and neither is required to be named `root`

    > Observables: `Get(FileTag, "alpha")` and `Get(FileTag, "beta")` succeed.

    > Boundaries: a cycle or a Parent that names a missing VersionTag still fails construction.

### Requirement: Conforming independent fixture protocol parsers

The Python generated-source parser and retained C++ `FAngelscriptTestSourceParser` SHALL implement equivalent fixture metadata, version, annotation, clean-byte and authored-origin semantics without requiring generated translation units to invoke the C++ parser. Case identity SHALL be `@begin <tag>` for author files in this Change's grammar. Several versions MAY omit Parent.

#### Scenario: Compare parentless begin blocks

- **GIVEN** a shared fixture with two `@begin` cases, no `@parent`, one `@function` header, and one `@range-begin` / `@range-end` pair
- **WHEN** the Python parser and C++ parser process the same fixture bytes independently
- **THEN** they produce equal FileMeta, VersionMeta (including empty Parent), version ordering, clean bytes, Points, Breakpoints, half-open Ranges and original-byte mappings

    > Boundaries: compile-fail cases may omit `@function`. Unknown `@topic` words remain legal nonempty labels.
