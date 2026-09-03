/**
 * Enhanced Input mapping context and action-value shapes: MapKey registers a
 * key against an action, UnmapKey removes one, UnmapAll clears every mapping,
 * and GetMappingCount reports how many remain. FInputActionValue carries a
 * typed payload and converts between axis shapes, so a Boolean value reads
 * through Get, a 2D value through GetAxis2D, and a 3D value through
 * GetAxis3D. Moved here from ../../Containers/TMap/Function/ where it sat
 * misplaced under a container whose API it does not touch.
 *
 * @Theme Bindings.UInputMappingContext
 * @Subject UInputMappingContext.MappingAndActionValues
 * @Harness Function
 * @Tag Bindings.UInputMappingContext.EnhancedInputMappingContextAndActionValues
 * @Namespace UInputMappingContextTest
 */

namespace UInputMappingContextTest
{
	/**
	 * Observe the map / unmap / clear lifecycle on a mapping context.
	 *
	 * @Kind Observe
	 * @Covers UInputMappingContext.MapKey
	 * @Inputs A context with one action; MapKey W and D; UnmapKey W; UnmapAll
	 * @Return true when counts track 2, then 1, then 0
	 */
	UFUNCTION()
	bool MappingContextMapUnmapAndClear()
	{
		UInputAction MoveAction = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"CoverageMoveAction", true));
		UInputMappingContext MappingContext = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"CoverageMoveContext", true));
		if (MoveAction == nullptr || MappingContext == nullptr)
		{
			return false;
		}

		MoveAction.SetValueType(EInputActionValueType::Axis2D);
		FEnhancedActionKeyMapping& WMapping = MappingContext.MapKey(MoveAction, EKeys::W);
		FEnhancedActionKeyMapping& DMapping = MappingContext.MapKey(MoveAction, EKeys::D);
		if (MappingContext.GetMappingCount() != 2)
		{
			return false;
		}
		if (!MappingContext.HasMappingForInputAction(MoveAction))
		{
			return false;
		}
		if (WMapping.GetAction() != MoveAction)
		{
			return false;
		}
		if (WMapping.GetKey() != EKeys::W)
		{
			return false;
		}
		if (DMapping.GetAction() != MoveAction)
		{
			return false;
		}
		if (DMapping.GetKey() != EKeys::D)
		{
			return false;
		}

		MappingContext.UnmapKey(MoveAction, EKeys::W);
		if (MappingContext.GetMappingCount() != 1)
		{
			return false;
		}

		MappingContext.UnmapAll();
		return MappingContext.GetMappingCount() == 0;
	}

	/**
	 * Observe the action-value shapes: each typed payload reads back through
	 * its matching accessor, and ConvertToType narrows a 3D value to 1D.
	 *
	 * @Kind Observe
	 * @Covers UInputMappingContext.MapKey
	 * @Inputs Float, Boolean, 2D, and 3D action values; ConvertToType on the 3D one
	 * @Return true when every shape reads back and the conversion narrows correctly
	 */
	UFUNCTION()
	bool InputActionValueShapes()
	{
		FInputActionValue FloatValue(0.75f);
		if (FloatValue.GetAxis1D() < 0.74f)
		{
			return false;
		}
		if (FloatValue.GetAxis1D() > 0.76f)
		{
			return false;
		}

		FInputActionValue BoolValue(EInputActionValueType::Boolean, FVector(1.0f, 0.0f, 0.0f));
		if (!BoolValue.Get())
		{
			return false;
		}

		FInputActionValue Vector2DValue(FVector2D(2.0f, -3.0f));
		FVector2D Axis2D = Vector2DValue.GetAxis2D();
		if (Axis2D.X < 1.9f)
		{
			return false;
		}
		if (Axis2D.X > 2.1f)
		{
			return false;
		}
		if (Axis2D.Y > -2.9f)
		{
			return false;
		}
		if (Axis2D.Y < -3.1f)
		{
			return false;
		}

		FInputActionValue Vector3DValue(FVector(4.0f, 5.0f, 6.0f));
		FVector Axis3D = Vector3DValue.GetAxis3D();
		if (Axis3D.X < 3.9f)
		{
			return false;
		}
		if (Axis3D.X > 4.1f)
		{
			return false;
		}
		if (Axis3D.Z < 5.9f)
		{
			return false;
		}
		if (Axis3D.Z > 6.1f)
		{
			return false;
		}

		Vector3DValue.ConvertToType(EInputActionValueType::Axis1D);
		if (Vector3DValue.GetAxis1D() <= 3.9f)
		{
			return false;
		}
		return Vector3DValue.GetAxis1D() < 4.1f;
	}

	/**
	 * Observe the empty default: a fresh context holds no mappings.
	 *
	 * @Kind Observe
	 * @Covers UInputMappingContext.MapKey
	 * @Inputs A newly created mapping context
	 * @Return true when GetMappingCount is 0
	 */
	UFUNCTION()
	bool MappingContextEmptyDefault()
	{
		UInputMappingContext MappingContext = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"CoverageEmptyContext", true));
		if (MappingContext == nullptr)
		{
			return false;
		}
		return MappingContext.GetMappingCount() == 0;
	}

	/**
	 * Observe the Boolean false boundary: a zero vector reads as false.
	 *
	 * @Kind Observe
	 * @Covers UInputMappingContext.MapKey
	 * @Inputs A Boolean action value built from a zero vector
	 * @Return true when Get is false
	 * @Boundary Boolean false vs true
	 */
	UFUNCTION()
	bool BoolValueFalseBoundary()
	{
		FInputActionValue BoolValue(EInputActionValueType::Boolean, FVector(0.0f, 0.0f, 0.0f));
		return !BoolValue.Get();
	}

	/**
	 * Observe copy independence: mapping on one context leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers UInputMappingContext.MapKey
	 * @Inputs Two contexts and one action; MapKey only on the first
	 * @Return true when the first has one mapping and the second has none
	 */
	UFUNCTION()
	bool MappingContextCopyIndependence()
	{
		UInputAction MoveAction = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"CoverageCopyMoveAction", true));
		UInputMappingContext First = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"CoverageCopyContextA", true));
		UInputMappingContext Second = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"CoverageCopyContextB", true));
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

		First.MapKey(MoveAction, EKeys::W);
		if (First.GetMappingCount() != 1)
		{
			return false;
		}
		return Second.GetMappingCount() == 0;
	}

	/**
	 * In-only: report the mapping count of a const&in context.
	 *
	 * @Kind RoundTrip
	 * @Covers UInputMappingContext.MapKey
	 * @Param Context Source context received as const UInputMappingContext&in
	 * @Inputs Context holds exactly one mapping
	 * @Return true when GetMappingCount is 1
	 */
	UFUNCTION()
	bool ReadMappingCount(const UInputMappingContext&in Context)
	{
		return Context.GetMappingCount() == 1;
	}

	/**
	 * Out-only: register a key on an &out context.
	 *
	 * @Kind RoundTrip
	 * @Covers UInputMappingContext.MapKey
	 * @Param Context Destination received as UInputMappingContext&out
	 * @Inputs Empty &out context
	 * @Return void; Context holds one mapping
	 */
	UFUNCTION()
	void MapOneKey(UInputMappingContext&out Context)
	{
		UInputAction MoveAction = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"CoverageOutMoveAction", true));
		Context.MapKey(MoveAction, EKeys::W);
	}

	/**
	 * Inout: clear every mapping on an existing context.
	 *
	 * @Kind RoundTrip
	 * @Covers UInputMappingContext.MapKey
	 * @Param Context Context received as UInputMappingContext&inout, starts holding one mapping
	 * @Inputs Context.GetMappingCount() is 1
	 * @Return void; Context holds no mappings
	 */
	UFUNCTION()
	void UnmapEveryKey(UInputMappingContext&inout Context)
	{
		Context.UnmapAll();
	}
}
