/**
 * A script attribute set exposing Agility, used to verify that the
 * get-and-register call also binds the trampoline. The observers cover the null
 * handle, the empty attribute data and handle independence.
 *
 * @Theme Optional.GAS
 * @Subject GAS.GetAndRegisterBindsTrampoline
 * @Harness UClass
 * @Tag Optional.GAS.GetAndRegisterCallbackForAttributeAlsoBindsTrampoline
 * @Provenance Theme: Optional.GAS. WorldStory: UTestGetRegBindAttributes Agility get-and-register trampoline.
 * @Provenance C++: AngelscriptGASAttributeCallbackTests.cpp::GetAndRegisterCallbackForAttributeAlsoBindsTrampoline
 * @Provenance Oracle: OnAttributeChanged fires after get-and-register then set 10 -> 20.
 * @Provenance Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Runner owns get-and-register then set.
 */

UCLASS()
class UTestGetRegBindAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Agility;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.GetAndRegisterBindsTrampoline
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestGetRegBindAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.GetAndRegisterBindsTrampoline
	 * @Inputs a default-constructed attribute data
	 * @Return true when the attribute name is none
	 * @Boundary empty name
	 */
	UFUNCTION()
	bool EmptyAttributeData()
	{
		FAngelscriptGameplayAttributeData EmptyData;
		return EmptyData.AttributeName.IsNone();
	}

	/**
	 * Observe that two runner-supplied handles refer to different objects.
	 *
	 * @Kind Observe
	 * @Covers GAS.GetAndRegisterBindsTrampoline
	 * @Inputs two attribute set handles
	 * @Return true when both are non-null and differ
	 * @Param First the first handle
	 * @Param Second the second handle
	 * @Boundary handle independence
	 */
	UFUNCTION()
	bool TwoHandlesIndependent(UTestGetRegBindAttributes First, UTestGetRegBindAttributes Second)
	{
		if (First == nullptr)
		{
			return false;
		}
		if (Second == nullptr)
		{
			return false;
		}
		return First != Second;
	}
}

/**
 * The empty sibling set that C++ also compiles alongside the populated one.
 *
 * @Covers GAS.GetAndRegisterBindsTrampoline
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestGetRegBindAttributesEmpty : UAngelscriptAttributeSet
{
}
