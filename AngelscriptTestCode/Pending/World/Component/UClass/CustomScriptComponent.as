/**
 * @version v1
 * @summary A script-derived actor component carrying a value, a name and a doubling method. C++ reads the retrieved value, name and doubled value by path. The observers cover the local-construct default and the doubling method at.
 * @topic World
 */
/**
 * @version root
 * @summary A script-derived actor component carrying a value, a name and a doubling method. C++ reads the retrieved value, name and doubled value by path. The observers cover the local-construct default and the doubling method at.
 * @topic Baseline
 */
UCLASS()
class UCustomLogicComponent : UActorComponent
{
	UPROPERTY()
	int CustomValue = 42;

	UPROPERTY()
	FString CustomName = "TestComponent";

	/**
	 * Double the custom value.
	 *
	 * @Kind Action
	 * @Covers Component.CustomScriptComponent
	 * @Inputs none
	 * @Return CustomValue * 2
	 */
	UFUNCTION()
	int GetDoubledValue()
	{
		return CustomValue * 2;
	}

	/**
	 * Observe that the default custom value doubles to 84.
	 *
	 * @Kind Observe
	 * @Covers Component.CustomScriptComponent
	 * @Inputs a component whose CustomValue is 42
	 * @Return GetDoubledValue(), expected to be 84
	 */
	UFUNCTION()
	int GetDoubledValueDefault()
	{
		return GetDoubledValue();
	}

	/**
	 * Observe that a zeroed custom value doubles to zero.
	 *
	 * @Kind Observe
	 * @Covers Component.CustomScriptComponent
	 * @Inputs a component whose CustomValue has been set to 0
	 * @Return GetDoubledValue(), expected to be 0
	 * @Boundary zero value
	 */
	UFUNCTION()
	int GetDoubledValueZeroBoundary()
	{
		CustomValue = 0;
		return GetDoubledValue();
	}
}

UCLASS()
class ACoverageComponentCustomScriptActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCustomLogicComponent CustomComp;

	UPROPERTY()
	int RetrievedValue = 0;

	UPROPERTY()
	FString RetrievedName;

	UPROPERTY()
	int DoubledValue = 0;

	/**
	 * WorldStory: BeginPlay copies the value and name off the component and calls
	 * its doubling method.
	 *
	 * @Kind WorldStory
	 * @Covers Component.CustomScriptComponent
	 * @Inputs a default-attached UCustomLogicComponent
	 * @Return RetrievedValue 42, RetrievedName "TestComponent", DoubledValue 84
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (CustomComp != nullptr)
		{
			RetrievedValue = CustomComp.CustomValue;
			RetrievedName = CustomComp.CustomName;
			DoubledValue = CustomComp.GetDoubledValue();
		}
	}

	/**
	 * Observe that a locally constructed actor has retrieved nothing.
	 *
	 * @Kind Observe
	 * @Covers Component.CustomScriptComponent
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when the value is 0, the name is empty and CustomComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (RetrievedValue != 0)
		{
			return false;
		}
		if (RetrievedName.Len() != 0)
		{
			return false;
		}
		if (DoubledValue != 0)
		{
			return false;
		}
		return CustomComp == nullptr;
	}
}
/** @end */
