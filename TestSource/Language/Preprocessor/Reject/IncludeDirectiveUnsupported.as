/**
 * The #include directive is not supported by this fork's preprocessor; imports
 * replace it. Using #include is rejected. This file is the illegal program
 * itself; do not rewrite the directive as an import, since the unsupported
 * directive is the point.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.IncludeDirectiveUnsupported
 * @Harness CompileReject
 * @Tag Language.Preprocessor.IncludeDirectiveUnsupported
 * @Kind CompileReject
 * @Covers Preprocessor.Directives
 * @Inputs an #include directive naming a script file
 * @Return does not preprocess; diagnostic "Unsupported preprocessor directive '#include'."
 * @Provenance C++: AngelscriptCoveragePreprocessorTests.cpp::IncludeDirectiveReportsUnsupportedDiagnostic
 * @Provenance AssertPreprocessFailed; lines 309-315;
 * @Provenance sha256=cd2dd8df920476323ae38c27b1300aa96be41a9f59ae502ed630333525fda28d.
 * @Provenance Expected diagnostic: "Unsupported preprocessor directive '#include'. Use import or automatic imports instead."
 * @Provenance Do not replace #include with import.
 * @Provenance DiagnosticOnly.
 */

/**
 * The rejected directive: #include has no meaning in this fork, so the file
 * named by it is never pulled in.
 *
 * @Covers Preprocessor.Directives
 * @Inputs the file name "Shared.as"
 * @Return does not preprocess
 */
#include "Shared.as"

/**
 * A plain entry point following the rejected directive. It never runs, since
 * the directive is rejected first.
 *
 * @Covers Preprocessor.Directives
 * @Inputs none
 * @Return 1, never reached
 */
int Entry()
{
	return 1;
}
