/**
 * An explicit parent-typed view selects the parent mixin overload. C++ expects
 * after BeginPlay: ParentViewTrace==1, ChildViewTrace==12, ParentRouteCount==1,
 * ChildRouteCount==1. The observers cover the empty handle and pre-BeginPlay zeros.
 *
 * @Theme Feature.Mixin
 * @Subject Mixin.MixinConflictResolutionUsesExplicitBaseReceiverView
 * @Harness UClass
 * @Tag Feature.Mixin.MixinConflictResolutionUsesExplicitBaseReceiverView
 * @Provenance Theme: Feature.Mixin. WorldStory explicit parent-typed view selects the parent mixin overload.
 * @Provenance C++: AngelscriptCoverageMixinTests.cpp::MixinConflictResolutionUsesExplicitBaseReceiverView
 * @Provenance Oracle after BeginPlay: ParentViewTrace==1, ChildViewTrace==12, ParentRouteCount==1, ChildRouteCount==1.
 * @Provenance Extra: empty handle null; pre-BeginPlay zeros. FixtureIsolated.
 */

/**
 * Parent-receiver mixin that records a 1 into RouteTrace and counts the parent route.
 *
 * @Kind Mixin
 * @Covers Mixin.MixinConflictResolutionUsesExplicitBaseReceiverView
 * @Inputs the parent actor as Self
 * @Param Self the mixin receiver
 * @Return void; RouteTrace appends 1 and ParentRouteCount increases
 */
mixin void RouteConflict(ACoverageMixinBaseReceiverParent Self)
{
	Self.RouteTrace = Self.RouteTrace * 10 + 1;
	Self.ParentRouteCount += 1;
}

/**
 * Child-receiver mixin that records a 2 into RouteTrace and counts the child route.
 *
 * @Kind Mixin
 * @Covers Mixin.MixinConflictResolutionUsesExplicitBaseReceiverView
 * @Inputs the child actor as Self
 * @Param Self the mixin receiver
 * @Return void; RouteTrace appends 2 and ChildRouteCount increases
 */
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

	/**
	 * WorldStory: a parent-typed view routes 1, then this routes 2, producing traces 1 then 12.
	 *
	 * @Kind WorldStory
	 * @Covers Mixin.MixinConflictResolutionUsesExplicitBaseReceiverView
	 * @Inputs this child cast to ACoverageMixinBaseReceiverParent then this
	 * @Return ParentViewTrace 1, ChildViewTrace 12, both route counts 1
	 */
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

	/**
	 * Observe that an unset child handle is null.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixinConflictResolutionUsesExplicitBaseReceiverView
	 * @Inputs an unset ACoverageMixinBaseReceiverChild handle
	 * @Return true when the handle is null
	 * @Boundary empty handle
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ACoverageMixinBaseReceiverChild Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe that all route counters are zero before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixinConflictResolutionUsesExplicitBaseReceiverView
	 * @Inputs this child before BeginPlay
	 * @Return the sum of RouteTrace, both route counts and both view traces
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	int DefaultsAreZero()
	{
		return RouteTrace + ParentRouteCount + ChildRouteCount + ParentViewTrace + ChildViewTrace;
	}

	/**
	 * Observe the BeginPlay oracle: parent view 1, child view 12, both counts 1.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixinConflictResolutionUsesExplicitBaseReceiverView
	 * @Inputs this child after BeginPlay
	 * @Return true when ParentViewTrace is 1, ChildViewTrace is 12 and both route counts are 1
	 */
	UFUNCTION()
	bool ParentThenChildRouteAfterPlay()
	{
		if (ParentViewTrace != 1)
		{
			return false;
		}
		if (ChildViewTrace != 12)
		{
			return false;
		}
		if (ParentRouteCount != 1)
		{
			return false;
		}
		return ChildRouteCount == 1;
	}
}
