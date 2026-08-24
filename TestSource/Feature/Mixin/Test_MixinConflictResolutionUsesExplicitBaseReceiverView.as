// Theme: Feature.Mixin. WorldStory explicit parent-typed view selects the parent mixin overload.
// C++: AngelscriptCoverageMixinTests.cpp::MixinConflictResolutionUsesExplicitBaseReceiverView
// Oracle after BeginPlay: ParentViewTrace==1, ChildViewTrace==12, ParentRouteCount==1, ChildRouteCount==1.
// Extra: empty handle null; pre-BeginPlay zeros. FixtureIsolated.

mixin void RouteConflict(ACoverageMixinBaseReceiverParent Self)
{
	Self.RouteTrace = Self.RouteTrace * 10 + 1;
	Self.ParentRouteCount += 1;
}

mixin void RouteConflict(ACoverageMixinBaseReceiverChild Self)
{
	Self.RouteTrace = Self.RouteTrace * 10 + 2;
	Self.ChildRouteCount += 1;
}

UCLASS()
class ACoverageMixinBaseReceiverParent : AActor
{
	UPROPERTY()
	int RouteTrace = 0;

	UPROPERTY()
	int ParentRouteCount = 0;
}

UCLASS()
class ACoverageMixinBaseReceiverChild : ACoverageMixinBaseReceiverParent
{
	UPROPERTY()
	int ChildRouteCount = 0;

	UPROPERTY()
	int ParentViewTrace = 0;

	UPROPERTY()
	int ChildViewTrace = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ACoverageMixinBaseReceiverParent ParentView = Cast<ACoverageMixinBaseReceiverParent>(this);
		if (ParentView != nullptr)
		{
			ParentView.RouteConflict();
			ParentViewTrace = RouteTrace;
		}

		this.RouteConflict();
		ChildViewTrace = RouteTrace;
	}
}

bool Observe_MixinBaseView_EmptyHandleIsNull()
{
	ACoverageMixinBaseReceiverChild Actor;
	return Actor == nullptr;
}

int Observe_MixinBaseView_BeforeBeginPlay(ACoverageMixinBaseReceiverChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0059 setup: required ACoverageMixinBaseReceiverChild is null");
	}
	return Actor.RouteTrace + Actor.ParentRouteCount + Actor.ChildRouteCount + Actor.ParentViewTrace + Actor.ChildViewTrace;
}

bool Observe_MixinBaseView_AfterBeginPlay(ACoverageMixinBaseReceiverChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0059 setup: required ACoverageMixinBaseReceiverChild is null");
	}
	return Actor.ParentViewTrace == 1
		&& Actor.ChildViewTrace == 12
		&& Actor.ParentRouteCount == 1
		&& Actor.ChildRouteCount == 1;
}
