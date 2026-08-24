// Theme: Definitions.UFunction. WorldStory: UObject/AActor/UClass/TSubclassOf parameter matrix.
// C++: AngelscriptCoverageUFunctionTests.cpp::ObjectAndClassParameterReflectionMatrix
// Oracle: AcceptObjectClassMatrix(this,this,self class,self class) == 15;
// ReturnSelfAsObject aliases this; ReturnSelfClass/ReturnActorSubclass are the generated class.
// Extra: all-null Accept returns 0; LastObject stays null on default construct.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageUFunctionObjectBaseActor : AActor
{
}

UCLASS()
class ACoverageUFunctionObjectClassActor : ACoverageUFunctionObjectBaseActor
{
	UPROPERTY()
	UObject LastObject;

	UPROPERTY()
	AActor LastActor;

	UPROPERTY()
	UClass LastClass;

	UPROPERTY()
	TSubclassOf<AActor> LastActorClass;

	UFUNCTION(BlueprintCallable, Category="Coverage|ObjectClass")
	int AcceptObjectClassMatrix(UObject ObjectValue, AActor ActorValue, UClass ClassValue, TSubclassOf<AActor> ActorClassValue)
	{
		LastObject = ObjectValue;
		LastActor = ActorValue;
		LastClass = ClassValue;
		LastActorClass = ActorClassValue;

		int Score = 0;
		if (LastObject == this)
		{
			Score += 1;
		}
		if (LastActor == this)
		{
			Score += 2;
		}
		if (LastClass == ACoverageUFunctionObjectClassActor::StaticClass())
		{
			Score += 4;
		}
		if (LastActorClass != nullptr && LastActorClass.IsChildOf(ACoverageUFunctionObjectBaseActor::StaticClass()))
		{
			Score += 8;
		}
		return Score;
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|ObjectClass")
	UObject ReturnSelfAsObject()
	{
		return this;
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|ObjectClass")
	UClass ReturnSelfClass()
	{
		return ACoverageUFunctionObjectClassActor::StaticClass();
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|ObjectClass")
	TSubclassOf<AActor> ReturnActorSubclass()
	{
		return ACoverageUFunctionObjectClassActor::StaticClass();
	}
}

int Observe_ObjectClass_AcceptSelf(ACoverageUFunctionObjectClassActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ObjectAndClassParameterReflectionMatrix setup: required Actor is null");
	}
	return Actor.AcceptObjectClassMatrix(
		Actor,
		Actor,
		ACoverageUFunctionObjectClassActor::StaticClass(),
		ACoverageUFunctionObjectClassActor::StaticClass());
}

int Observe_ObjectClass_AcceptNulls(ACoverageUFunctionObjectClassActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ObjectAndClassParameterReflectionMatrix setup: required Actor is null");
	}
	return Actor.AcceptObjectClassMatrix(nullptr, nullptr, nullptr, nullptr);
}

bool Observe_ObjectClass_ReturnSelfAndClass(ACoverageUFunctionObjectClassActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ObjectAndClassParameterReflectionMatrix setup: required Actor is null");
	}
	return Actor.ReturnSelfAsObject() == Actor
		&& Actor.ReturnSelfClass() == ACoverageUFunctionObjectClassActor::StaticClass()
		&& Actor.ReturnActorSubclass() == ACoverageUFunctionObjectClassActor::StaticClass();
}

bool Observe_ObjectClass_DefaultLastObjectNull(ACoverageUFunctionObjectClassActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ObjectAndClassParameterReflectionMatrix setup: required Actor is null");
	}
	return Actor.LastObject == nullptr && Actor.LastActor == nullptr && Actor.LastClass == nullptr;
}
