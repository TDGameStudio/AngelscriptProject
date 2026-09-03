/**
 * An empty UUserWidget subclass used as the WidgetTree runtime fixture. C++
 * compiles the class, injects a tree script against a transient instance, and
 * checks that the native tree is empty afterwards, so the class name is part of
 * the contract and is kept verbatim. The empty class is the default vector.
 *
 * @Theme Gameplay.Widget
 * @Subject Widget.WidgetTreeRuntimeOperations
 * @Harness UClass
 * @Tag Gameplay.Widget.WidgetTreeRuntimeOperations
 * @Provenance Theme: Gameplay.Widget. Positive empty UUserWidget subclass for WidgetTree ops.
 * @Provenance C++: AngelscriptCoverageWidgetTests.cpp::WidgetTreeRuntimeOperations block 1.
 * @Provenance Oracle: UCoverageRuntimeWidget compiles; native postcondition is no root / empty tree
 * @Provenance after the injected tree script. Extra: empty class is the default vector. DefaultSafe.
 */

UCLASS()
class UCoverageRuntimeWidget : UUserWidget
{
}
