// Theme: Gameplay.FTransform. Positive transform operation oracles.
// C++: AngelscriptCoverageMathGeometricStructs.cpp::FTransformOperations
// Oracle vectors: multiply (10,20,0); TransformPosition (12,24,36);
// TransformVector (2,6,12); InverseTransformPosition (1,2,3);
// InverseTransformRoundTrip (3,4,5); TransformPositionNoScale (11,22,33);
// InverseTransformVector (2,2,2); InverseTransformVectorNoScale (4,8,10);
// ScaleTranslationAndAdd (21,42,63); BlendLocation (5,10,15).
// Bools true; TestAxisScale 7.0. Extra: empty Identity location (0,0,0);
// copy independence of Blend inputs. DefaultSafe.

FVector TestMultiplyTransformLocation()
{
	FTransform First = FTransform(FVector(10, 0, 0));
	FTransform Second = FTransform(FVector(0, 20, 0));
	FTransform Combined = First * Second;
	return Combined.GetLocation();
}

FVector TestTransformPosition()
{
	FTransform Transform = FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(2, 2, 2));
	return Transform.TransformPosition(FVector(1, 2, 3));
}

FVector TestTransformVector()
{
	FTransform Transform = FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(2, 3, 4));
	return Transform.TransformVector(FVector(1, 2, 3));
}

FVector TestInverseTransformPosition()
{
	FTransform Transform = FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(2, 2, 2));
	return Transform.InverseTransformPosition(FVector(12, 24, 36));
}

FVector TestInverseTransformRoundTrip()
{
	FTransform Transform = FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(2, 3, 4));
	FVector Local = FVector(3, 4, 5);
	return Transform.Inverse().TransformPosition(Transform.TransformPosition(Local));
}

FVector TestTransformPositionNoScale()
{
	FTransform Transform = FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(2, 3, 4));
	return Transform.TransformPositionNoScale(FVector(1, 2, 3));
}

FVector TestInverseTransformVector()
{
	FTransform Transform = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(2, 4, 5));
	return Transform.InverseTransformVector(FVector(4, 8, 10));
}

FVector TestInverseTransformVectorNoScale()
{
	FTransform Transform = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(2, 4, 5));
	return Transform.InverseTransformVectorNoScale(FVector(4, 8, 10));
}

FVector TestScaleTranslationAndAdd()
{
	FTransform Transform = FTransform(FVector(10, 20, 30));
	Transform.ScaleTranslation(2.0);
	Transform.AddToTranslation(FVector(1, 2, 3));
	return Transform.GetTranslation();
}

FVector TestBlendLocation()
{
	FTransform A = FTransform(FVector(0, 0, 0));
	FTransform B = FTransform(FVector(10, 20, 30));
	FTransform Result;
	Result.Blend(A, B, 0.5f);
	return Result.GetTranslation();
}

bool TestEqualsNoScale()
{
	FTransform A = FTransform(FQuat::Identity, FVector(1, 2, 3), FVector(1, 1, 1));
	FTransform B = FTransform(FQuat::Identity, FVector(1, 2, 3), FVector(4, 5, 6));
	return A.EqualsNoScale(B, 0.001);
}

bool TestTranslationEqualsAndSubtract()
{
	FTransform A = FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(1, 1, 1));
	FTransform B = FTransform(FQuat::Identity, FVector(3, 5, 7), FVector(9, 9, 9));
	FVector Difference = A.SubtractTranslations(B);
	return A.TranslationEquals(FTransform(FVector(10, 20, 30)), 0.001)
		&& Difference.Equals(FVector(7, 15, 23), 0.001);
}

bool TestSetTranslationScaleAndDeterminant()
{
	FTransform Transform = FTransform::Identity;
	Transform.SetTranslationAndScale3D(FVector(1, 2, 3), FVector(2, 3, 4));
	return Transform.GetTranslation().Equals(FVector(1, 2, 3), 0.001)
		&& Transform.GetScale3D().Equals(FVector(2, 3, 4), 0.001)
		&& Math::IsNearlyEqual(Transform.GetDeterminant(), 24.0, 0.001);
}

