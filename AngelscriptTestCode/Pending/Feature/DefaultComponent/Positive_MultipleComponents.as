/**
 * @version v1
 * @summary Two children attached to one root compile. Child1 and Child2 both name Root as their Attach parent; a local construct leaves those handles null.
 * @topic Feature
 */
/**
 * @version root
 * @summary Two children attached to one root compile. Child1 and Child2 both name Root as their Attach parent; a local construct leaves those handles null.
 * @topic Baseline
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
/** @end */
