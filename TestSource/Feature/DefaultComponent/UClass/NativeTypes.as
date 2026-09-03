/**
 * A native UStaticMeshComponent root plus an attached billboard. C++ spawns the
 * actor and checks that Billboard's attach parent is the native mesh root. The
 * observer covers the local construct default.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.NativeTypes
 * @Harness UClass
 * @Tag Feature.DefaultComponent.NativeTypes
 * @Provenance Theme: Feature.DefaultComponent. WorldStory native UStaticMeshComponent root plus billboard.
 * @Provenance C++: AngelscriptComponentTests.cpp::NativeTypes
 * @Provenance Oracle after spawn: Billboard attach parent is the native mesh root.
 * @Provenance Extra: empty actor is null; Mesh/Billboard default handles are null. FixtureIsolated.
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
