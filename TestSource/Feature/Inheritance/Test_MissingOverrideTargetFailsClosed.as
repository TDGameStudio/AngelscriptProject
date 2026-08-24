// Theme: Feature.Inheritance. Isolated compile-fail: OverrideComponent target missing on the base.
// C++: AngelscriptComponentMetadataValidationTests.cpp::MissingOverrideTargetFailsClosed
// Observation.bCompiled false. Expected diagnostic:
// "OverrideComponent ADerivedOverrideMissing::ReplacementRoot could not find component MissingScene in base class to override."
// DiagnosticOnly. Do not drop OverrideComponent = MissingScene; that would make the program compile.

UCLASS()
class UBaseOverrideMissingRoot : USceneComponent
{
}

UCLASS()
class UDerivedOverrideMissingRoot : UBaseOverrideMissingRoot
{
}

UCLASS()
class ABaseOverrideMissing : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UBaseOverrideMissingRoot RootScene;
}

UCLASS()
class ADerivedOverrideMissing : ABaseOverrideMissing
{
	UPROPERTY(OverrideComponent = MissingScene)
	UDerivedOverrideMissingRoot ReplacementRoot;
}
