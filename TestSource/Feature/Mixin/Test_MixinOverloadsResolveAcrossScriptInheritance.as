// Theme: Feature.Mixin. WorldStory mixin overloads resolve by receiver type across inheritance.
// C++: AngelscriptCoverageMixinTests.cpp::MixinOverloadsResolveAcrossScriptInheritance
// Oracle: parent RouteValue==10 LayerTotal==2; child RouteValue==20 ChildRouteValue==30 LayerTotal==30 ChildLayerTotal==3;
// grandchild RouteValue==20 ChildRouteValue==30 LayerTotal==40 ChildLayerTotal==4 GrandchildRouteValue==50 GrandchildLayerTotal==44.
// Extra: empty handle null; pre-BeginPlay zeros. FixtureIsolated.

mixin void MarkSource(ACoverageMixinConflictParent Self)
{
	Self.RouteValue = 10;
}

mixin void MarkSource(ACoverageMixinConflictChild Self)
{
	Self.RouteValue = 20;
	Self.ChildRouteValue = 30;
}

mixin void AddLayer(ACoverageMixinConflictParent Self, int Amount)
{
	Self.LayerTotal += Amount;
}

mixin void AddLayer(ACoverageMixinConflictChild Self, int Amount)
{
	Self.LayerTotal += Amount * 10;
	Self.ChildLayerTotal += Amount;
}

UCLASS()
class ACoverageMixinConflictParent : AActor
{
	UPROPERTY()
	int RouteValue = 0;

	UPROPERTY()
	int LayerTotal = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		this.MarkSource();
		this.AddLayer(2);
	}
}

UCLASS()
class ACoverageMixinConflictChild : ACoverageMixinConflictParent
{
	UPROPERTY()
	int ChildRouteValue = 0;

	UPROPERTY()
	int ChildLayerTotal = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		this.MarkSource();
		this.AddLayer(3);
	}
}

UCLASS()
class ACoverageMixinConflictGrandchild : ACoverageMixinConflictChild
{
	UPROPERTY()
	int GrandchildRouteValue = 0;

	UPROPERTY()
	int GrandchildLayerTotal = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// A grandchild descends from BOTH receiver types, so an auto-dispatched
		// `this.MarkSource()` is ambiguous (AS overload resolution does not rank by
		// inheritance distance when neither overload is an exact match). Select the
		// nearest (child) overload through an explicit child-typed receiver view.
		ACoverageMixinConflictChild ChildView = this;
		ChildView.MarkSource();
		ChildView.AddLayer(4);
		GrandchildRouteValue = ChildRouteValue + RouteValue;
		GrandchildLayerTotal = ChildLayerTotal + LayerTotal;
	}
}

bool Observe_MixinOverload_EmptyHandleIsNull()
{
	ACoverageMixinConflictGrandchild Actor;
	return Actor == nullptr;
}

bool Observe_MixinOverload_ParentAfterBeginPlay(ACoverageMixinConflictParent Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0058 setup: required ACoverageMixinConflictParent is null");
	}
	return Actor.RouteValue == 10 && Actor.LayerTotal == 2;
}

bool Observe_MixinOverload_ChildAfterBeginPlay(ACoverageMixinConflictChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0058 setup: required ACoverageMixinConflictChild is null");
	}
	return Actor.RouteValue == 20
		&& Actor.ChildRouteValue == 30
		&& Actor.LayerTotal == 30
		&& Actor.ChildLayerTotal == 3;
}

bool Observe_MixinOverload_GrandchildAfterBeginPlay(ACoverageMixinConflictGrandchild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0058 setup: required ACoverageMixinConflictGrandchild is null");
	}
	return Actor.RouteValue == 20
		&& Actor.ChildRouteValue == 30
		&& Actor.LayerTotal == 40
		&& Actor.ChildLayerTotal == 4
		&& Actor.GrandchildRouteValue == 50
		&& Actor.GrandchildLayerTotal == 44;
}

int Observe_MixinOverload_BeforeBeginPlay(ACoverageMixinConflictGrandchild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0058 setup: required ACoverageMixinConflictGrandchild is null");
	}
	return Actor.RouteValue + Actor.LayerTotal + Actor.GrandchildRouteValue;
}
