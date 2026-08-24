// Theme: Language.Syntax.EdgeCases. Positive FQuat default Identity argument.
// C++: AngelscriptCoverageFQuatFunctionTests.cpp::FunctionDefaultParameters
// sha256=ffe1ddb0e01984bb0a1f5eadded2ca97c47794a209e249815a3ec82c1158783d; lines 269-279.
// Oracle: MultiplyWithDefault(45,45) equals a*b; MultiplyWithImplicitDefault(yaw 90) equals arg.
// Extra: Identity * Identity is Identity. DefaultSafe.

FQuat MultiplyWithDefault(FQuat a, FQuat b = FQuat::Identity)
{
	return a * b;
}

FQuat MultiplyWithImplicitDefault(FQuat a)
{
	return MultiplyWithDefault(a);
}

bool Observe_MultiplyWithDefault_Nominal()
{
	FQuat Arg1 = FQuat(FRotator(0, 45, 0));
	FQuat Arg2 = FQuat(FRotator(0, 45, 0));
	FQuat Yaw = FQuat(FRotator(0, 90, 0));
	return MultiplyWithDefault(Arg1, Arg2).Equals(Arg1 * Arg2, 0.01) && MultiplyWithImplicitDefault(Yaw).Equals(Yaw, 0.01);
}

bool Observe_MultiplyWithDefault_IdentityEmpty()
{
	return MultiplyWithImplicitDefault(FQuat::Identity).IsIdentity(0.001);
}

bool Observe_MultiplyWithDefault_ExplicitOverrideBoundary()
{
	FQuat Yaw = FQuat(FRotator(0, 90, 0));
	return MultiplyWithDefault(Yaw, FQuat::Identity).Equals(Yaw, 0.01) && !MultiplyWithDefault(Yaw, Yaw).Equals(Yaw, 0.01);
}
