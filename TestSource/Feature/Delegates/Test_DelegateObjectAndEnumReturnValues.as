// Theme: Feature.Delegates. WorldStory AActor and UENUM delegate returns.
// C++: AngelscriptCoverageDelegateTests.cpp::DelegateObjectAndEnumReturnValues
// Oracle after BeginPlay: ReturnedActor is self, bReturnedSelf==true,
// ReturnedRoute==Matched (enumerator 1). Extra: empty actor is null;
// pre-BeginPlay Missing / false / null. FixtureIsolated.

UENUM()
enum ECoverageDelegateObjectRoute
{
	Missing,
	Matched,
	Fallback
}

delegate AActor FDelegateActorReturn();
delegate ECoverageDelegateObjectRoute FDelegateEnumReturn(AActor ActorValue);

UCLASS()
class ACoverageDelegateObjectEnumReturnActor : AActor
{
	UPROPERTY()
	AActor ReturnedActor;

	UPROPERTY()
	ECoverageDelegateObjectRoute ReturnedRoute = ECoverageDelegateObjectRoute::Missing;

	UPROPERTY()
	bool bReturnedSelf = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FDelegateActorReturn ActorReturn;
		ActorReturn.BindUFunction(this, n"ReturnSelfActor");
		ReturnedActor = ActorReturn.Execute();
		bReturnedSelf = ReturnedActor == this;

		FDelegateEnumReturn EnumReturn;
		EnumReturn.BindUFunction(this, n"ClassifyActor");
		ReturnedRoute = EnumReturn.Execute(ReturnedActor);
	}

	UFUNCTION()
	AActor ReturnSelfActor()
	{
		return this;
	}

	UFUNCTION()
	ECoverageDelegateObjectRoute ClassifyActor(AActor ActorValue)
	{
		if (ActorValue == this)
		{
			return ECoverageDelegateObjectRoute::Matched;
		}

		return ECoverageDelegateObjectRoute::Fallback;
	}
}

bool Observe_ObjectEnumReturn_EmptyDefaultIsNull()
{
	ACoverageDelegateObjectEnumReturnActor Actor;
	return Actor == nullptr;
}

bool Observe_ObjectEnumReturn_ReturnedActorDefaultNull(ACoverageDelegateObjectEnumReturnActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0023 setup: required ACoverageDelegateObjectEnumReturnActor is null");
	}
	return Actor.ReturnedActor == nullptr;
}

bool Observe_ObjectEnumReturn_ReturnedSelfDefaultFalse(ACoverageDelegateObjectEnumReturnActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0023 setup: required ACoverageDelegateObjectEnumReturnActor is null");
	}
	return Actor.bReturnedSelf;
}
