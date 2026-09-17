/**
 * @version v1
 * @summary Not TSet API. Kept here until moved.
 * @topic Containers
 */
/**
 * @version root
 * @summary Not TSet API. Kept here until moved.
 * @topic Negative
 */
// Isolate the failing pawn. DiagnosticOnly.

UCLASS()
class AInputSetupPawn : APawn
{
	UPROPERTY()
	bool InputComponentReceived = false;

	UPROPERTY()
	bool InputComponentValid = false;

	UFUNCTION(BlueprintOverride)
	void SetupPlayerInputComponent(UInputComponent PlayerInputComponent)
	{
		InputComponentReceived = true;
		InputComponentValid = (PlayerInputComponent != nullptr);
	}
}
/** @end */
