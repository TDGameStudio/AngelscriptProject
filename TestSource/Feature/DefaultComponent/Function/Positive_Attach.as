/**
 * A RootComponent plus an attached DefaultComponent compiles. Mesh names Root
 * as its Attach parent; a local construct leaves that handle null.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.Positive_Attach
 * @Harness Function
 * @Tag Feature.DefaultComponent.Positive_Attach
 * @Namespace DefaultComponentTest
 * @Provenance Theme: Feature.DefaultComponent. Positive RootComponent plus Attach DefaultComponent.
 * @Provenance C++: AngelscriptSyntaxDefaultComponentTests.cpp::Positive_Attach
 * @Provenance Oracle: AssertCompiles ADefCompAttachActor. Extra: empty actor is null;
 * @Provenance Mesh default handle is null. FixtureIsolated.
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
