// Theme: Gameplay.FQuat. Positive Inverse / GetNormalized / flags.
// C++: AngelscriptCoverageFQuatExpressionTests.cpp::QuatInverseAndNormalize
// Oracle: Inverse of yaw-90; GetNormalized of (0.1,0.2,0.3,0.9);
// IsNormalized Identity true; IsIdentityQuat true.
// Extra: default Identity flags; unnormalized IsNormalized false. DefaultSafe.

FQuat InverseQuat()
{
	FQuat q = FQuat(FRotator(0, 90, 0));
	return q.Inverse();
}

FQuat NormalizeQuat()
{
	FQuat q = FQuat(0.1, 0.2, 0.3, 0.9);
	return q.GetNormalized();
}

bool IsNormalized()
{
	FQuat q = FQuat::Identity;
	return q.IsNormalized();
}

bool IsIdentityQuat()
{
	FQuat q = FQuat::Identity;
	return q.IsIdentity();
}

bool Observe_InverseQuat()
{
	FQuat q = FQuat(FRotator(0, 90, 0));
	return InverseQuat().Equals(q.Inverse(), 0.01);
}

bool Observe_NormalizeQuat()
{
	FQuat q = FQuat(0.1, 0.2, 0.3, 0.9);
	return NormalizeQuat().Equals(q.GetNormalized(), 0.01);
}

bool Observe_IsNormalized()
{
	return IsNormalized() == true;
}

bool Observe_IsIdentityQuat()
{
	return IsIdentityQuat() == true;
}

bool Observe_IsIdentityQuat_DefaultEmpty()
{
	return FQuat().IsIdentity() == true && FQuat().IsNormalized() == true;
}

bool Observe_IsNormalized_UnnormalizedBoundary()
{
	FQuat Inflated = FQuat(0.1, 0.2, 0.3, 0.9);
	return Inflated.IsNormalized() == false;
}
