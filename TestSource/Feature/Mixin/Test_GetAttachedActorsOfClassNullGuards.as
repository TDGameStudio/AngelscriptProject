// Theme: Feature.Mixin. WorldStory GetAttachedActorsOfClass valid filter vs null TSubclassOf.
// C++: AngelscriptActorMixinTests.cpp::GetAttachedActorsOfClassNullGuards
// Oracle: RunValidClassFilter()==1; RunNullClass()==1.
// Extra: empty handle null; default null-class filter is empty. FixtureIsolated.

UCLASS()
class ATestMixinAttachedFilterChild : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent ChildRoot;
}

UCLASS()
class ATestMixinAttachedFilterOther : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent OtherRoot;
}

UCLASS()
class ATestMixinAttachedFilterParent : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent ParentRoot;

	UFUNCTION()
	int RunValidClassFilter()
	{
		AActor MatchingChild = SpawnActor(ATestMixinAttachedFilterChild::StaticClass(), FVector::ZeroVector, FRotator::ZeroRotator, n"MatchingChild");
		if (MatchingChild == nullptr)
		{
			return 10;
		}
		MatchingChild.AttachToActor(this, n"NAME_None", EAttachmentRule::KeepWorld, EAttachmentRule::KeepWorld, EAttachmentRule::KeepWorld, false);

		AActor OtherChild = SpawnActor(ATestMixinAttachedFilterOther::StaticClass(), FVector::ZeroVector, FRotator::ZeroRotator, n"OtherChild");
		if (OtherChild == nullptr)
		{
			return 20;
		}
		OtherChild.AttachToActor(this, n"NAME_None", EAttachmentRule::KeepWorld, EAttachmentRule::KeepWorld, EAttachmentRule::KeepWorld, false);

		TArray<AActor> FilteredActors = GetAttachedActorsOfClass(ATestMixinAttachedFilterChild::StaticClass());
		if (FilteredActors.Num() != 1)
		{
			return 30;
		}
		if (!FilteredActors[0].IsA(ATestMixinAttachedFilterChild::StaticClass()))
		{
			return 40;
		}

		return 1;
	}

	UFUNCTION()
	int RunNullClass()
	{
		AActor Child = SpawnActor(ATestMixinAttachedFilterChild::StaticClass(), FVector::ZeroVector, FRotator::ZeroRotator, n"NullClassChild");
		if (Child == nullptr)
		{
			return 10;
		}
		Child.AttachToActor(this, n"NAME_None", EAttachmentRule::KeepWorld, EAttachmentRule::KeepWorld, EAttachmentRule::KeepWorld, false);

		TSubclassOf<AActor> NullClass;
		TArray<AActor> FilteredActors = GetAttachedActorsOfClass(NullClass);
		return FilteredActors.Num() == 0 ? 1 : 20;
	}
}

bool Observe_AttachedFilter_EmptyHandleIsNull()
{
	ATestMixinAttachedFilterParent Actor;
	return Actor == nullptr;
}

int Observe_AttachedFilter_NullClassEmptyDefault(ATestMixinAttachedFilterParent Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0167 setup: required ATestMixinAttachedFilterParent is null");
	}
	TSubclassOf<AActor> NullClass;
	TArray<AActor> FilteredActors = Actor.GetAttachedActorsOfClass(NullClass);
	return FilteredActors.Num();
}

int Observe_AttachedFilter_RunValid(ATestMixinAttachedFilterParent Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0167 setup: required ATestMixinAttachedFilterParent is null");
	}
	return Actor.RunValidClassFilter();
}

int Observe_AttachedFilter_RunNullClass(ATestMixinAttachedFilterParent Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0167 setup: required ATestMixinAttachedFilterParent is null");
	}
	return Actor.RunNullClass();
}
