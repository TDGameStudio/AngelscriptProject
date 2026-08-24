// Theme: Language.Syntax.EdgeCases. Positive FQuat value parameters.
// C++: AngelscriptCoverageFQuatFunctionTests.cpp::FunctionParametersValue
// sha256=5d6e10316313aeb3c5ae53c6f52b1910070cd98e540b7f6e7e3617a220490fb6; lines 51-61.
// Oracle: AcceptQuat(yaw 90) equals Inverse; AcceptTwoQuats(45,45) equals a*b.
// Extra: Identity inverse is Identity; value args are copy-independent. DefaultSafe.

FQuat AcceptQuat(FQuat q)
{
	return q.Inverse();
}

FQuat AcceptTwoQuats(FQuat a, FQuat b)
{
	return a * b;
}

bool Observe_AcceptQuat_Nominal()
{
	FQuat Input = FQuat(FRotator(0, 90, 0));
	FQuat A = FQuat(FRotator(0, 45, 0));
	FQuat B = FQuat(FRotator(0, 45, 0));
	return AcceptQuat(Input).Equals(Input.Inverse(), 0.01) && AcceptTwoQuats(A, B).Equals(A * B, 0.01);
}

bool Observe_AcceptQuat_IdentityEmpty()
{
	return AcceptQuat(FQuat::Identity).IsIdentity(0.001) && AcceptTwoQuats(FQuat::Identity, FQuat::Identity).IsIdentity(0.001);
}

bool Observe_AcceptQuat_CopyIndependence()
{
	FQuat Input = FQuat(FRotator(0, 90, 0));
	FQuat Before = Input;
	FQuat Result = AcceptQuat(Input);
	return Input.Equals(Before, 0.001) && Result.Equals(Before.Inverse(), 0.01);
}
