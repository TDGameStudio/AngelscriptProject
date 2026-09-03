/**
 * An empty UUserWidget subclass used as the runtime API fixture class. C++
 * compiles it in BEFORE_ALL and then constructs named widgets from it, so the
 * class name is part of the contract and is kept verbatim. The empty class is
 * the default vector.
 *
 * @Theme Gameplay.Widget
 * @Subject Widget.RuntimeApiWidget
 * @Harness UClass
 * @Tag Gameplay.Widget.RuntimeApiWidget
 * @Provenance Theme: Gameplay.Widget. Positive empty UUserWidget subclass for runtime API fixture.
 * @Provenance C++: AngelscriptCoverageWidgetTests.cpp::FAngelscriptCoverageWidgetRuntimeApiTest BEFORE_ALL.
 * @Provenance Oracle: UCoverageRuntimeApiWidget compiles as the RuntimeApi fixture class.
 * @Provenance Extra: empty class is the default vector. DefaultSafe.
 */

UCLASS()
class UCoverageRuntimeApiWidget : UUserWidget
{
}
