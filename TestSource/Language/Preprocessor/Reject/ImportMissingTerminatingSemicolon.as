/**
 * An import statement must end with a semicolon. Omitting it is a syntax error
 * reported at the import row. This file is the illegal program itself; do not
 * add the semicolon or extra declarations, since the missing terminator is the
 * point.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.ImportMissingTerminatingSemicolon
 * @Harness CompileReject
 * @Tag Language.Preprocessor.ImportMissingTerminatingSemicolon
 * @Kind CompileReject
 * @Covers Preprocessor.Imports
 * @Inputs an import statement with no terminating ';'
 * @Return does not preprocess; diagnostic "Import statement is missing terminating ';'."
 * @Provenance C++: AngelscriptPreprocessorImportTests.cpp::MissingSemicolonReportsSyntax block 2
 * @Provenance sha256=81311b0280effe7c666e85a13f3a9ec3e81139c0aaff58e971050082ba39280c; lines 195-201.
 * @Provenance Expected diagnostic: "Import statement is missing terminating ';'." at row 1 (count 1).
 * @Provenance DiagnosticOnly. Do not add the semicolon or extra declarations that would compile this away.
 */

import Tests.Preprocessor.MissingSemicolon.Shared

/**
 * Uses the imported module. It never runs, since the malformed import is
 * rejected first.
 *
 * @Covers Preprocessor.Imports
 * @Inputs the imported module's SharedValue
 * @Return the imported value, never reached
 */
int UseShared()
{
	return SharedValue();
}
