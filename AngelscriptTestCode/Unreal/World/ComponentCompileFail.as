/**
 * @version v1
 * @summary World component forms that do not compile.
 * @topic Unreal
 * @topic World
 *
 * input-component-finding
 */
/**
 * @begin input-component-finding
 * @summary FindComponentByClass taking a UClass argument is not available, so this program is rejected. The failing call is isolated inside BeginPlay; no extra declaration may be added that would compile the failure away.
 * @topic Negative
 */
UCLASS()
class AInputComponentFindingPawn : APawn
{
	UPROPERTY()
	bool FoundInputComponent = false;

	/**
	 * The isolated failing program: the UClass overload of FindComponentByClass
	 * has no matching signature.
	 *
	 * @Kind WorldStory
	 * @Covers Component.InputComponentFinding
	 * @Inputs FindComponentByClass(UInputComponent::StaticClass())
	 * @Return does not compile; "No matching signatures to 'FindComponentByClass(UClass)'"
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Expected diagnostic: No matching signatures to 'FindComponentByClass(UClass)'
		UInputComponent InputComp = Cast<UInputComponent>(FindComponentByClass(UInputComponent::StaticClass()));
		FoundInputComponent = (InputComp != nullptr);
	}
}
/** @end */
