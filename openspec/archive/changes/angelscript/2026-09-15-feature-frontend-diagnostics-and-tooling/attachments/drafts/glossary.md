# Accepted names and convention-derived planning names

English export of diagnostics-tooling-successor/glossary.md, source topic angelscript/diagnostic-engine. Names accepted 2026-09-14; N2, N1d, Q8 and N3.

| Role | Chosen | Rejected / reason |
|---|---|---|
| Phase diagnostic funnel | Diag | Report and Diagnose; N2 |
| RAII return object | asCDiagnostic | Builder, Result, Draft, Pending, Streaming, Emission, Active; N1d |
| Initial operator<< set | Argument / FixIt / RelatedRange / FStringView / int64 / bool | Note is excluded from the first slice; Q8 |
| Change ID | angelscript/feature-frontend-diagnostics-and-tooling | funnel-and-tooling and diagnostics-engine variants; N3 |
| Worker count | asSBuilderOptions::WorkerCount | Separate LexWorkerCount rejected; Q15 |
| Batch size | asSBuilderOptions::LexBatchSize = 4 | Derived during planning from existing PascalCase option fields under Q15's explicit convention delegation; minimum 1 |

Inherited names are preserved from the predecessor's accepted design: asSDiagnosticGroup, asCDiagnosticResult, asSDiagnosticOptions, asCDiagnosticRenderer, asCSourcePositionCodec, asSSourceEdit, asSDiagnosticFixAlternative, asCSourceEditApplier, asSCallAssessment, asSCandidateAssessment, asSAnalysisInputs, asCAnalysisResult, asCToolingSession, asCLanguageService and their named result/status types. They are planned outputs, not claims that the source already defines them.

New test class names DiagnosticProduction and ParallelLexPreprocess follow the inspected replacement CQTest convention under Angelscript.UnitTest.NativeEngine. Supporting public signatures and test file names follow the existing asC/asS/asE and *Tests.cpp conventions; the producing task owns each name. No new public phase directory is introduced.
