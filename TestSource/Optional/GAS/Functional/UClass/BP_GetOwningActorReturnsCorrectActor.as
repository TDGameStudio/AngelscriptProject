/**
 * An attribute set whose BP_GetOwningActor resolves to the actor owning the
 * registered ASC. The observers cover the null handle, the resolved owner actor
 * and the empty attribute data.
 *
 * @Theme Optional.GAS
 * @Subject GAS.BPGetOwningActor
 * @Harness UClass
 * @Tag Optional.GAS.BP_GetOwningActorReturnsCorrectActor
 * @Provenance Theme: Optional.GAS. WorldStory: UTestOwnerAttributes BP_GetOwningActor after register.
 * @Provenance C++: AngelscriptGASAttributeSetOverrideTests.cpp::BP_GetOwningActorReturnsCorrectActor
 * @Provenance Oracle: BP_GetOwningActor() == TestActor that owns the ASC.
 * @Provenance Extra: nullptr handle; empty sibling set; unowned set returns null.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Runner owns spawn, ASC, register.
 */

UCLASS()
class UTestOwnerAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Luck;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.BPGetOwningActor
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestOwnerAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe the owning actor reported by this set.
	 *
	 * @Kind Observe
	 * @Covers GAS.BPGetOwningActor
	 * @Inputs this set's owning actor and the runner-supplied baseline
	 * @Return true when the owning actor matches
	 * @Param BaselineOwner the actor that owns the ASC
	 */
	UFUNCTION()
	bool OwningActor(AActor BaselineOwner)
	{
		return BP_GetOwningActor() == BaselineOwner;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.BPGetOwningActor
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
 * @Covers GAS.BPGetOwningActor
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestOwnerAttributesEmpty : UAngelscriptAttributeSet
{
}
