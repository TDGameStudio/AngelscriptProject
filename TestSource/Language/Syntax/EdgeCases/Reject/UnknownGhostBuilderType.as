/**
 * A builder integration compile referencing an undeclared GhostBuilderType is
 * rejected. This file is the illegal program itself; do not declare the missing
 * type, since the unknown name is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.UnknownGhostBuilderType
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.UnknownGhostBuilderType
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a local typed with the undeclared GhostBuilderType
 * @Return does not compile; diagnostic contains "GhostBuilderType"
 * @Provenance C++: AngelscriptCompilerBuilderIntegrationTests.cpp::RuntimeCompileFailureReportsBuilderDiagnostics
 * @Provenance sha256=7cbc0d3b7ac436f0e8f4506c8153a7b9565f3f124cb18467fa3a86f7d04d105b; lines 178-184.
 * @Provenance Expected diagnostic contains "GhostBuilderType"; compile result Error, end event failed.
 * @Provenance DiagnosticOnly. Do not add declarations that would compile this away.
 */

/**
 * The function whose local references the undeclared type.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
int Entry()
{
	GhostBuilderType Value;
	return 42;
}
