/**
 * A parent actor that filters attached children through GetAttachedActorsOfClass.
 * C++ expects RunValidClassFilter() and RunNullClass() to return 1. The observers
 * cover the empty handle and the default null-class filter.
 *
 * @Theme Feature.Mixin
 * @Subject Mixin.GetAttachedActorsOfClassNullGuards
 * @Harness UClass
 * @Tag Feature.Mixin.GetAttachedActorsOfClassNullGuards
 * @Provenance Theme: Feature.Mixin. WorldStory GetAttachedActorsOfClass valid filter vs null TSubclassOf.
 * @Provenance C++: AngelscriptActorMixinTests.cpp::GetAttachedActorsOfClassNullGuards
 * @Provenance Oracle: RunValidClassFilter()==1; RunNullClass()==1.
 * @Provenance Extra: empty handle null; default null-class filter is empty. FixtureIsolated.
 */

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

	/**
	 * WorldStory: GetAttachedActorsOfClass keeps only the matching child class.
	 *
	 * @Kind WorldStory
	 * @Covers Mixin.GetAttachedActorsOfClassNullGuards
	 * @Inputs one ATestMixinAttachedFilterChild and one ATestMixinAttachedFilterOther attached
	 * @Return 1 when the filtered list holds exactly the matching child; 10, 20, 30 or 40 on mismatch
	 */
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

	/**
	 * WorldStory: a null TSubclassOf filter returns an empty attached list.
	 *
	 * @Kind WorldStory
	 * @Covers Mixin.GetAttachedActorsOfClassNullGuards
	 * @Inputs one attached child and a default-constructed TSubclassOf<AActor>
	 * @Return 1 when the filtered list is empty; 10 if spawn fails; 20 if the list is not empty
	 */
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

	/**
	 * Observe that an unset parent handle is null.
	 *
	 * @Kind Observe
	 * @Covers Mixin.GetAttachedActorsOfClassNullGuards
	 * @Inputs an unset ATestMixinAttachedFilterParent handle
	 * @Return true when the handle is null
	 * @Boundary empty handle
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ATestMixinAttachedFilterParent Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe that a null class filter is empty before any children attach.
	 *
	 * @Kind Observe
	 * @Covers Mixin.GetAttachedActorsOfClassNullGuards
	 * @Inputs this parent and a default-constructed TSubclassOf<AActor>
	 * @Return FilteredActors.Num()
	 * @Boundary default null-class filter
	 */
	UFUNCTION()
	int NullClassEmptyDefault()
	{
		TSubclassOf<AActor> NullClass;
		TArray<AActor> FilteredActors = GetAttachedActorsOfClass(NullClass);
		return FilteredActors.Num();
	}
}
