// Theme: Language.Syntax.EdgeCases. Positive FQuat &in GetAxisX.
// C++: AngelscriptCoverageFQuatFunctionTests.cpp::FunctionParametersIn
// sha256=cc2c557820a8df136bc294d5f7d1e98590ff94f31fd55272b609add23a9018fc; lines 99-104.
// Oracle: AcceptQuatIn(yaw 90) equals GetAxisX of that quat. Extra: Identity axis is Forward.
// DefaultSafe. &in does not mutate the caller.

FVector AcceptQuatIn(FQuat&in q)
{
	return q.GetAxisX();
}

bool Observe_AcceptQuatIn_Nominal()
{
	FQuat Input = FQuat(FRotator(0, 90, 0));
	return AcceptQuatIn(Input).Equals(Input.GetAxisX(), 0.01);
}

bool Observe_AcceptQuatIn_IdentityEmpty()
{
	FQuat Identity = FQuat::Identity;
	return AcceptQuatIn(Identity).Equals(FVector::ForwardVector, 0.01);
}

bool Observe_AcceptQuatIn_CopyIndependence()
{
	FQuat Input = FQuat(FRotator(0, 90, 0));
	FQuat Before = Input;
	FVector Axis = AcceptQuatIn(Input);
	return Input.Equals(Before, 0.001) && Axis.Equals(Before.GetAxisX(), 0.01);
}
