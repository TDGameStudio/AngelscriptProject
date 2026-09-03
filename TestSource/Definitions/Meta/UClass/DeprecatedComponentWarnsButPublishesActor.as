/**
 * A Deprecated DefaultComponent warns but still compiles and publishes. The actor
 * class is published with DeprecatedRoot present after spawn.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.DeprecatedComponentWarnsButPublishesActor
 * @Harness UClass
 * @Tag Definitions.Meta.DeprecatedComponentWarnsButPublishesActor
 * @Provenance Theme: Definitions.Meta. WorldStory: Deprecated DefaultComponent warns but still compiles and publishes.
 * @Provenance C++: DeprecatedComponentWarnsButPublishesActor; bCompiled true, warning diagnostic, actor class published.
 * @Provenance Extra: default handle is null; DeprecatedRoot present after spawn. FixtureIsolated.
 */

UCLASS(Deprecated)
class UComponentVerifyClassDeprecatedSceneComponent : USceneComponent
{
}

UCLASS()
class AComponentVerifyClassDeprecatedActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UComponentVerifyClassDeprecatedSceneComponent DeprecatedRoot;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Meta.DeprecatedComponentWarnsButPublishesActor
	 * @Inputs an unset actor handle
	 * @Return 1 when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	int EmptyDefaultIsNull()
	{
		AComponentVerifyClassDeprecatedActor Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that DeprecatedRoot is present after spawn.
	 *
	 * @Kind Observe
	 * @Covers Meta.DeprecatedComponentWarnsButPublishesActor
	 * @Inputs none
	 * @Return true when DeprecatedRoot is not null
	 */
	UFUNCTION()
	bool RootPresent()
	{
		return DeprecatedRoot != nullptr;
	}

	/**
	 * Observe that assigning one unset handle aliases the other.
	 *
	 * @Kind Observe
	 * @Covers Meta.DeprecatedComponentWarnsButPublishesActor
	 * @Inputs none
	 * @Return true when the assigned handles compare identical
	 * @Boundary assign aliases
	 */
	UFUNCTION()
	bool AssignAliases()
	{
		AComponentVerifyClassDeprecatedActor First;
		AComponentVerifyClassDeprecatedActor Second;
		First = Second;
		return First is Second;
	}
}
