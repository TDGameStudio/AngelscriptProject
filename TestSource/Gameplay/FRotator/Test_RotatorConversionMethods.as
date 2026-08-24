// Theme: Gameplay.FRotator. Positive Vector / Quaternion / Euler / rotate oracles.
// C++: AngelscriptCoverageFRotatorExpressionTests.cpp::RotatorConversionMethods
// Oracle: Vector Forward; Quaternion Equals native; Euler Equals native;
// RotateVector Equals native; UnrotateVector Equals native.
// Extra: default Vector is Forward; copy independence of rotate input. DefaultSafe.

FVector RotatorToVector()
{
	FRotator r = FRotator(0, 0, 0);
	return r.Vector();
}

FQuat RotatorToQuaternion()
{
	FRotator r = FRotator(0, 90, 0);
	return r.Quaternion();
}

FVector RotatorEuler()
{
	FRotator r = FRotator(10, 20, 30);
	return r.Euler();
}

FVector RotateVector()
{
	FRotator r = FRotator(0, 90, 0);
	FVector v = FVector(1, 0, 0);
	return r.RotateVector(v);
}

FVector UnrotateVector()
{
	FRotator r = FRotator(0, 90, 0);
	FVector v = FVector(0, 1, 0);
	return r.UnrotateVector(v);
}

bool Observe_RotatorToVector()
{
	return RotatorToVector().Equals(FVector::ForwardVector, 0.01);
}

bool Observe_RotatorToQuaternion()
{
	return RotatorToQuaternion().Equals(FRotator(0, 90, 0).Quaternion(), 0.001);
}

bool Observe_RotatorEuler()
{
	return RotatorEuler().Equals(FRotator(10, 20, 30).Euler(), 0.001);
}

bool Observe_RotateVector()
{
	return RotateVector().Equals(FRotator(0, 90, 0).RotateVector(FVector(1, 0, 0)), 0.01);
}

bool Observe_UnrotateVector()
{
	return UnrotateVector().Equals(FRotator(0, 90, 0).UnrotateVector(FVector(0, 1, 0)), 0.01);
}

bool Observe_RotatorToVector_DefaultEmpty()
{
	return FRotator().Vector().Equals(FVector::ForwardVector, 0.01);
}

bool Observe_RotateVector_CopyIndependence()
{
	FVector V = FVector(1, 0, 0);
	FVector Rotated = FRotator(0, 90, 0).RotateVector(V);
	Rotated.X = 0.0;
	return V.Equals(FVector(1, 0, 0));
}
