// Theme: Gameplay.FTransform. Positive &inout assignment and mutator oracles.
// C++: AngelscriptCoverageFTransformFunctionTests.cpp::FunctionParametersInOut
// Oracle: AssignScaleTransform scale (2,2,2); AssignTranslateTransform location
// (15,30,45) from (10,20,30)+offset(5,10,15); MutateScaleTransform scale (2,2,2).
// Extra: identity scale remains (1,1,1) until mutated; copy independence of
// AssignTranslateTransform inputs. DefaultSafe.

void AssignScaleTransform(FTransform&inout t)
{
	t = FTransform(t.GetRotation(), t.GetLocation(), FVector(2, 2, 2));
}

void AssignTranslateTransform(FTransform&inout t, FVector offset)
{
	t = FTransform(t.GetRotation(), t.GetLocation() + offset, t.GetScale3D());
}

void MutateScaleTransform(FTransform&inout t)
{
	t.SetScale3D(FVector(2, 2, 2));
}

bool Observe_AssignScaleTransform()
{
	FTransform Value = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(1, 1, 1));
	AssignScaleTransform(Value);
	return Value.GetScale3D().Equals(FVector(2, 2, 2), 0.01);
}

bool Observe_AssignTranslateTransform()
{
	FTransform Value = FTransform(FVector(10, 20, 30));
	FVector Offset = FVector(5, 10, 15);
	AssignTranslateTransform(Value, Offset);
	return Value.GetLocation().Equals(FVector(15, 30, 45), 0.01);
}

bool Observe_MutateScaleTransform()
{
	FTransform Value = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(1, 1, 1));
	MutateScaleTransform(Value);
	return Value.GetScale3D().Equals(FVector(2, 2, 2), 0.01);
}

bool Observe_AssignScaleTransform_DefaultEmpty()
{
	FTransform Value = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(1, 1, 1));
	return Value.GetScale3D().Equals(FVector(1, 1, 1), 0.01)
		&& Value.GetLocation().Equals(FVector::ZeroVector, 0.01);
}

bool Observe_AssignTranslateTransform_CopyIndependence()
{
	FTransform Value = FTransform(FVector(10, 20, 30));
	FVector Offset = FVector(5, 10, 15);
	AssignTranslateTransform(Value, Offset);
	return Offset.Equals(FVector(5, 10, 15), 0.01)
		&& Value.GetLocation().Equals(FVector(15, 30, 45), 0.01);
}
