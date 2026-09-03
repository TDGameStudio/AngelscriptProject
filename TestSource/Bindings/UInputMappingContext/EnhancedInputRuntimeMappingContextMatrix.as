/**
 * Enhanced Input runtime movement mapping matrix: a WASD and arrow layout
 * where each key carries its own modifier chain. W and the arrows get a
 * swizzle, S and Down get a swizzle plus a negate, A and Left get a negate,
 * and D and Right stay unmodified. The observable contract is the mapping
 * count, the action's value type and accumulation behaviour, and the modifier
 * count on each mapping. Moved here from ../../Containers/TMap/Function/ where
 * it sat misplaced under a container whose API it does not touch.
 *
 * @Theme Bindings.UInputMappingContext
 * @Subject UInputMappingContext.RuntimeMappingMatrix
 * @Harness Function
 * @Tag Bindings.UInputMappingContext.EnhancedInputRuntimeMappingContextMatrix
 * @Namespace UInputMappingContextTest
 */

namespace UInputMappingContextTest
{
	/**
	 * Observe the runtime WASD and arrow mapping matrix, including each
	 * mapping's modifier chain.
	 *
	 * @Kind Observe
	 * @Covers UInputMappingContext.MapKey
	 * @Inputs A context with one Axis2D cumulative action; eight keys mapped with modifiers
	 * @Return true when the count, value type, behaviour, and modifier counts all match
	 */
	UFUNCTION()
	bool RuntimeMovementMappingMatrix()
	{
		UInputAction MoveAction = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"CoverageRuntimeMoveAction", true));
		UInputMappingContext MappingContext = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"CoverageRuntimeMoveContext", true));
		if (MoveAction == nullptr)
		{
			return false;
		}
		if (MappingContext == nullptr)
		{
			return false;
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
		if (WSwizzle == nullptr)
		{
			return false;
		}
		if (SSwizzle == nullptr)
		{
			return false;
		}
		if (SNegate == nullptr)
		{
			return false;
		}
		if (ANegate == nullptr)
		{
			return false;
		}
		if (UpSwizzle == nullptr)
		{
			return false;
		}
		if (DownSwizzle == nullptr)
		{
			return false;
		}
		if (DownNegate == nullptr)
		{
			return false;
		}
		if (LeftNegate == nullptr)
		{
			return false;
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
			return false;
		}
		if (MoveAction.GetValueType() != EInputActionValueType::Axis2D)
		{
			return false;
		}
		if (MoveAction.GetAccumulationBehavior() != EInputActionAccumulationBehavior::Cumulative)
		{
			return false;
		}
		if (W.GetAction() != MoveAction)
		{
			return false;
		}
		if (W.GetKey() != EKeys::W)
		{
			return false;
		}
		if (W.GetModifierCount() != 1)
		{
			return false;
		}
		if (S.GetModifierCount() != 2)
		{
			return false;
		}
		if (A.GetModifierCount() != 1)
		{
			return false;
		}
		if (D.GetModifierCount() != 0)
		{
			return false;
		}
		if (Up.GetModifierCount() != 1)
		{
			return false;
		}
		if (Down.GetModifierCount() != 2)
		{
			return false;
		}
		if (Left.GetModifierCount() != 1)
		{
			return false;
		}
		return Right.GetModifierCount() == 0;
	}

	/**
	 * Observe the empty default: UnmapAll on a fresh context leaves it empty.
	 *
	 * @Kind Observe
	 * @Covers UInputMappingContext.MapKey
	 * @Inputs A newly created mapping context; UnmapAll
	 * @Return true when GetMappingCount is 0
	 */
	UFUNCTION()
	bool RuntimeMatrixEmptyDefault()
	{
		UInputMappingContext MappingContext = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"CoverageEmptyRuntimeContext", true));
		if (MappingContext == nullptr)
		{
			return false;
		}
		MappingContext.UnmapAll();
		return MappingContext.GetMappingCount() == 0;
	}

	/**
	 * Observe copy independence: mapping on one context leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers UInputMappingContext.MapKey
	 * @Inputs Two contexts and one Axis2D action; MapKey only on the first
	 * @Return true when the first has one mapping and the second has none
	 */
	UFUNCTION()
	bool RuntimeMatrixCopyIndependence()
	{
		UInputAction MoveAction = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"CoverageRuntimeCopyAction", true));
		UInputMappingContext First = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"CoverageRuntimeCopyA", true));
		UInputMappingContext Second = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"CoverageRuntimeCopyB", true));
		if (MoveAction == nullptr)
		{
			return false;
		}
		if (First == nullptr)
		{
			return false;
		}
		if (Second == nullptr)
		{
			return false;
		}

		MoveAction.SetValueType(EInputActionValueType::Axis2D);
		First.MapKey(MoveAction, EKeys::W);
		if (First.GetMappingCount() != 1)
		{
			return false;
		}
		return Second.GetMappingCount() == 0;
	}

	/**
	 * In-only: report the modifier count of a const&in mapping.
	 *
	 * @Kind RoundTrip
	 * @Covers UInputMappingContext.MapKey
	 * @Param Mapping Source mapping received as const FEnhancedActionKeyMapping&in
	 * @Inputs Mapping carries one modifier
	 * @Return true when GetModifierCount is 1
	 */
	UFUNCTION()
	bool ReadModifierCount(const FEnhancedActionKeyMapping&in Mapping)
	{
		return Mapping.GetModifierCount() == 1;
	}

	/**
	 * Out-only: register a key with one modifier on an &out context.
	 *
	 * @Kind RoundTrip
	 * @Covers UInputMappingContext.MapKey
	 * @Param Context Destination received as UInputMappingContext&out
	 * @Inputs Empty &out context
	 * @Return void; Context holds one mapping carrying one modifier
	 */
	UFUNCTION()
	void MapKeyWithModifier(UInputMappingContext&out Context)
	{
		UInputAction MoveAction = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"CoverageOutRuntimeAction", true));
		UInputModifierNegate Negate = Cast<UInputModifierNegate>(NewObject(Context, UInputModifierNegate::StaticClass(), n"CoverageOutRuntimeNegate", true));
		FEnhancedActionKeyMapping& Mapping = Context.MapKey(MoveAction, EKeys::A);
		Mapping.AddModifier(Negate);
	}

	/**
	 * Inout: clear every mapping on an existing context.
	 *
	 * @Kind RoundTrip
	 * @Covers UInputMappingContext.MapKey
	 * @Param Context Context received as UInputMappingContext&inout, starts holding mappings
	 * @Inputs Context.GetMappingCount() is greater than 0
	 * @Return void; Context holds no mappings
	 */
	UFUNCTION()
	void ClearRuntimeMatrix(UInputMappingContext&inout Context)
	{
		Context.UnmapAll();
	}
}
