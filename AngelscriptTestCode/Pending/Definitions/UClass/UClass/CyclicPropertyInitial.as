/**
 * @version v1
 * @summary Cyclic property dependency initial source. Live CycleA.Other and CycleB.Other default to null.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Cyclic property dependency initial source. Live CycleA.Other and CycleB.Other default to null.
 * @topic Baseline
 */
UCLASS()
class UClassGeneratorPropagationCycleA : UObject
{
	UPROPERTY()
	UClassGeneratorPropagationCycleB Other;

	/**
	 * Observe that Other defaults to null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs a freshly constructed CycleA
	 * @Return true when Other is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool OtherDefaultIsNull()
	{
		return Other == nullptr;
	}

	/**
	 * Observe that a nullptr CycleA handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs UClassGeneratorPropagationCycleA Node = nullptr
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UClassGeneratorPropagationCycleA Node = nullptr;
		return Node == nullptr;
	}

	/**
	 * Observe that assigning a handle aliases the same object.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs Alias = this
	 * @Return true when Alias == this
	 * @Boundary handle aliasing
	 */
	UFUNCTION()
	bool AssignAliases()
	{
		UClassGeneratorPropagationCycleA Alias = this;
		return Alias == this;
	}
}

UCLASS()
class UClassGeneratorPropagationCycleB : UObject
{
	UPROPERTY()
	UClassGeneratorPropagationCycleA Other;

	/**
	 * Observe that Other defaults to null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs a freshly constructed CycleB
	 * @Return true when Other is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool OtherDefaultIsNull()
	{
		return Other == nullptr;
	}
}
/** @end */
