/**
 * @version v1
 * @summary OverrideComponent naming a base component that does not exist is rejected. The isolated failure is OverrideComponent = MissingScene; dropping that specifier would make the program compile.
 * @topic Feature
 */
/**
 * @version root
 * @summary OverrideComponent naming a base component that does not exist is rejected. The isolated failure is OverrideComponent = MissingScene; dropping that specifier would make the program compile.
 * @topic Negative
 */
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
/** @end */
