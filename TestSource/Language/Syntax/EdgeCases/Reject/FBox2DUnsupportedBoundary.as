/**
 * FBox2D is not on the AngelScript binding surface, so any use of it is rejected.
 * This file is the illegal program itself; do not add declarations that would
 * compile it away, since the missing type is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FBox2DUnsupportedBoundary
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.FBox2DUnsupportedBoundary
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs the undeclared FBox2D type
 * @Return does not compile; diagnostic containing "FBox2D"
 * @Provenance C++: AngelscriptCoverageMathGeometricStructs.cpp::FBox2DUnsupportedBoundary CompileAndExpectFailure
 * @Provenance sha256=c030d0c88aee2ed02c3c8b5b530c6e396068887d6caa2f3fb488b045ea483890; lines 1377-1383.
 * @Provenance Expected diagnostic contains "FBox2D".
 * @Provenance Isolate this failing program; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

/**
 * Attempt to construct and query an FBox2D.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
bool TriggerUnsupportedFBox2D()
{
	FBox2D Box = FBox2D(FVector2D(0, 0), FVector2D(100, 100));
	return Box.IsInside(FVector2D(50, 50));
}
