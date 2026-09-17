/**
 * @version v1
 * @summary An enum UPROPERTY whose CDO default is set with a `default` statement. The observers confirm the default lands, that the zero member is the unset value, and that instances do not share state.
 * @topic Language
 */
/**
 * @version root
 * @summary An enum UPROPERTY whose CDO default is set with a `default` statement. The observers confirm the default lands, that the zero member is the unset value, and that instances do not share state.
 * @topic Baseline
 */
enum ETestDirection
{
	Up,
	Down,
	Left,
	Right
}

UCLASS()
class UDefaultEnumCarrier : UObject
{
	UPROPERTY()
	ETestDirection Direction;

	default Direction = ETestDirection::Right;

	/**
	 * Reads the enum as its underlying integer.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the carrier's Direction
	 * @Return the integer value of Direction
	 */
	UFUNCTION()
	int GetDirectionValue()
	{
		return int(Direction);
	}

	/**
	 * Observe that the CDO default was applied.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed carrier
	 * @Return true when the value is 3
	 */
	UFUNCTION()
	bool DefaultEnumAppliesRight()
	{
		return GetDirectionValue() == 3;
	}

	/**
	 * Observe that the first enum member is the zero value.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs the Up member
	 * @Return true when it is 0
	 * @Boundary zero member
	 */
	UFUNCTION()
	bool DefaultEnumUpIsZero()
	{
		return int(ETestDirection::Up) == 0;
	}

	/**
	 * Observe that writing this carrier leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs this carrier set to Up, compared against a second carrier
	 * @Return true when this carrier reads 0 and the other reads 3
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool DefaultEnumInstancesAreIndependent()
	{
		UDefaultEnumCarrier Other =
			Cast<UDefaultEnumCarrier>(
				NewObject(GetTransientPackage(), UDefaultEnumCarrier::StaticClass(), n"DefaultEnumCarrierOther"));
		if (Other == nullptr)
		{
			throw("Test_DefaultEnumPropertyApplied setup: NewObject returned null");
		}

		Direction = ETestDirection::Up;

		if (GetDirectionValue() != 0)
		{
			return false;
		}

		return Other.GetDirectionValue() == 3;
	}
}
/** @end */
