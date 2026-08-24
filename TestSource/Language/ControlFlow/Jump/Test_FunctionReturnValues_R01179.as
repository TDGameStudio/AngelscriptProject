// Theme: Language.ControlFlow.Jump. Positive value oracle from FunctionReturnValues.
// C++: AngelscriptCoverageFQuatFunctionTests.cpp::FunctionReturnValues
// sha256=35e7acf576555d2970153dab5977e386e059d6bfe913c2eb2b37df9df5e6979d; lines 211-228.
// Oracle: ReturnIdentity equals FQuat::Identity (0.001); ReturnCustomQuat equals FQuat(FRotator(0,90,0)) (0.01);
// ReturnComputedQuat equals two 45-yaw products (0.01).
// Extra: custom yaw is not Identity; two 45-yaw products match 90-yaw.
// DefaultSafe. Source owns locals.

FQuat ReturnIdentity()
{
	return FQuat::Identity;
}

FQuat ReturnCustomQuat()
{
	return FQuat(FRotator(0, 90, 0));
}

FQuat ReturnComputedQuat()
{
	FQuat a = FQuat(FRotator(0, 45, 0));
	FQuat b = FQuat(FRotator(0, 45, 0));
	return a * b;
}

bool Observe_QuatReturnValues_Nominal()
{
	FQuat ExpectedCustom = FQuat(FRotator(0, 90, 0));
	FQuat ExpectedComputed = FQuat(FRotator(0, 45, 0)) * FQuat(FRotator(0, 45, 0));
	return ReturnIdentity().Equals(FQuat::Identity, 0.001)
		&& ReturnCustomQuat().Equals(ExpectedCustom, 0.01)
		&& ReturnComputedQuat().Equals(ExpectedComputed, 0.01);
}

bool Observe_QuatReturnValues_IdentityDefault()
{
	return ReturnIdentity().Equals(FQuat::Identity, 0.001)
		&& !ReturnCustomQuat().Equals(FQuat::Identity, 0.01);
}

bool Observe_QuatReturnValues_CompositionBoundary()
{
	return ReturnComputedQuat().Equals(ReturnCustomQuat(), 0.01);
}
