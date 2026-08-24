// Theme: Gameplay.FQuat. Positive Rotator / Euler / axis conversion oracles.
// C++: AngelscriptCoverageFQuatExpressionTests.cpp::QuatConversionMethods
// Oracle: QuatToRotator (0,90,0); QuatEuler native Euler of (10,20,30);
// GetAxisX Forward; GetAxisY Right; GetAxisZ Up.
// Extra: Identity rotator ZeroRotator; copy independence of Euler source. DefaultSafe.

FRotator QuatToRotator()
{
	FQuat q = FQuat(FRotator(0, 90, 0));
	return q.Rotator();
}

FVector QuatEuler()
{
	FQuat q = FQuat(FRotator(10, 20, 30));
	return q.Euler();
}

FVector GetForwardAxis()
{
	FQuat q = FQuat(FRotator(0, 0, 0));
	return q.GetAxisX();
}

FVector GetRightAxis()
{
	FQuat q = FQuat(FRotator(0, 0, 0));
	return q.GetAxisY();
}

FVector GetUpAxis()
{
	FQuat q = FQuat(FRotator(0, 0, 0));
	return q.GetAxisZ();
}

bool Observe_QuatToRotator()
{
	return QuatToRotator().Equals(FRotator(0, 90, 0), 0.1);
}

bool Observe_QuatEuler()
{
	FQuat q = FQuat(FRotator(10, 20, 30));
	return QuatEuler().Equals(q.Euler(), 0.1);
}

bool Observe_GetForwardAxis()
{
	return GetForwardAxis().Equals(FVector::ForwardVector, 0.01);
}

bool Observe_GetRightAxis()
{
	return GetRightAxis().Equals(FVector::RightVector, 0.01);
}

bool Observe_GetUpAxis()
{
	return GetUpAxis().Equals(FVector::UpVector, 0.01);
}

bool Observe_QuatToRotator_DefaultIdentity()
{
	return FQuat().Rotator().Equals(FRotator::ZeroRotator, 0.1);
}

bool Observe_GetAxes_CopyIndependence()
{
	FQuat q = FQuat(FRotator(0, 0, 0));
	FVector Forward = q.GetAxisX();
	Forward.X = 0.0;
	return q.GetAxisX().Equals(FVector::ForwardVector, 0.01);
}