bool TestRotatorConversion()
{
	FTransform Transform = FTransform(FRotator(10, 20, 30));
	FRotator Rotator = Transform.Rotator();
	return Math::IsNearlyEqual(Rotator.Pitch, 10.0, 0.001)
		&& Math::IsNearlyEqual(Rotator.Yaw, 20.0, 0.001)
		&& Math::IsNearlyEqual(Rotator.Roll, 30.0, 0.001);
}

bool TestValidityHelpers()
{
	FTransform Transform = FTransform(FQuat::Identity, FVector(1, 2, 3), FVector(2, 2, 2));
	return Transform.IsValid() && !Transform.ContainsNaN();
}

float TestAxisScale()
{
	FTransform Transform = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(2, 5, 3));
	return Transform.GetMaximumAxisScale() + Transform.GetMinimumAxisScale();
}

bool Observe_TestMultiplyTransformLocation()
{
	return TestMultiplyTransformLocation().Equals(FVector(10, 20, 0), 0.001);
}

bool Observe_TestTransformPosition()
{
	return TestTransformPosition().Equals(FVector(12, 24, 36), 0.001);
}

bool Observe_TestTransformVector()
{
	return TestTransformVector().Equals(FVector(2, 6, 12), 0.001);
}

bool Observe_TestInverseTransformPosition()
{
	return TestInverseTransformPosition().Equals(FVector(1, 2, 3), 0.001);
}

bool Observe_TestInverseTransformRoundTrip()
{
	return TestInverseTransformRoundTrip().Equals(FVector(3, 4, 5), 0.001);
}

bool Observe_TestTransformPositionNoScale()
{
	return TestTransformPositionNoScale().Equals(FVector(11, 22, 33), 0.001);
}

bool Observe_TestInverseTransformVector()
{
	return TestInverseTransformVector().Equals(FVector(2, 2, 2), 0.001);
}

bool Observe_TestInverseTransformVectorNoScale()
{
	return TestInverseTransformVectorNoScale().Equals(FVector(4, 8, 10), 0.001);
}

bool Observe_TestScaleTranslationAndAdd()
{
	return TestScaleTranslationAndAdd().Equals(FVector(21, 42, 63), 0.001);
}

bool Observe_TestBlendLocation()
{
	return TestBlendLocation().Equals(FVector(5, 10, 15), 0.001);
}

bool Observe_TestEqualsNoScale()
{
	return TestEqualsNoScale() == true;
}

bool Observe_TestTranslationEqualsAndSubtract()
{
	return TestTranslationEqualsAndSubtract() == true;
}

bool Observe_TestSetTranslationScaleAndDeterminant()
{
	return TestSetTranslationScaleAndDeterminant() == true;
}

bool Observe_TestRotatorConversion()
{
	return TestRotatorConversion() == true;
}

bool Observe_TestValidityHelpers()
{
	return TestValidityHelpers() == true;
}

bool Observe_TestAxisScale()
{
	return Math::IsNearlyEqual(TestAxisScale(), 7.0, 0.001);
}

bool Observe_TestBlendLocation_DefaultEmpty()
{
	FTransform Result;
	return Result.GetTranslation().Equals(FVector::ZeroVector, 0.001);
}

bool Observe_TestBlendLocation_CopyIndependence()
{
	FTransform A = FTransform(FVector(0, 0, 0));
	FTransform B = FTransform(FVector(10, 20, 30));
	FTransform Result;
	Result.Blend(A, B, 0.5f);
	Result.SetLocation(FVector::ZeroVector);
	return A.GetTranslation().Equals(FVector(0, 0, 0), 0.001)
		&& B.GetTranslation().Equals(FVector(10, 20, 30), 0.001);
}

bool Observe_TestEqualsNoScale_FalseBoundary()
{
	FTransform A = FTransform(FQuat::Identity, FVector(1, 2, 3), FVector(1, 1, 1));
	FTransform B = FTransform(FQuat::Identity, FVector(9, 9, 9), FVector(1, 1, 1));
	return A.EqualsNoScale(B, 0.001) == false;
}
