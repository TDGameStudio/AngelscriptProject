// Theme: World.Actor. WorldStory: FRotator/FQuat factories and FTransform Blend/SetRotation.
// C++: AngelscriptMathOrientationFunctionLibraryTests.cpp::FactoriesAndTransformMutators
// Oracle: ExecuteAndExtractStruct on each Get* matches native MakeFromAxes / Compose /
// AngularDistance / MakeFromX..ZY / Blend / BlendWith / SetRotation.
// Extra: empty AngularDistance(0,0)==0; Blend alpha 0 keeps A; member vs free axes copy-independence.
// FixtureIsolated.

FRotator GetAxesRotator()
{
	return FRotator::MakeFromAxes(FVector(1.0f, 0.0f, 0.0f), FVector(0.0f, 1.0f, 0.0f), FVector(0.0f, 0.0f, 1.0f));
}

FVector GetAxesForward()
{
	return GetAxesRotator().GetForwardVector();
}

FVector GetAxesForwardMember()
{
	const FRotator Rotator = GetAxesRotator();
	return Rotator.GetForwardVector();
}

FVector GetAxesRight()
{
	return GetAxesRotator().GetRightVector();
}

FVector GetAxesRightMember()
{
	const FRotator Rotator = GetAxesRotator();
	return Rotator.GetRightVector();
}

FVector GetAxesUp()
{
	return GetAxesRotator().GetUpVector();
}

FVector GetAxesUpMember()
{
	const FRotator Rotator = GetAxesRotator();
	return Rotator.GetUpVector();
}

FRotator GetComposedRotator()
{
	const FRotator A = FRotator(0.0f, 90.0f, 0.0f);
	const FRotator B = FRotator(45.0f, 0.0f, 0.0f);
	return A.Compose(B);
}

double GetRotatorAngularDistance()
{
	const FRotator A = FRotator(0.0f, 0.0f, 0.0f);
	const FRotator B = FRotator(0.0f, 90.0f, 0.0f);
	return A.AngularDistance(B);
}

FQuat GetQuatFromX()
{
	return FQuat::MakeFromX(FVector(1.0f, 1.0f, 0.0f));
}

FQuat GetQuatFromY()
{
	return FQuat::MakeFromY(FVector(-1.0f, 1.0f, 0.0f));
}

FQuat GetQuatFromZ()
{
	return FQuat::MakeFromZ(FVector(0.0f, 0.0f, 1.0f));
}

FQuat GetQuatFromXY()
{
	return FQuat::MakeFromXY(FVector(1.0f, 1.0f, 0.0f), FVector(-1.0f, 1.0f, 0.0f));
}

FQuat GetQuatFromXZ()
{
	return FQuat::MakeFromXZ(FVector(1.0f, 1.0f, 0.0f), FVector(0.0f, 0.0f, 1.0f));
}

FQuat GetQuatFromYX()
{
	return FQuat::MakeFromYX(FVector(-1.0f, 1.0f, 0.0f), FVector(1.0f, 1.0f, 0.0f));
}

FQuat GetQuatFromYZ()
{
	return FQuat::MakeFromYZ(FVector(-1.0f, 1.0f, 0.0f), FVector(0.0f, 0.0f, 1.0f));
}

FQuat GetQuatFromZX()
{
	return FQuat::MakeFromZX(FVector(0.0f, 0.0f, 1.0f), FVector(1.0f, 1.0f, 0.0f));
}

FQuat GetQuatFromZY()
{
	return FQuat::MakeFromZY(FVector(0.0f, 0.0f, 1.0f), FVector(-1.0f, 1.0f, 0.0f));
}

FTransform GetBlendTransform()
{
	FTransform Result;
	const FTransform A = FTransform(FRotator(10.0f, 20.0f, 30.0f), FVector(100.0f, -50.0f, 25.0f), FVector(1.25f, 0.75f, 2.0f));
	const FTransform B = FTransform(FRotator(-20.0f, 70.0f, 10.0f), FVector(-40.0f, 80.0f, 5.0f), FVector(0.5f, 1.5f, 1.0f));
	Result.Blend(A, B, 0.25f);
	return Result;
}

FTransform GetBlendWithTransform()
{
	FTransform Result = FTransform(FRotator(10.0f, 20.0f, 30.0f), FVector(100.0f, -50.0f, 25.0f), FVector(1.25f, 0.75f, 2.0f));
	const FTransform Other = FTransform(FRotator(-20.0f, 70.0f, 10.0f), FVector(-40.0f, 80.0f, 5.0f), FVector(0.5f, 1.5f, 1.0f));
	Result.BlendWith(Other, 0.5f);
	return Result;
}

FTransform GetSetRotationTransform()
{
	FTransform Result = FTransform(FRotator(10.0f, 20.0f, 30.0f), FVector(100.0f, -50.0f, 25.0f), FVector(1.25f, 0.75f, 2.0f));
	Result.SetRotation(FRotator(-30.0f, 15.0f, 45.0f));
	return Result;
}

double Observe_AngularDistance_EmptyZero()
{
	const FRotator Empty = FRotator(0.0f, 0.0f, 0.0f);
	return Empty.AngularDistance(Empty);
}

bool Observe_AxesMemberCopyIndependence()
{
	return GetAxesForward().Equals(GetAxesForwardMember())
		&& GetAxesRight().Equals(GetAxesRightMember())
		&& GetAxesUp().Equals(GetAxesUpMember());
}

FTransform Observe_Blend_ZeroAlphaKeepsA()
{
	FTransform Result;
	const FTransform A = FTransform(FRotator(10.0f, 20.0f, 30.0f), FVector(100.0f, -50.0f, 25.0f), FVector(1.25f, 0.75f, 2.0f));
	const FTransform B = FTransform(FRotator(-20.0f, 70.0f, 10.0f), FVector(-40.0f, 80.0f, 5.0f), FVector(0.5f, 1.5f, 1.0f));
	Result.Blend(A, B, 0.0f);
	return Result;
}
