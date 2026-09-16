# Selected vocabulary

- Change: angelscript/feature-testcode-language-fixtures (Q110).
- Author root: AngelscriptTestCode/Language; exact FileTags are in the accepted inventory (Q106).
- Themes: Operators, ControlFlow, Casting, Namespace, Syntax, Preprocessor; Const is Syntax/Const.
- Containers use grammar v1; generated C++ uses the existing structured format=v2 carrier. These are different version identifiers.
- Version tags: root; valid-<legacy-scenario-kebab-name>; invalid-<legacy-scenario-kebab-name>. Every non-root version has parent root. Syntax/StructFields additionally uses the explicit add-field version for integration coverage.
- Topics: Language and the theme at file level; Baseline for root, Negative for rejected variants, SourceOnly for lexical-only material; Fields on StructFields/add-field.
- Integration script type: FStructFields with X/Y and child Z, derived from the inspected FStructBasic/FMemberDefaults fixture convention.
- New CQTest class: LanguageFixtureCorpus in Angelscript.UnitTest.Framework, with AllFilesAndVersionsAreAdmitted; existing GeneratedSources and Adoption identities remain.
- Read-only planning/implementation verifier: attachments/scripts/verify-fixture.py, using existing CodeGenTool APIs, not a new production CLI.
