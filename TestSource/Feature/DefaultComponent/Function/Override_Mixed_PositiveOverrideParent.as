/**
 * OverrideComponent from a parent Root compiles as a script class pair. The
 * child replaces Root with a static mesh; a local construct leaves that handle
 * null. C++ AssertCompiles is currently #if 0 (#as-engine-behavior).
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.Override_Mixed_PositiveOverrideParent
 * @Harness Function
 * @Tag Feature.DefaultComponent.Override_Mixed_PositiveOverrideParent
 * @Namespace DefaultComponentTest
 * @Provenance Theme: Feature.DefaultComponent. OverrideComponent from parent Root.
 * @Provenance C++: AngelscriptSyntaxDefaultComponentTests.cpp::Override_Mixed_PositiveOverrideParent
 * @Provenance Oracle: C++ AssertCompiles (currently #if 0, #as-engine-behavior feature-not-supported).
 * @Provenance Extra: empty child actor is null; Root default handle is null. FixtureIsolated.
 */

namespace DefaultComponentTest
{
	class ADefCompBaseActor : AActor
	{
		UPROPERTY(DefaultComponent, RootComponent)
		USceneComponent Root;
	}

	class ADefCompChildActor : ADefCompBaseActor
	{
		UPROPERTY(OverrideComponent = Root)
		UStaticMeshComponent Root;

		/**
		 * Observe that a locally constructed child has no Root component.
		 *
		 * @Kind Observe
		 * @Covers DefaultComponent.Override_Mixed_PositiveOverrideParent
		 * @Inputs a child actor that has not been spawned
		 * @Return true when Root is null
		 * @Boundary null override component
		 */
		UFUNCTION()
		bool DefaultEmpty()
		{
			return Root == nullptr;
		}
	}
}
