// Theme: Gameplay.FTransform. Positive advanced method / mutator oracles.
// C++: AngelscriptCoverageFTransformExpressionTests.cpp::TransformAdvancedMethodsAndMutators
// Oracle: TransformRotation native; InverseTransformRotation round-trip Local;
// TransformPositionNoScale / TransformVectorNoScale native;
// InverseTransformPositionNoScale round-trip (1,2,3); ConstGetterComposition (8,11,14);
// MultiplyAssign native; SetTranslationAndScale native;
// MutateTranslationAndScaling (11,15,19); CompareNoScale true; CompareTranslationOnly true;
// AxisScaleSum 7.
// Extra: AxisScaleSum of Identity is 2; copy independence of Local quat. DefaultSafe.

FQuat TransformRotation()
{
	FTransform T = FTransform(FRotator(0, 90, 0), FVector(100, 0, 0), FVector(2, 3, 4));
	FQuat Local = FQuat(FRotator(10, 20, 30));
	return T.TransformRotation(Local);
}

FQuat InverseTransformRotationRoundTrip()
{
	FTransform T = FTransform(FRotator(0, 90, 0), FVector(100, 0, 0), FVector(2, 3, 4));
	FQuat Local = FQuat(FRotator(10, 20, 30));
	return T.InverseTransformRotation(T.TransformRotation(Local));
}

FVector TransformPositionNoScale()
{
	FTransform T = FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(2, 3, 4));
	return T.TransformPositionNoScale(FVector(1, 2, 3));
}

FVector TransformVectorNoScale()
{
	FTransform T = FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(2, 3, 4));
	return T.TransformVectorNoScale(FVector(1, 2, 3));
}

FVector InverseTransformPositionNoScaleRoundTrip()
{
	FTransform T = FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(2, 3, 4));
	FVector Local = FVector(1, 2, 3);
	return T.InverseTransformPositionNoScale(T.TransformPositionNoScale(Local));
}

FVector ConstGetterComposition()
{
	const FTransform T = FTransform(FQuat::Identity, FVector(3, 4, 5), FVector(2, 3, 4));
	return T.GetLocation() + T.GetTranslation() + T.GetScale3D();
}

FTransform MultiplyAssign()
{
	FTransform T = FTransform(FVector(1, 0, 0));
	T *= FTransform(FVector(0, 2, 0));
	return T;
}

FTransform SetTranslationAndScale()
{
	FTransform T = FTransform::Identity;
	T.SetTranslationAndScale3D(FVector(7, 8, 9), FVector(2, 3, 4));
	return T;
}

FVector MutateTranslationAndScaling()
{
	FTransform T = FTransform::Identity;
	T.SetLocation(FVector(1, 2, 3));
	T.AddToTranslation(FVector(4, 5, 6));
	T.SetScale3D(FVector(2, 3, 4));
	T.ScaleTranslation(2.0);
	T.RemoveScaling();
	return T.GetLocation() + T.GetScale3D();
}

bool CompareNoScale()
{
	FTransform A = FTransform(FQuat::Identity, FVector(1, 2, 3), FVector(1, 1, 1));
	FTransform B = FTransform(FQuat::Identity, FVector(1, 2, 3), FVector(4, 5, 6));
	return A.EqualsNoScale(B, 0.001);
}

bool CompareTranslationOnly()
{
	FTransform A = FTransform(FQuat::Identity, FVector(1, 2, 3), FVector(1, 1, 1));
	FTransform B = FTransform(FQuat(FRotator(0, 90, 0)), FVector(1, 2, 3), FVector(4, 5, 6));
	return A.TranslationEquals(B, 0.001);
}

float AxisScaleSum()
{
	FTransform T = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(2, 5, 3));
	return T.GetMaximumAxisScale() + T.GetMinimumAxisScale();
}

bool Observe_TransformRotation()
{
	FTransform T = FTransform(FRotator(0, 90, 0), FVector(100, 0, 0), FVector(2, 3, 4));
	FQuat Local = FQuat(FRotator(10, 20, 30));
	return TransformRotation().Equals(T.TransformRotation(Local), 0.001);
}

bool Observe_InverseTransformRotationRoundTrip()
{
	FQuat Local = FQuat(FRotator(10, 20, 30));
	return InverseTransformRotationRoundTrip().Equals(Local, 0.001);
}

bool Observe_TransformPositionNoScale()
{
	FTransform T = FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(2, 3, 4));
	return TransformPositionNoScale().Equals(T.TransformPositionNoScale(FVector(1, 2, 3)), 0.001);
}

bool Observe_TransformVectorNoScale()
{
	FTransform T = FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(2, 3, 4));
	return TransformVectorNoScale().Equals(T.TransformVectorNoScale(FVector(1, 2, 3)), 0.001);
}

bool Observe_InverseTransformPositionNoScaleRoundTrip()
{
	return InverseTransformPositionNoScaleRoundTrip().Equals(FVector(1, 2, 3), 0.001);
}

bool Observe_ConstGetterComposition()
{
	return ConstGetterComposition().Equals(FVector(8, 11, 14), 0.001);
}

bool Observe_MultiplyAssign()
{
	FTransform Expected = FTransform(FVector(1, 0, 0));
	Expected *= FTransform(FVector(0, 2, 0));
	return MultiplyAssign().Equals(Expected, 0.001);
}

bool Observe_SetTranslationAndScale()
{
	FTransform Expected = FTransform::Identity;
	Expected.SetTranslationAndScale3D(FVector(7, 8, 9), FVector(2, 3, 4));
	return SetTranslationAndScale().Equals(Expected, 0.001);
}

bool Observe_MutateTranslationAndScaling()
{
	return MutateTranslationAndScaling().Equals(FVector(11, 15, 19), 0.001);
}

bool Observe_CompareNoScale()
{
	return CompareNoScale() == true;
}

bool Observe_CompareTranslationOnly()
{
	return CompareTranslationOnly() == true;
}

bool Observe_AxisScaleSum()
{
	return AxisScaleSum() == 7.0;
}

bool Observe_AxisScaleSum_DefaultIdentity()
{
	FTransform Empty = FTransform();
	return Empty.GetMaximumAxisScale() + Empty.GetMinimumAxisScale() == 2.0;
}

bool Observe_InverseTransformRotation_CopyIndependence()
{
	FQuat Local = FQuat(FRotator(10, 20, 30));
	FTransform T = FTransform(FRotator(0, 90, 0), FVector(100, 0, 0), FVector(2, 3, 4));
	FQuat World = T.TransformRotation(Local);
	World.X = 0.0;
	return Local.Equals(FQuat(FRotator(10, 20, 30)), 0.001);
}
