/**
 * @version v1
 * @summary USceneComponent host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic USceneComponent
 *
 * scope
 * fscopedmovementupdate-borrows-component
 * set-relative-location
 * set-relative-rotation
 * set-component-velocity
 * set-sphere-radius
 * get-num-children-components
 * get-child-component-by-class
 * get-children-components-by-class
 * get-component-transform
 * get-component-velocity
 */
/**
 * @begin scope
 * @summary AS-facing API:
 * @topic Unreal
 */
/**
 * @function ObserveScopeNominal
 * @summary AS-facing API:
 * @covers USceneComponent.scope
 * @inputs USceneComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

 FScopedMovementUpdate Scope(USceneComponent Component);
// Inputs: Runner-owned USceneComponent and a relative location written while
// the scope is alive.
// Expected observations: SetRelativeLocation issued inside the scope still
// executes. After the scope leaves, GetLocation X is 10.
// Boundary/ownership: The scope borrows the component. Nested construction is
// not required. Destroying the value is the lifecycle boundary.
// SetupOwner=Runner.
bool ObserveScopeNominal(USceneComponent Component)
{
	if (Component is null)
	{
		throw("TS_USceneComponent_Behavior_01 setup: required Component is null");
	}
	FVector Target(10.0, 0.0, 0.0);
	{
		FScopedMovementUpdate Scope(Component);
		Component.SetRelativeLocation(Target);
	}
	FVector After = Component.GetComponentTransform().GetLocation();
	Component.SetRelativeLocation(FVector::ZeroVector);
	return After.X == 10.0;
}
/** @end */
/**
 * @begin fscopedmovementupdate-borrows-component
 * @summary FScopedMovementUpdate borrows the component.
 * @topic Unreal
 */
/**
 * @function ObserveSurface010Nominal
 * @summary FScopedMovementUpdate borrows the component.
 * @covers USceneComponent.fscopedmovementupdate-borrows-component
 * @inputs USceneComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface010Nominal(USceneComponent Component)
{
	if (Component is null)
	{
		throw("TS_USceneComponent_ConstructionAndAssignment_01 setup: required Component is null");
	}
	FScopedMovementUpdate Scope(Component);
	return IsValid(Component) && Component.GetNumChildrenComponents() >= 0;
}
/** @end */
/**
 * @begin set-relative-location
 * @summary space UU/s.
 * @topic Unreal
 */
/**
 * @function ObserveSetRelativeLocationNominal
 * @summary space UU/s.
 * @covers USceneComponent.set-relative-location
 * @inputs USceneComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetRelativeLocationNominal(USceneComponent Component)
{
	if (Component is null)
	{
		throw("TS_USceneComponent_MutationAndLifecycle_01 setup: required Component is null");
	}
	Component.SetRelativeLocation(FVector(10.0, 0.0, 0.0));
	FVector After = Component.GetComponentTransform().GetLocation();
	Component.SetRelativeLocation(FVector::ZeroVector);
	return After.X == 10.0;
}
/** @end */
/**
 * @begin set-relative-rotation
 * @summary space UU/s.
 * @topic Unreal
 */
/**
 * @function ObserveSetRelativeRotationNominal
 * @summary space UU/s.
 * @covers USceneComponent.set-relative-rotation
 * @inputs USceneComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetRelativeRotationNominal(USceneComponent Component)
{
	if (Component is null)
	{
		throw("TS_USceneComponent_MutationAndLifecycle_01 setup: required Component is null");
	}
	Component.SetRelativeRotation(FRotator(0.0, 90.0, 0.0));
	FRotator After = Component.GetComponentTransform().Rotator();
	Component.SetRelativeRotation(FRotator::ZeroRotator);
	return After.Equals(FRotator(0.0, 90.0, 0.0), 0.01);
}
/** @end */
/**
 * @begin set-component-velocity
 * @summary space UU/s.
 * @topic Unreal
 */
