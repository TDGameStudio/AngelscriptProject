/**
 * @version v1
 * @summary Script casts one C++ multi-interface actor to the parent and secondary interfaces. C++ verifies the success flags and read values, so those UPROPERTY names are part of the contract and are kept verbatim.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Script casts one C++ multi-interface actor to the parent and secondary interfaces. C++ verifies the success flags and read values, so those UPROPERTY names are part of the contract and are kept verbatim.
 * @topic Baseline
 */
UCLASS()
class ATestInterfaceNativePointerOffset : AActor
{
	UPROPERTY()
	UObject Target;

	UPROPERTY()
	int bParentCastSucceeded = 0;

	UPROPERTY()
	int bSecondaryCastSucceeded = 0;

	UPROPERTY()
	int ParentReadValue = 0;

	UPROPERTY()
	int SecondaryReadValue = 0;

	/**
	 * WorldStory: BeginPlay casts Target to parent and secondary native interfaces.
	 *
	 * @Kind WorldStory
	 * @Covers UInterface.MultiInterfaceCast
	 * @Inputs none
	 * @Return both success flags 1 and the native read values when Target implements both
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(Target);
		if (ParentRef != nullptr)
		{
			bParentCastSucceeded = 1;
			ParentReadValue = ParentRef.GetNativeValue();
			ParentRef.SetNativeMarker(n"FromParent");
		}

		UAngelscriptNativeSecondaryInterface SecondaryRef = Cast<UAngelscriptNativeSecondaryInterface>(Target);
		if (SecondaryRef != nullptr)
		{
			bSecondaryCastSucceeded = 1;
			SecondaryReadValue = SecondaryRef.GetSecondaryValue();
			SecondaryRef.SetSecondaryLabel("FromSecondary");
		}
	}

	/**
	 * Observe that a null target does not cast to the parent interface.
	 *
	 * @Kind Observe
	 * @Covers UInterface.MultiInterfaceCast
	 * @Inputs none
	 * @Return true when the parent cast of nullptr is null
	 * @Boundary null Target
	 */
	UFUNCTION()
	bool NullTargetDoesNotCastParent()
	{
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(nullptr);
		return ParentRef == nullptr;
	}

	/**
	 * Observe that a null target does not cast to the secondary interface.
	 *
	 * @Kind Observe
	 * @Covers UInterface.MultiInterfaceCast
	 * @Inputs none
	 * @Return true when the secondary cast of nullptr is null
	 * @Boundary null Target
	 */
	UFUNCTION()
	bool NullTargetDoesNotCastSecondary()
	{
		UAngelscriptNativeSecondaryInterface SecondaryRef = Cast<UAngelscriptNativeSecondaryInterface>(nullptr);
		return SecondaryRef == nullptr;
	}
}
/** @end */
