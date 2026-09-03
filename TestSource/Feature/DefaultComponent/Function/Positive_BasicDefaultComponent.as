/**
 * A basic DefaultComponent on an actor compiles. Root is a scene component
 * created with the actor; a local construct leaves that handle null.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.Positive_BasicDefaultComponent
 * @Harness Function
 * @Tag Feature.DefaultComponent.Positive_BasicDefaultComponent
 * @Namespace DefaultComponentTest
 * @Provenance Theme: Feature.DefaultComponent. Positive basic DefaultComponent compiles.
 * @Provenance C++: AngelscriptSyntaxDefaultComponentTests.cpp::Positive_BasicDefaultComponent
 * @Provenance Oracle: AssertCompiles ADefCompBasicActor.
 * @Provenance Extra: empty actor is null; Root default handle is null. FixtureIsolated.
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
