// Theme: Feature.Mixin. WorldStory GetAttachedActors empty then two attached children.
// C++: AngelscriptActorMixinTests.cpp::GetAttachedActors
// Oracle: RunGetAttachedTest()==1 (Before.Num()==0, After.Num()==2).
// Extra: empty handle null; default attached list is empty. FixtureIsolated.

UCLASS()
class ATestMixinAttachChild : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent ChildRoot;
}

UCLASS()
class ATestMixinAttachParent : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent ParentRoot;

	UFUNCTION()
	int RunGetAttachedTest()
	{
		TArray<AActor> Before;
		GetAttachedActors(Before);
		if (Before.Num() != 0)
		{
			return 10;
		}

		AActor Child1 = SpawnActor(ATestMixinAttachChild::StaticClass(), FVector::ZeroVector, FRotator::ZeroRotator, n"Child1");
		if (Child1 == nullptr)
		{
			return 20;
		}
		Child1.AttachToActor(this, n"NAME_None", EAttachmentRule::KeepWorld, EAttachmentRule::KeepWorld, EAttachmentRule::KeepWorld, false);

		AActor Child2 = SpawnActor(ATestMixinAttachChild::StaticClass(), FVector::ZeroVector, FRotator::ZeroRotator, n"Child2");
		if (Child2 == nullptr)
		{
			return 30;
		}
		Child2.AttachToActor(this, n"NAME_None", EAttachmentRule::KeepWorld, EAttachmentRule::KeepWorld, EAttachmentRule::KeepWorld, false);

		TArray<AActor> After;
		GetAttachedActors(After);
		if (After.Num() != 2)
		{
			return 40;
		}

		return 1;
	}
}

bool Observe_GetAttached_EmptyHandleIsNull()
{
	ATestMixinAttachParent Actor;
	return Actor == nullptr;
}

int Observe_GetAttached_EmptyDefaultList(ATestMixinAttachParent Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0166 setup: required ATestMixinAttachParent is null");
	}
	TArray<AActor> Before;
	Actor.GetAttachedActors(Before);
	return Before.Num();
}

int Observe_GetAttached_Run(ATestMixinAttachParent Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0166 setup: required ATestMixinAttachParent is null");
	}
	return Actor.RunGetAttachedTest();
}
