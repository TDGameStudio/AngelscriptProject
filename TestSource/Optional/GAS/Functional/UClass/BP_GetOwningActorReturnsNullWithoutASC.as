/**
 * An attribute set created with NewObject and never registered, so it has no
 * owning actor. The observers cover the null handle, the null owning actor and
 * the empty attribute data.
 *
 * @Theme Optional.GAS
 * @Subject GAS.BPGetOwningActorNull
 * @Harness UClass
 * @Tag Optional.GAS.BP_GetOwningActorReturnsNullWithoutASC
 * @Provenance Theme: Optional.GAS. WorldStory: UTestNoASCOwnerAttributes unowned NewObject.
 * @Provenance C++: AngelscriptGASAttributeSetOverrideTests.cpp::BP_GetOwningActorReturnsNullWithoutASC
 * @Provenance Oracle: BP_GetOwningActor() is null when the set has no owning ASC.
 * @Provenance Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Runner owns unowned NewObject set.
 */

UCLASS()
class UTestNoASCOwnerAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Temp;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.BPGetOwningActorNull
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestNoASCOwnerAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that an unregistered set reports no owning actor.
	 *
	 * @Kind Observe
	 * @Covers GAS.BPGetOwningActorNull
	 * @Inputs this set's owning actor accessor
	 * @Return true when the owning actor is null
	 * @Boundary unowned set
	 */
	UFUNCTION()
	bool UnownedOwnerIsNull()
	{
		return BP_GetOwningActor() == nullptr;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.BPGetOwningActorNull
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
}

/**
 * The empty sibling set that C++ also compiles alongside the populated one.
 *
 * @Covers GAS.BPGetOwningActorNull
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestNoASCOwnerAttributesEmpty : UAngelscriptAttributeSet
{
}
