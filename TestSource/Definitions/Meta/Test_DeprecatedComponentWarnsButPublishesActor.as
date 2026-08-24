// Theme: Definitions.Meta. WorldStory: Deprecated DefaultComponent warns but still compiles and publishes.
// C++: DeprecatedComponentWarnsButPublishesActor; bCompiled true, warning diagnostic, actor class published.
// Extra: default handle is null; DeprecatedRoot present after spawn. FixtureIsolated.

UCLASS(Deprecated)
class UComponentVerifyClassDeprecatedSceneComponent : USceneComponent
{
}

UCLASS()
class AComponentVerifyClassDeprecatedActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UComponentVerifyClassDeprecatedSceneComponent DeprecatedRoot;
}

int Observe_DeprecatedComponent_EmptyDefaultIsNull()
{
	AComponentVerifyClassDeprecatedActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}

bool Observe_DeprecatedComponent_RootPresent(AComponentVerifyClassDeprecatedActor Actor)
{
	return Actor.DeprecatedRoot != nullptr;
}

bool Observe_DeprecatedComponent_AssignAliases()
{
	AComponentVerifyClassDeprecatedActor First;
	AComponentVerifyClassDeprecatedActor Second;
	First = Second;
	return First is Second;
}
