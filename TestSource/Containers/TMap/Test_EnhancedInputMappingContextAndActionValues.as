// Theme: Containers.TMap. Positive Enhanced Input mapping context and action-value shapes.
// C++ ExecuteAndExpectInt MappingContextMapUnmapAndClear==1, InputActionValueShapes==1.
// Extra: empty mapping count 0; Boolean false vector; two contexts stay independent.
// DefaultSafe.

int MappingContextMapUnmapAndClear()
{
	UInputAction MoveAction = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"CoverageMoveAction", true));
	UInputMappingContext MappingContext = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"CoverageMoveContext", true));
	if (MoveAction == nullptr || MappingContext == nullptr)
	{
		return 0;
	}

	MoveAction.SetValueType(EInputActionValueType::Axis2D);
	FEnhancedActionKeyMapping& WMapping = MappingContext.MapKey(MoveAction, EKeys::W);
	FEnhancedActionKeyMapping& DMapping = MappingContext.MapKey(MoveAction, EKeys::D);
	if (MappingContext.GetMappingCount() != 2)
	{
		return 0;
	}
	if (!MappingContext.HasMappingForInputAction(MoveAction))
	{
		return 0;
	}
	if (WMapping.GetAction() != MoveAction || WMapping.GetKey() != EKeys::W)
	{
		return 0;
	}
	if (DMapping.GetAction() != MoveAction || DMapping.GetKey() != EKeys::D)
	{
		return 0;
	}

	MappingContext.UnmapKey(MoveAction, EKeys::W);
	if (MappingContext.GetMappingCount() != 1)
	{
		return 0;
	}

	MappingContext.UnmapAll();
	return MappingContext.GetMappingCount() == 0 ? 1 : 0;
}

int InputActionValueShapes()
{
	FInputActionValue FloatValue(0.75f);
	if (FloatValue.GetAxis1D() < 0.74f || FloatValue.GetAxis1D() > 0.76f)
	{
		return 0;
	}

	FInputActionValue BoolValue(EInputActionValueType::Boolean, FVector(1.0f, 0.0f, 0.0f));
	if (!BoolValue.Get())
	{
		return 0;
	}

	FInputActionValue Vector2DValue(FVector2D(2.0f, -3.0f));
	FVector2D Axis2D = Vector2DValue.GetAxis2D();
	if (Axis2D.X < 1.9f || Axis2D.X > 2.1f || Axis2D.Y > -2.9f || Axis2D.Y < -3.1f)
	{
		return 0;
	}

	FInputActionValue Vector3DValue(FVector(4.0f, 5.0f, 6.0f));
	FVector Axis3D = Vector3DValue.GetAxis3D();
	if (Axis3D.X < 3.9f || Axis3D.X > 4.1f || Axis3D.Z < 5.9f || Axis3D.Z > 6.1f)
	{
		return 0;
	}

	Vector3DValue.ConvertToType(EInputActionValueType::Axis1D);
	return Vector3DValue.GetAxis1D() > 3.9f && Vector3DValue.GetAxis1D() < 4.1f ? 1 : 0;
}

bool Observe_EnhancedInputMapping_Nominal()
{
	return MappingContextMapUnmapAndClear() == 1 && InputActionValueShapes() == 1;
}

int Observe_MappingContext_EmptyDefault()
{
	UInputMappingContext MappingContext = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"CoverageEmptyContext", true));
	if (MappingContext == nullptr)
	{
		return 0;
	}
	return MappingContext.GetMappingCount() == 0 ? 1 : 0;
}

int Observe_BoolValue_FalseBoundary()
{
	FInputActionValue BoolValue(EInputActionValueType::Boolean, FVector(0.0f, 0.0f, 0.0f));
	return !BoolValue.Get() ? 1 : 0;
}

int Observe_MappingContext_CopyIndependence()
{
	UInputAction MoveAction = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"CoverageCopyMoveAction", true));
	UInputMappingContext First = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"CoverageCopyContextA", true));
	UInputMappingContext Second = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"CoverageCopyContextB", true));
	if (MoveAction == nullptr || First == nullptr || Second == nullptr)
	{
		return 0;
	}
	First.MapKey(MoveAction, EKeys::W);
	return First.GetMappingCount() == 1 && Second.GetMappingCount() == 0 ? 1 : 0;
}
