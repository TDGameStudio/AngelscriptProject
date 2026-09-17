/**
 * @version v1
 * @summary A basic DefaultComponent on an actor compiles. Root is a scene component created with the actor; a local construct leaves that handle null.
 * @topic Feature
 */
/**
 * @version root
 * @summary A basic DefaultComponent on an actor compiles. Root is a scene component created with the actor; a local construct leaves that handle null.
 * @topic Baseline
 */
namespace DefaultComponentTest
{
	class ADefCompBasicActor : AActor
	{
		UPROPERTY(DefaultComponent)
		USceneComponent Root;

		/**
		 * Observe that a locally constructed actor has no Root component.
		 *
		 * @Kind Observe
		 * @Covers DefaultComponent.Positive_BasicDefaultComponent
		 * @Inputs an actor that has not been spawned
		 * @Return true when Root is null
		 * @Boundary null default component
		 */
		UFUNCTION()
		bool DefaultEmpty()
		{
			return Root == nullptr;
		}
	}
}
/** @end */
