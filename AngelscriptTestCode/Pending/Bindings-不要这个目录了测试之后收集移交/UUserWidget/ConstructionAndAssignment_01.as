/**
 * @version v1
 * @summary Observe ConstructWidget child creation with default and explicit widget names, including null class identity.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe ConstructWidget child creation with default and explicit widget names, including null class identity.
 * @topic Baseline
 */
// Runner owns the parent widget fixture.
// AS-facing API: UWidget UUserWidget.ConstructWidget(const TSubclassOf<UWidget>& WidgetClass, FName WidgetName = NAME_None);
// Inputs: Runner-owned UUserWidget, UTextBlock::StaticClass() as WidgetClass,
// default WidgetName omission, n"TestSource.Child" as the explicit name, and
// an empty TSubclassOf<UWidget> as the null class.
// Expected observations: ConstructWidget with a valid class returns a non-null
// child whose identity differs from the parent. The named child can be
// distinguished from the default-name child. An empty WidgetClass returns
// null and does not add a tree entry.
// Boundary/ownership: The parent widget tree owns the constructed child.
// WidgetName is an optional stable UObject name, not a Slate label.
// SetupOwner=Runner.

UCLASS()
class UTSUserWidgetConstructProbe : UUserWidget
{
}

namespace TS_UUserWidget_ConstructionAndAssignment_01
{
	bool Observe_ConstructWidget_Nominal(UUserWidget Widget)
	{
		if (Widget is null)
		{
			throw("TS_UUserWidget_ConstructionAndAssignment_01 setup: required Widget is null");
		}
		UWidget DefaultNamed = Widget.ConstructWidget(UTextBlock::StaticClass());
		UWidget ExplicitNamed = Widget.ConstructWidget(UTextBlock::StaticClass(), n"TestSource.Child");
		TSubclassOf<UWidget> EmptyClass;
		UWidget NullChild = Widget.ConstructWidget(EmptyClass);
		UWidget NullNamed = Widget.ConstructWidget(EmptyClass, NAME_None);
		return DefaultNamed != nullptr && DefaultNamed != Widget && ExplicitNamed != nullptr && ExplicitNamed != DefaultNamed && NullChild is null && NullNamed is null;
	}
}
/** @end */
