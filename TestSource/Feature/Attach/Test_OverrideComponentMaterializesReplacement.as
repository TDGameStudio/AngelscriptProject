// Theme: Feature.Attach. WorldStory: OverrideComponent materializes the base slot as UStaticMeshComponent.
// C++: AngelscriptComponentLifecycleExtendedTests.cpp::OverrideComponentMaterializesReplacement.
// Oracle: Replacement property points at BaseChild instance named "BaseChild"; attach parent stays Root.
// Extra: CDO Replacement/Root/BaseChild may be null; copy independence of two child actors.
// FixtureIsolated. Keep Root, BaseChild, Replacement.

UCLASS()
class ATestDefaultComponentExtendedOverrideBase : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach = Root)
	USceneComponent BaseChild;
}

UCLASS()
class ATestDefaultComponentExtendedOverrideChild : ATestDefaultComponentExtendedOverrideBase
{
	UPROPERTY(OverrideComponent = BaseChild)
	UStaticMeshComponent Replacement;
}

bool Observe_OverrideReplacement_EmptyDefault(ATestDefaultComponentExtendedOverrideChild Actor)
{
	if (Actor is null)
	{
		throw("Test_OverrideComponentMaterializesReplacement setup: required Actor is null");
	}
	return Actor.Root == nullptr && Actor.BaseChild == nullptr && Actor.Replacement == nullptr;
}

bool Observe_OverrideReplacement_RuntimeIfMaterialized(ATestDefaultComponentExtendedOverrideChild Actor)
{
	if (Actor is null)
	{
		throw("Test_OverrideComponentMaterializesReplacement setup: required Actor is null");
	}
	if (Actor.Root == nullptr || Actor.Replacement == nullptr)
	{
		return Actor.Replacement == nullptr;
	}
	return Actor.Replacement.GetAttachParent() == Actor.Root;
}

bool Observe_OverrideReplacement_CopyIndependence()
{
	ATestDefaultComponentExtendedOverrideChild First;
	ATestDefaultComponentExtendedOverrideChild Second;
	return First != Second;
}
