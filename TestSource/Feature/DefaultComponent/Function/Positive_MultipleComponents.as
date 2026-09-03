/**
 * Two children attached to one root compile. Child1 and Child2 both name Root
 * as their Attach parent; a local construct leaves those handles null.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.Positive_MultipleComponents
 * @Harness Function
 * @Tag Feature.DefaultComponent.Positive_MultipleComponents
 * @Namespace DefaultComponentTest
 * @Provenance Theme: Feature.DefaultComponent. Positive two children attached to one root.
 * @Provenance C++: AngelscriptSyntaxDefaultComponentTests.cpp::Positive_MultipleComponents
 * @Provenance Oracle: AssertCompiles ADefCompMultiActor. Extra: empty actor is null;
 * @Provenance Child1/Child2 default handles are null. FixtureIsolated.
 */

namespace DefaultComponentTest
{
	class ADefCompMultiActor : AActor
	{
		UPROPERTY(DefaultComponent, RootComponent)
		USceneComponent Root;

		UPROPERTY(DefaultComponent, Attach = Root)
		USceneComponent Child1;

		UPROPERTY(DefaultComponent, Attach = Root)
		USceneComponent Child2;

		/**
		 * Observe that a locally constructed actor has neither child component.
		 *
		 * @Kind Observe
		 * @Covers DefaultComponent.Positive_MultipleComponents
		 * @Inputs an actor that has not been spawned
		 * @Return true when Child1 and Child2 are null
		 * @Boundary null default components
		 */
		UFUNCTION()
		bool DefaultEmpty()
		{
			if (Child1 != nullptr)
			{
				return false;
			}
			return Child2 == nullptr;
		}
	}
}