/**
 * @function ObserveSetComponentVelocityNominal
 * @summary space UU/s.
 * @covers USceneComponent.set-component-velocity
 * @inputs USceneComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetComponentVelocityNominal(USceneComponent Component)
{
	if (Component is null)
	{
		throw("TS_USceneComponent_MutationAndLifecycle_01 setup: required Component is null");
	}
	FVector Velocity(0.0, 0.0, 100.0);
	Component.SetComponentVelocity(Velocity);
	FVector After = Component.GetComponentVelocity();
	Component.SetComponentVelocity(FVector::ZeroVector);
	FVector Cleared = Component.GetComponentVelocity();
	return After.Equals(Velocity) && Cleared.IsNearlyZero();
}
/** @end */
/**
 * @begin set-sphere-radius
 * @summary space UU/s.
 * @topic Unreal
 */
/**
 * @function ObserveSetSphereRadiusNominal
 * @summary space UU/s.
 * @covers USceneComponent.set-sphere-radius
 * @inputs USceneComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetSphereRadiusNominal(USphereComponent Sphere)
{
	if (Sphere is null)
	{
		throw("TS_USceneComponent_MutationAndLifecycle_01 setup: required Sphere is null");
	}
	Sphere.SetSphereRadius(32.0);
	FVector ExtentsDefault = Sphere.GetBoundingBoxExtents();
	Sphere.SetSphereRadius(16.0, true);
	FVector ExtentsOverlap = Sphere.GetBoundingBoxExtents();
	Sphere.SetSphereRadius(8.0, false);
	FVector ExtentsNoOverlap = Sphere.GetBoundingBoxExtents();
	return ExtentsDefault.X == 32.0 && ExtentsOverlap.X == 16.0 && ExtentsNoOverlap.X == 8.0;
}
/** @end */
/**
 * @begin get-num-children-components
 * @summary keeps a sentinel at
 * @topic Unreal
 */
/**
 * @function ObserveGetNumChildrenComponentsNominal
 * @summary keeps a sentinel at
 * @covers USceneComponent.get-num-children-components
 * @inputs USceneComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
// keeps a sentinel at

 index 0 (append-without-clear).
// Boundary/ownership: OutChildren element type matches ComponentClass.
// SetupOwner=Runner.
bool ObserveGetNumChildrenComponentsNominal(USceneComponent Component, int32 ExpectedCount)
{
	if (Component is null)
	{
		throw("TS_USceneComponent_Queries_01 setup: required Component is null");
	}
	return Component.GetNumChildrenComponents() == ExpectedCount;
}
/** @end */
/**
 * @begin get-child-component-by-class
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveGetChildComponentByClassNominal
 * @summary SetupOwner=Runner.
 * @covers USceneComponent.get-child-component-by-class
 * @inputs USceneComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
// keeps a sentinel at

bool ObserveGetChildComponentByClassNominal(USceneComponent Component, USceneComponent Expected)
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
/** @end */
/**
 * @begin get-children-components-by-class
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveGetChildrenComponentsByClassNominal
 * @summary SetupOwner=Runner.
 * @covers USceneComponent.get-children-components-by-class
 * @inputs USceneComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
// keeps a sentinel at

bool ObserveGetChildrenComponentsByClassNominal(USceneComponent Component, USceneComponent Sentinel)
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
/** @end */
/**
 * @begin get-component-transform
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveGetComponentTransformNominal
 * @summary SetupOwner=Runner.
 * @covers USceneComponent.get-component-transform
 * @inputs USceneComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
// keeps a sentinel at

bool ObserveGetComponentTransformNominal(USceneComponent Component, const FTransform& Expected)
{
	if (Component is null)
	{
		throw("TS_USceneComponent_Queries_01 setup: required Component is null");
	}
	return Component.GetComponentTransform().Equals(Expected);
}
/** @end */
/**
 * @begin get-component-velocity
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveGetComponentVelocityNominal
 * @summary SetupOwner=Runner.
 * @covers USceneComponent.get-component-velocity
 * @inputs USceneComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
// keeps a sentinel at

bool ObserveGetComponentVelocityNominal(USceneComponent Component, const FVector& Expected)
{
	if (Component is null)
	{
		throw("TS_USceneComponent_Queries_01 setup: required Component is null");
	}
	return Component.GetComponentVelocity().Equals(Expected);
}
/** @end */
