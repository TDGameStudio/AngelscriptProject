/**
 * @version v1
 * @summary Observe scene-component child counts, typed child lookup, world transform, and velocity queries.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe scene-component child counts, typed child lookup, world transform, and velocity queries.
 * @topic Baseline
 */
// Runner owns the Component fixture.
// AS-facing API: int32 USceneComponent.GetNumChildrenComponents() const;
// USceneComponent USceneComponent.GetChildComponentByClass(TSubclassOf<USceneComponent> ComponentClass);
// void USceneComponent.GetChildrenComponentsByClass(UClass ComponentClass, bool bIncludeAllDescendants, ?& OutChildren);
// FTransform USceneComponent.GetComponentTransform() const;
// FVector USceneComponent.GetComponentVelocity() const;
// Inputs: Runner-owned USceneComponent, expected child count, expected child
// handle, USceneComponent class, bIncludeAllDescendants false and true, a
// sentinel OutChildren entry, expected transform, and expected velocity.
// Expected observations: returned bool is the exact comparison. OutChildren
// keeps a sentinel at index 0 (append-without-clear).
// Boundary/ownership: OutChildren element type matches ComponentClass.
// SetupOwner=Runner.

namespace TS_USceneComponent_Queries_01
{
	bool Observe_GetNumChildrenComponents_Nominal(USceneComponent Component, int32 ExpectedCount)
	{
		if (Component is null)
		{
			throw("TS_USceneComponent_Queries_01 setup: required Component is null");
		}
		return Component.GetNumChildrenComponents() == ExpectedCount;
	}

	bool Observe_GetChildComponentByClass_Nominal(USceneComponent Component, USceneComponent Expected)
	{
		if (Component is null)
		{
			throw("TS_USceneComponent_Queries_01 setup: required Component is null");
		}
		TSubclassOf<USceneComponent> SceneClass = USceneComponent::StaticClass();
		USceneComponent Child = Component.GetChildComponentByClass(SceneClass);
		TSubclassOf<USceneComponent> SphereClass = USphereComponent::StaticClass();
		USceneComponent SphereChild = Component.GetChildComponentByClass(SphereClass);
		return Child == Expected && SphereChild is null;
	}

	bool Observe_GetChildrenComponentsByClass_Nominal(USceneComponent Component, USceneComponent Sentinel)
	{
		if (Component is null)
		{
			throw("TS_USceneComponent_Queries_01 setup: required Component is null");
		}
		TArray<USceneComponent> Direct;
		Direct.Add(Sentinel);
		int32 SeededNum = Direct.Num();
		Component.GetChildrenComponentsByClass(USceneComponent::StaticClass(), false, Direct);
		TArray<USceneComponent> Descendants;
		Descendants.Add(Sentinel);
		int32 DescendantBefore = Descendants.Num();
		Component.GetChildrenComponentsByClass(USceneComponent::StaticClass(), true, Descendants);
		return Direct.Num() >= SeededNum && Direct[0] == Sentinel && Descendants.Num() >= DescendantBefore && Descendants[0] == Sentinel;
	}

	bool Observe_GetComponentTransform_Nominal(USceneComponent Component, const FTransform& Expected)
	{
		if (Component is null)
		{
			throw("TS_USceneComponent_Queries_01 setup: required Component is null");
		}
		return Component.GetComponentTransform().Equals(Expected);
	}

	bool Observe_GetComponentVelocity_Nominal(USceneComponent Component, const FVector& Expected)
	{
		if (Component is null)
		{
			throw("TS_USceneComponent_Queries_01 setup: required Component is null");
		}
		return Component.GetComponentVelocity().Equals(Expected);
	}
}
/** @end */
