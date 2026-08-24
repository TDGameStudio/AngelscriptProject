// Theme: Language.Syntax.EdgeCases. Positive FQuat &out writeback.
// C++: AngelscriptCoverageFQuatFunctionTests.cpp::FunctionParametersOut
// sha256=a695921cf3345581ede198b8b414dd8745ad2a8fbe919dd145b01de23256ef6e; lines 132-143.
// Oracle: WriteQuat yields FQuat(FRotator(0,90,0)); WriteMultipleQuats A=Identity B=pitch 45.
// Extra: &out overwrites prior storage. DefaultSafe.

void WriteQuat(FQuat&out q)
{
	q = FQuat(FRotator(0, 90, 0));
}

void WriteMultipleQuats(FQuat&out a, FQuat&out b)
{
	a = FQuat::Identity;
	b = FQuat(FRotator(45, 0, 0));
}

bool Observe_WriteQuat_Nominal()
{
	FQuat Q;
	WriteQuat(Q);
	FQuat A;
	FQuat B;
	WriteMultipleQuats(A, B);
	return Q.Equals(FQuat(FRotator(0, 90, 0)), 0.01) && A.Equals(FQuat::Identity, 0.001) && B.Equals(FQuat(FRotator(45, 0, 0)), 0.01);
}

bool Observe_WriteQuat_OverwritesPrior()
{
	FQuat Q = FQuat::Identity;
	WriteQuat(Q);
	return Q.Equals(FQuat(FRotator(0, 90, 0)), 0.01) && !Q.IsIdentity(0.001);
}

bool Observe_WriteMultipleQuats_IdentityThenPitch()
{
	FQuat A = FQuat(FRotator(0, 90, 0));
	FQuat B = FQuat::Identity;
	WriteMultipleQuats(A, B);
	return A.IsIdentity(0.001) && B.Equals(FQuat(FRotator(45, 0, 0)), 0.01);
}
