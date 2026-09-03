/**
 * Mixin overloads resolve by receiver type across script inheritance. C++
 * expects parent RouteValue==10 LayerTotal==2; child RouteValue==20
 * ChildRouteValue==30 LayerTotal==30 ChildLayerTotal==3; grandchild RouteValue==20
 * ChildRouteValue==30 LayerTotal==40 ChildLayerTotal==4 GrandchildRouteValue==50
 * GrandchildLayerTotal==44. The observers cover the empty handle and pre-BeginPlay zeros.
 *
 * @Theme Feature.Mixin
 * @Subject Mixin.MixinOverloadsResolveAcrossScriptInheritance
 * @Harness UClass
 * @Tag Feature.Mixin.MixinOverloadsResolveAcrossScriptInheritance
 * @Provenance Theme: Feature.Mixin. WorldStory mixin overloads resolve by receiver type across inheritance.
 * @Provenance C++: AngelscriptCoverageMixinTests.cpp::MixinOverloadsResolveAcrossScriptInheritance
 * @Provenance Oracle: parent RouteValue==10 LayerTotal==2; child RouteValue==20 ChildRouteValue==30 LayerTotal==30 ChildLayerTotal==3;
 * @Provenance grandchild RouteValue==20 ChildRouteValue==30 LayerTotal==40 ChildLayerTotal==4 GrandchildRouteValue==50 GrandchildLayerTotal==44.
 * @Provenance Extra: empty handle null; pre-BeginPlay zeros. FixtureIsolated.
 */

/**
 * Parent-receiver mixin that sets RouteValue to 10.
 *
 * @Kind Mixin
 * @Covers Mixin.MixinOverloadsResolveAcrossScriptInheritance
 * @Inputs the parent actor as Self
 * @Param Self the mixin receiver
 * @Return void; Self.RouteValue becomes 10
 */
mixin void MarkSource(ACoverageMixinConflictParent Self)
{
	Self.RouteValue = 10;
}

/**
 * Child-receiver mixin that sets RouteValue to 20 and ChildRouteValue to 30.
 *
 * @Kind Mixin
 * @Covers Mixin.MixinOverloadsResolveAcrossScriptInheritance
 * @Inputs the child actor as Self
 * @Param Self the mixin receiver
 * @Return void; Self.RouteValue becomes 20 and Self.ChildRouteValue becomes 30
 */
mixin void MarkSource(ACoverageMixinConflictChild Self)
{
	Self.RouteValue = 20;
	Self.ChildRouteValue = 30;
}

/**
 * Parent-receiver mixin that adds Amount to LayerTotal.
 *
 * @Kind Mixin
 * @Covers Mixin.MixinOverloadsResolveAcrossScriptInheritance
 * @Inputs the parent actor and an amount
 * @Param Self the mixin receiver
 * @Param Amount added to LayerTotal
 * @Return void; Self.LayerTotal increases by Amount
 */
mixin void AddLayer(ACoverageMixinConflictParent Self, int Amount)
{
	Self.LayerTotal += Amount;
}

/**
 * Child-receiver mixin that adds Amount*10 to LayerTotal and Amount to ChildLayerTotal.
 *
 * @Kind Mixin
 * @Covers Mixin.MixinOverloadsResolveAcrossScriptInheritance
 * @Inputs the child actor and an amount
 * @Param Self the mixin receiver
 * @Param Amount scaled onto LayerTotal and added to ChildLayerTotal
 * @Return void; Self.LayerTotal increases by Amount*10 and Self.ChildLayerTotal by Amount
 */
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

	/**
	 * WorldStory: MarkSource and AddLayer(2) on the parent receiver.
	 *
	 * @Kind WorldStory
	 * @Covers Mixin.MixinOverloadsResolveAcrossScriptInheritance
	 * @Inputs none
	 * @Return RouteValue 10, LayerTotal 2
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		this.MarkSource();
		this.AddLayer(2);
	}

	/**
	 * Observe the parent BeginPlay oracle: RouteValue 10 and LayerTotal 2.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixinOverloadsResolveAcrossScriptInheritance
	 * @Inputs this parent after BeginPlay
	 * @Return true when RouteValue is 10 and LayerTotal is 2
	 */
	UFUNCTION()
	bool ParentRouteAfterPlay()
	{
		if (RouteValue != 10)
		{
			return false;
		}
		return LayerTotal == 2;
	}
}

