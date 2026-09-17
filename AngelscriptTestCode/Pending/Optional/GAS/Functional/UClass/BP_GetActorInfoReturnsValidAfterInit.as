/**
 * @version v1
 * @summary An attribute set whose BP_GetActorInfo resolves after C++ runs InitAbilityActorInfo. The observers cover the null handle, the resolved owner actor and the empty attribute data.
 * @topic Optional
 */
/**
 * @version root
 * @summary An attribute set whose BP_GetActorInfo resolves after C++ runs InitAbilityActorInfo. The observers cover the null handle, the resolved owner actor and the empty attribute data.
 * @topic Baseline
 */
UCLASS()
class UTestActorInfoAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Vitality;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.BPGetActorInfo
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestActorInfoAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe the owner actor reported by the actor info.
	 *
	 * @Kind Observe
	 * @Covers GAS.BPGetActorInfo
	 * @Inputs this set's actor info and the runner-supplied owner
	 * @Return true when the owner actor matches
	 * @Param BaselineOwner the actor that owns the initialized ASC
	 */
	UFUNCTION()
	bool OwnerActor(AActor BaselineOwner)
	{
		FGameplayAbilityActorInfo ActorInfo = BP_GetActorInfo();
		return ActorInfo.OwnerActor == BaselineOwner;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.BPGetActorInfo
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
 * @Covers GAS.BPGetActorInfo
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestActorInfoAttributesEmpty : UAngelscriptAttributeSet
{
}
/** @end */
