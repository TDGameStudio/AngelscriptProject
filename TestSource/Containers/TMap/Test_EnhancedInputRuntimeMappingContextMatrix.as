// Theme: Containers.TMap. Positive Enhanced Input runtime WASD/arrow mapping matrix.
// C++ ExecuteAndExpectInt RuntimeMovementMappingMatrix==1 (8 mappings, Axis2D, Cumulative).
// Extra: UnmapAll empty count 0; two contexts stay independent after MapKey.
// DefaultSafe.

int RuntimeMovementMappingMatrix()
{
	UInputAction MoveAction = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"CoverageRuntimeMoveAction", true));
	UInputMappingContext MappingContext = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"CoverageRuntimeMoveContext", true));
	if (MoveAction == nullptr || MappingContext == nullptr)
	{
		return 0;
	}

	MoveAction.SetValueType(EInputActionValueType::Axis2D);
	MoveAction.SetAccumulationBehavior(EInputActionAccumulationBehavior::Cumulative);
	MappingContext.UnmapAll();

	UInputModifierSwizzleAxis WSwizzle = Cast<UInputModifierSwizzleAxis>(NewObject(MappingContext, UInputModifierSwizzleAxis::StaticClass(), n"CoverageRuntimeWSwizzle", true));
	UInputModifierSwizzleAxis SSwizzle = Cast<UInputModifierSwizzleAxis>(NewObject(MappingContext, UInputModifierSwizzleAxis::StaticClass(), n"CoverageRuntimeSSwizzle", true));
	UInputModifierNegate SNegate = Cast<UInputModifierNegate>(NewObject(MappingContext, UInputModifierNegate::StaticClass(), n"CoverageRuntimeSNegate", true));
	UInputModifierNegate ANegate = Cast<UInputModifierNegate>(NewObject(MappingContext, UInputModifierNegate::StaticClass(), n"CoverageRuntimeANegate", true));
	UInputModifierSwizzleAxis UpSwizzle = Cast<UInputModifierSwizzleAxis>(NewObject(MappingContext, UInputModifierSwizzleAxis::StaticClass(), n"CoverageRuntimeUpSwizzle", true));
	UInputModifierSwizzleAxis DownSwizzle = Cast<UInputModifierSwizzleAxis>(NewObject(MappingContext, UInputModifierSwizzleAxis::StaticClass(), n"CoverageRuntimeDownSwizzle", true));
	UInputModifierNegate DownNegate = Cast<UInputModifierNegate>(NewObject(MappingContext, UInputModifierNegate::StaticClass(), n"CoverageRuntimeDownNegate", true));
	UInputModifierNegate LeftNegate = Cast<UInputModifierNegate>(NewObject(MappingContext, UInputModifierNegate::StaticClass(), n"CoverageRuntimeLeftNegate", true));
	if (WSwizzle == nullptr || SSwizzle == nullptr || SNegate == nullptr || ANegate == nullptr
		|| UpSwizzle == nullptr || DownSwizzle == nullptr || DownNegate == nullptr || LeftNegate == nullptr)
	{
		return 0;
	}

	FEnhancedActionKeyMapping& W = MappingContext.MapKey(MoveAction, EKeys::W);
	W.AddModifier(WSwizzle);

	FEnhancedActionKeyMapping& S = MappingContext.MapKey(MoveAction, EKeys::S);
	S.AddModifier(SSwizzle);
	S.AddModifier(SNegate);

	FEnhancedActionKeyMapping& A = MappingContext.MapKey(MoveAction, EKeys::A);
	A.AddModifier(ANegate);

	FEnhancedActionKeyMapping& D = MappingContext.MapKey(MoveAction, EKeys::D);

	FEnhancedActionKeyMapping& Up = MappingContext.MapKey(MoveAction, EKeys::Up);
	Up.AddModifier(UpSwizzle);

	FEnhancedActionKeyMapping& Down = MappingContext.MapKey(MoveAction, EKeys::Down);
	Down.AddModifier(DownSwizzle);
	Down.AddModifier(DownNegate);

	FEnhancedActionKeyMapping& Left = MappingContext.MapKey(MoveAction, EKeys::Left);
	Left.AddModifier(LeftNegate);

	FEnhancedActionKeyMapping& Right = MappingContext.MapKey(MoveAction, EKeys::Right);

	if (MappingContext.GetMappingCount() != 8)
	{
		return 0;
	}
	if (MoveAction.GetValueType() != EInputActionValueType::Axis2D)
	{
		return 0;
	}
	if (MoveAction.GetAccumulationBehavior() != EInputActionAccumulationBehavior::Cumulative)
	{
		return 0;
	}
	if (W.GetAction() != MoveAction || W.GetKey() != EKeys::W || W.GetModifierCount() != 1)
	{
		return 0;
	}
	if (S.GetModifierCount() != 2 || A.GetModifierCount() != 1 || D.GetModifierCount() != 0)
	{
		return 0;
	}
	if (Up.GetModifierCount() != 1 || Down.GetModifierCount() != 2 || Left.GetModifierCount() != 1 || Right.GetModifierCount() != 0)
	{
		return 0;
	}

	return 1;
}

bool Observe_RuntimeMovementMappingMatrix_Nominal()
{
	return RuntimeMovementMappingMatrix() == 1;
}

int Observe_RuntimeMatrix_EmptyDefault()
{
	UInputMappingContext MappingContext = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"CoverageEmptyRuntimeContext", true));
	if (MappingContext == nullptr)
	{
		return 0;
	}
	MappingContext.UnmapAll();
	return MappingContext.GetMappingCount() == 0 ? 1 : 0;
}

int Observe_RuntimeMatrix_CopyIndependence()
{
	UInputAction MoveAction = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"CoverageRuntimeCopyAction", true));
	UInputMappingContext First = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"CoverageRuntimeCopyA", true));
	UInputMappingContext Second = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"CoverageRuntimeCopyB", true));
	if (MoveAction == nullptr || First == nullptr || Second == nullptr)
	{
		return 0;
	}
	MoveAction.SetValueType(EInputActionValueType::Axis2D);
	First.MapKey(MoveAction, EKeys::W);
	return First.GetMappingCount() == 1 && Second.GetMappingCount() == 0 ? 1 : 0;
}
