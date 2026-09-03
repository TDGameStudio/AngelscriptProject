/**
 * OverrideComponent materializes the base slot as UStaticMeshComponent. C++ verifies the
 * Replacement property, so Root, BaseChild and Replacement are part of the contract and
 * are kept verbatim.
 *
 * @Theme Feature.Attach
 * @Subject Attach.OverrideComponentMaterializesReplacement
 * @Harness UClass
 * @Tag Feature.Attach.OverrideComponentMaterializesReplacement
 * @Provenance Theme: Feature.Attach. WorldStory: OverrideComponent materializes the base slot as UStaticMeshComponent.
 * @Provenance C++: AngelscriptComponentLifecycleExtendedTests.cpp::OverrideComponentMaterializesReplacement.
 * @Provenance Oracle: Replacement property points at BaseChild instance named "BaseChild"; attach parent stays Root.
 * @Provenance Extra: CDO Replacement/Root/BaseChild may be null; copy independence of two child actors.
 * @Provenance FixtureIsolated. Keep Root, BaseChild, Replacement.
 */

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

	/**
	 * Observe that CDO component pointers are null.
	 *
	 * @Kind Observe
	 * @Covers Attach.OverrideComponentMaterializesReplacement
	 * @Inputs none
	 * @Return true when Root, BaseChild and Replacement are null
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool EmptyDefault()
	{
		if (Root != nullptr)
		{
			return false;
		}
		if (BaseChild != nullptr)
		{
			return false;
		}
		return Replacement == nullptr;
	}

	/**
	 * Observe that a materialized Replacement attaches to Root, or stays null.
	 *
	 * @Kind Observe
	 * @Covers Attach.OverrideComponentMaterializesReplacement
	 * @Inputs none
	 * @Return true when Replacement is null or attached to Root
	 */
	UFUNCTION()
	bool RuntimeIfMaterialized()
	{
		if (Root == nullptr || Replacement == nullptr)
		{
			return Replacement == nullptr;
		}
		return Replacement.GetAttachParent() == Root;
	}

	/**
	 * Observe that two constructed child actors are distinct objects.
	 *
	 * @Kind Observe
	 * @Covers Attach.OverrideComponentMaterializesReplacement
	 * @Inputs a second actor
	 * @Return true when this is not the same object as Second
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestDefaultComponentExtendedOverrideChild Second)
	{
		if (Second is null)
		{
			throw("OverrideComponentMaterializesReplacement setup: required Second is null");
		}
		return this != Second;
	}
}
