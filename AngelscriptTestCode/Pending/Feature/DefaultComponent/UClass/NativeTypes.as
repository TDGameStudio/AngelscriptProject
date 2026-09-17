/**
 * @version v1
 * @summary A native UStaticMeshComponent root plus an attached billboard. C++ spawns the actor and checks that Billboard's attach parent is the native mesh root. The observer covers the local construct default.
 * @topic Feature
 */
/**
 * @version root
 * @summary A native UStaticMeshComponent root plus an attached billboard. C++ spawns the actor and checks that Billboard's attach parent is the native mesh root. The observer covers the local construct default.
 * @topic Baseline
 */
UCLASS()
class ATestDefaultComponentNativeTypes : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UStaticMeshComponent Mesh;

	UPROPERTY(DefaultComponent, Attach = Mesh)
	UBillboardComponent Billboard;

	/**
	 * Observe that a locally constructed actor has neither Mesh nor Billboard.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.NativeTypes
	 * @Inputs an actor that has not been spawned
	 * @Return true when Mesh and Billboard are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (Mesh != nullptr)
		{
			return false;
		}
		return Billboard == nullptr;
	}
}
/** @end */
