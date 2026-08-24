// Theme: Gameplay.FRotator. Isolated compile-fail: unary negate is unbound.
// C++: AngelscriptCoverageFRotatorExpressionTests.cpp::RotatorUnsupportedOperators
// CompileAndExpectFailure fragment: Function 'opNeg()' not found
// CSV NegativeDiagnostic. DiagnosticOnly. Do not drop TryNegate.

FRotator TryNegate()
{
	FRotator Rotator = FRotator(10, 20, 30);
	return -Rotator;
}
