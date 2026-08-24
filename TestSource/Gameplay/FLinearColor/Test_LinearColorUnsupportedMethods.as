// Theme: Gameplay.FLinearColor. Isolated compile-fail: Desaturate is unbound.
// C++: AngelscriptCoverageFLinearColorExpressionTests.cpp::LinearColorUnsupportedMethods
// CompileAndExpectFailure fragment: No matching signatures to 'FLinearColor::Desaturate
// CSV NegativeDiagnostic. DiagnosticOnly. Do not drop TryDesaturate.

FLinearColor TryDesaturate()
{
	FLinearColor Color = FLinearColor::Red;
	return Color.Desaturate(0.5);
}
