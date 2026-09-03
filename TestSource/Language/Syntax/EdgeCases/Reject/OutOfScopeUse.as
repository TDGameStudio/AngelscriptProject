/**
 * Reading a local after its block has ended is rejected. This file is the illegal
 * program itself; do not hoist the declaration, since the scope exit is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.OutOfScopeUse
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.OutOfScopeUse
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a local read after its block closed
 * @Return does not compile; diagnostic "missing variable Inner"
 * @Provenance C++: AngelscriptCompilerModulePipelineTests.cpp::OutOfScopeUseRejected
 * @Provenance sha256=24537273dea1397e995a642000fcbb27180bceeadb28e8dc8fa0b2b08323ee50; lines 174-182.
 * @Provenance Expected diagnostic: missing variable Inner after the inner block ends.
 * @Provenance Isolate this failing program; do not add declarations that would compile it
 * @Provenance away. DiagnosticOnly.
 */

/**
 * The function reading a variable whose block has closed.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
int Entry()
{
	{
		int Inner = 2;
	}
	return Inner;
}
