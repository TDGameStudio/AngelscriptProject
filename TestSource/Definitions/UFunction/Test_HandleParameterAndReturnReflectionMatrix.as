// Theme: Definitions.UFunction. WorldStory: TSoftObjectPtr / TSoftClassPtr / TWeakObjectPtr matrix.
// C++: AngelscriptCoverageUFunctionTests.cpp::HandleParameterAndReturnReflectionMatrix
// Oracle: AcceptHandleMatrix(DefaultTexture, Engine.Actor, this) == 7 and bWeakWasValid true.
// Extra: empty handles score 0 and leave bWeakWasValid false; ReturnWeakSelf aliases this.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageUFunctionHandleActor : AActor
{
	UPROPERTY()
	TSoftObjectPtr<UObject> LastSoftObject;

	UPROPERTY()
	TSoftClassPtr<AActor> LastSoftClass;

	UPROPERTY()
	TWeakObjectPtr<AActor> LastWeakActor;

	UPROPERTY()
	bool bWeakWasValid = false;

	UFUNCTION(BlueprintCallable, Category="Coverage|Handles")
	int AcceptHandleMatrix(TSoftObjectPtr<UObject> SoftObject, TSoftClassPtr<AActor> SoftClass, TWeakObjectPtr<AActor> WeakActor)
	{
		LastSoftObject = SoftObject;
		LastSoftClass = SoftClass;
		LastWeakActor = WeakActor;
		bWeakWasValid = WeakActor.IsValid() && WeakActor.Get() == this;

		int Score = 0;
		if (SoftObject.ToString().Contains("DefaultTexture"))
		{
			Score += 1;
		}
		if (SoftClass.ToString().Contains("Actor"))
		{
			Score += 2;
		}
		if (bWeakWasValid)
		{
			Score += 4;
		}
		return Score;
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|Handles")
	TSoftObjectPtr<UObject> ReturnSoftObject()
	{
		return TSoftObjectPtr<UObject>(FSoftObjectPath("/Engine/EngineResources/DefaultTexture.DefaultTexture"));
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|Handles")
	TSoftClassPtr<AActor> ReturnSoftClass()
	{
		return TSoftClassPtr<AActor>(FSoftObjectPath("/Script/Engine.Actor"));
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|Handles")
	TWeakObjectPtr<AActor> ReturnWeakSelf()
	{
		return this;
	}
}

int Observe_HandleMatrix_NominalSelf(ACoverageUFunctionHandleActor Actor)
{
	if (Actor is null)
	{
		throw("Test_HandleParameterAndReturnReflectionMatrix setup: required Actor is null");
	}
	return Actor.AcceptHandleMatrix(Actor.ReturnSoftObject(), Actor.ReturnSoftClass(), Actor.ReturnWeakSelf());
}

int Observe_HandleMatrix_EmptyHandles(ACoverageUFunctionHandleActor Actor)
{
	if (Actor is null)
	{
		throw("Test_HandleParameterAndReturnReflectionMatrix setup: required Actor is null");
	}
	TSoftObjectPtr<UObject> SoftObject;
	TSoftClassPtr<AActor> SoftClass;
	TWeakObjectPtr<AActor> WeakActor;
	return Actor.AcceptHandleMatrix(SoftObject, SoftClass, WeakActor);
}

bool Observe_HandleMatrix_DefaultWeakFalse(ACoverageUFunctionHandleActor Actor)
{
	if (Actor is null)
	{
		throw("Test_HandleParameterAndReturnReflectionMatrix setup: required Actor is null");
	}
	return !Actor.bWeakWasValid;
}

bool Observe_HandleMatrix_ReturnWeakSelf(ACoverageUFunctionHandleActor Actor)
{
	if (Actor is null)
	{
		throw("Test_HandleParameterAndReturnReflectionMatrix setup: required Actor is null");
	}
	TWeakObjectPtr<AActor> WeakSelf = Actor.ReturnWeakSelf();
	return WeakSelf.IsValid() && WeakSelf.Get() == Actor;
}