UCLASS()
class ACoverageMixinConflictChild : ACoverageMixinConflictParent
{
	UPROPERTY()
	int ChildRouteValue = 0;

	UPROPERTY()
	int ChildLayerTotal = 0;

	/**
	 * WorldStory: MarkSource and AddLayer(3) on the child receiver.
	 *
	 * @Kind WorldStory
	 * @Covers Mixin.MixinOverloadsResolveAcrossScriptInheritance
	 * @Inputs none
	 * @Return RouteValue 20, ChildRouteValue 30, LayerTotal 30, ChildLayerTotal 3
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		this.MarkSource();
		this.AddLayer(3);
	}

	/**
	 * Observe the child BeginPlay oracle: route 20/30 and layers 30/3.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixinOverloadsResolveAcrossScriptInheritance
	 * @Inputs this child after BeginPlay
	 * @Return true when RouteValue is 20, ChildRouteValue is 30, LayerTotal is 30 and ChildLayerTotal is 3
	 */
	UFUNCTION()
	bool ChildRouteAfterPlay()
	{
		if (RouteValue != 20)
		{
			return false;
		}
		if (ChildRouteValue != 30)
		{
			return false;
		}
		if (LayerTotal != 30)
		{
			return false;
		}
		return ChildLayerTotal == 3;
	}
}

UCLASS()
class ACoverageMixinConflictGrandchild : ACoverageMixinConflictChild
{
	UPROPERTY()
	int GrandchildRouteValue = 0;

	UPROPERTY()
	int GrandchildLayerTotal = 0;

	/**
	 * WorldStory: an explicit child-typed view selects the nearest overload, then
	 * GrandchildRouteValue and GrandchildLayerTotal record the sums.
	 *
	 * @Kind WorldStory
	 * @Covers Mixin.MixinOverloadsResolveAcrossScriptInheritance
	 * @Inputs this grandchild viewed as ACoverageMixinConflictChild
	 * @Return RouteValue 20, ChildRouteValue 30, LayerTotal 40, ChildLayerTotal 4, GrandchildRouteValue 50, GrandchildLayerTotal 44
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ACoverageMixinConflictChild ChildView = this;
		ChildView.MarkSource();
		ChildView.AddLayer(4);
		GrandchildRouteValue = ChildRouteValue + RouteValue;
		GrandchildLayerTotal = ChildLayerTotal + LayerTotal;
	}

	/**
	 * Observe that an unset grandchild handle is null.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixinOverloadsResolveAcrossScriptInheritance
	 * @Inputs an unset ACoverageMixinConflictGrandchild handle
	 * @Return true when the handle is null
	 * @Boundary empty handle
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ACoverageMixinConflictGrandchild Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe that route counters are zero before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixinOverloadsResolveAcrossScriptInheritance
	 * @Inputs this grandchild before BeginPlay
	 * @Return RouteValue + LayerTotal + GrandchildRouteValue
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	int DefaultsAreZero()
	{
		return RouteValue + LayerTotal + GrandchildRouteValue;
	}

	/**
	 * Observe the grandchild BeginPlay oracle: child routes plus grandchild sums.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixinOverloadsResolveAcrossScriptInheritance
	 * @Inputs this grandchild after BeginPlay
	 * @Return true when RouteValue is 20, ChildRouteValue is 30, LayerTotal is 40, ChildLayerTotal is 4, GrandchildRouteValue is 50 and GrandchildLayerTotal is 44
	 */
	UFUNCTION()
	bool GrandchildRouteAfterPlay()
	{
		if (RouteValue != 20)
		{
			return false;
		}
		if (ChildRouteValue != 30)
		{
			return false;
		}
		if (LayerTotal != 40)
		{
			return false;
		}
		if (ChildLayerTotal != 4)
		{
			return false;
		}
		if (GrandchildRouteValue != 50)
		{
			return false;
		}
		return GrandchildLayerTotal == 44;
	}
}
