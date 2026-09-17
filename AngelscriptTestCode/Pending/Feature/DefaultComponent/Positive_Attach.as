/**
 * @version v1
 * @summary A RootComponent plus an attached DefaultComponent compiles. Mesh names Root as its Attach parent; a local construct leaves that handle null.
 * @topic Feature
 */
/**
 * @version root
 * @summary A RootComponent plus an attached DefaultComponent compiles. Mesh names Root as its Attach parent; a local construct leaves that handle null.
 * @topic Baseline
 */
namespace DefaultComponentTest
{
	class ADefCompAttachActor : AActor
	{
		UPROPERTY(DefaultComponent, RootComponent)
		USceneComponent Root;

		UPROPERTY(DefaultComponent, Attach = Root)
		UStaticMeshComponent Mesh;

		/**
		 * Observe that a locally constructed actor has no Mesh component.
		 *
		 * @Kind Observe
		 * @Covers DefaultComponent.Positive_Attach
		 * @Inputs an actor that has not been spawned
		 * @Return true when Mesh is null
		 * @Boundary null default component
		 */
		UFUNCTION()
		bool DefaultEmpty()
		{
			return Mesh == nullptr;
		}
	}
}
/** @end */
