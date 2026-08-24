// Theme: Language.Syntax.EdgeCases. Positive FQuat &inout Inverse.
// C++: AngelscriptCoverageFQuatFunctionTests.cpp::FunctionParametersInOut
// sha256=e1d4400e8882501989b49d3e554d199318f345884953ba05b2bfc4ebe0c6dd90; lines 179-184.
// Oracle: InverseQuat(yaw 90) equals that quat's Inverse. Extra: Identity stays Identity.
// DefaultSafe. &inout mutates caller storage.

void InverseQuat(FQuat&inout q)
{
	q = q.Inverse();
}

bool Observe_InverseQuat_Nominal()
{
	FQuat Value = FQuat(FRotator(0, 90, 0));
	FQuat Expected = Value.Inverse();
	InverseQuat(Value);
	return Value.Equals(Expected, 0.01);
}

bool Observe_InverseQuat_IdentityEmpty()
{
	FQuat Value = FQuat::Identity;
	InverseQuat(Value);
	return Value.IsIdentity(0.001);
}

bool Observe_InverseQuat_DoubleInverseBoundary()
{
	FQuat Original = FQuat(FRotator(0, 90, 0));
	FQuat Value = Original;
	InverseQuat(Value);
	InverseQuat(Value);
	return Value.Equals(Original, 0.01);
}
