/**
 * A function whose return statement carries no expression is rejected, and the
 * compiler's paired End compilation event fires on that failure. This file is the
 * illegal program itself; do not supply a return value, since the missing
 * expression is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FailedCompileEmitsPairedEndEvent
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.FailedCompileEmitsPairedEndEvent
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a return statement with an empty expression
 * @Return does not compile; diagnostic "invalid script / missing return expression"
 * @Provenance C++: AngelscriptCompilerEventsTests.cpp::FailedCompileEmitsPairedEndEvent
 * @Provenance sha256=584d8a3986162cc68ca19d062e81bda2db3929b7042de671e030cc3f6d29175c; lines 580-585.
 * @Provenance Expected diagnostic: invalid script / missing return expression so the module
 * @Provenance does not compile (bCompiled false, ECompileResult::Error). Isolate this
 * @Provenance failing program; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

/**
 * A function returning nothing despite declaring an int return type.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
int Entry()
{
	return ;
}
