// Theme: Gameplay.FTransform. Positive Equals oracles.
// C++: AngelscriptCoverageFTransformExpressionTests.cpp::TransformComparison
// Oracle: CompareIdentity true; CompareEqual true; CompareNotEqual false.
// Extra: default Identity equals; Identity vs location false. DefaultSafe.

bool CompareIdentity()
{
	FTransform A = FTransform::Identity;
	FTransform B = FTransform::Identity;
	return A.Equals(B);
}

bool CompareEqual()
{
	FTransform A = FTransform(FVector(100, 200, 300));
	FTransform B = FTransform(FVector(100, 200, 300));
	return A.Equals(B);
}

bool CompareNotEqual()
{
	FTransform A = FTransform(FVector(100, 200, 300));
	FTransform B = FTransform(FVector(400, 500, 600));
	return A.Equals(B);
}

bool Observe_CompareIdentity()
{
	return CompareIdentity() == true;
}

bool Observe_CompareEqual()
{
	return CompareEqual() == true;
}

bool Observe_CompareNotEqual()
{
	return CompareNotEqual() == false;
}

bool Observe_CompareIdentity_DefaultEmpty()
{
	return FTransform().Equals(FTransform::Identity) == true;
}

bool Observe_CompareNotEqual_IdentityBoundary()
{
	return FTransform(FVector(100, 200, 300)).Equals(FTransform::Identity) == false;
}
