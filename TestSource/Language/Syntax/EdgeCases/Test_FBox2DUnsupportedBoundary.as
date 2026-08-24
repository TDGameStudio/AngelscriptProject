// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: FBox2D is not on the AS surface.
// C++: AngelscriptCoverageMathGeometricStructs.cpp::FBox2DUnsupportedBoundary CompileAndExpectFailure
// sha256=c030d0c88aee2ed02c3c8b5b530c6e396068887d6caa2f3fb488b045ea483890; lines 1377-1383.
// Expected diagnostic contains "FBox2D".
// Isolate this failing program; do not add declarations that would compile it away.
// DiagnosticOnly.

bool TriggerUnsupportedFBox2D()
{
	FBox2D Box = FBox2D(FVector2D(0, 0), FVector2D(100, 100));
	return Box.IsInside(FVector2D(50, 50));
}
