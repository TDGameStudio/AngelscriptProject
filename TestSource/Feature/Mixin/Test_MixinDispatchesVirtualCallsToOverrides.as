// Theme: Feature.Mixin. WorldStory mixin virtual call dispatches to BlueprintOverride.
// C++: AngelscriptCoverageMixinTests.cpp::MixinDispatchesVirtualCallsToOverrides
// Oracle: parent MixinResult==11 DirectResult==11; child MixinResult==77 DirectResult==77.
// Extra: empty handle null; pre-BeginPlay zeros. FixtureIsolated. Keep MixinResult/DirectResult.

mixin int ReadVirtualValue(ACoverageMixinVirtualParent Self)
{
	return Self.GetVirtualValue();
}

mixin void StoreVirtualValue(ACoverageMixinVirtualParent Self)
{
	Self.MixinResult = Self.ReadVirtualValue();
}

UCLASS()
class ACoverageMixinVirtualParent : AActor
{
	UPROPERTY()
	int MixinResult = 0;

	UPROPERTY()
	int DirectResult = 0;

	UFUNCTION(BlueprintEvent)
	int GetVirtualValue()
	{
		return 11;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		this.StoreVirtualValue();
		DirectResult = GetVirtualValue();
	}
}

UCLASS()
class ACoverageMixinVirtualChild : ACoverageMixinVirtualParent
{
	UFUNCTION(BlueprintOverride)
	int GetVirtualValue()
	{
		return 77;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		this.StoreVirtualValue();
		DirectResult = GetVirtualValue();
	}
}

bool Observe_MixinVirtual_EmptyHandleIsNull()
{
	ACoverageMixinVirtualChild Actor;
	return Actor == nullptr;
}

int Observe_MixinVirtual_BeforeBeginPlay(ACoverageMixinVirtualParent Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0060 setup: required ACoverageMixinVirtualParent is null");
	}
	return Actor.MixinResult + Actor.DirectResult;
}

bool Observe_MixinVirtual_ParentAfterBeginPlay(ACoverageMixinVirtualParent Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0060 setup: required ACoverageMixinVirtualParent is null");
	}
	return Actor.MixinResult == 11 && Actor.DirectResult == 11;
}

bool Observe_MixinVirtual_ChildAfterBeginPlay(ACoverageMixinVirtualChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0060 setup: required ACoverageMixinVirtualChild is null");
	}
	return Actor.MixinResult == 77 && Actor.DirectResult == 77;
}

int Observe_MixinVirtual_DirectChildValue(ACoverageMixinVirtualChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0060 setup: required ACoverageMixinVirtualChild is null");
	}
	return Actor.GetVirtualValue();
}
