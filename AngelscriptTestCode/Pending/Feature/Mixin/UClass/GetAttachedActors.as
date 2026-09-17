/**
 * @version v1
 * @summary A parent actor that enumerates attached children through GetAttachedActors. C++ expects RunGetAttachedTest() to return 1 when the list is empty then holds two attached children. The observers cover the empty handle and.
 * @topic Feature
 */
/**
 * @version root
 * @summary A parent actor that enumerates attached children through GetAttachedActors. C++ expects RunGetAttachedTest() to return 1 when the list is empty then holds two attached children. The observers cover the empty handle and.
 * @topic Baseline
 */
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

	/**
	 * WorldStory: GetAttachedActors is empty, then two children attach, then the list is 2.
	 *
	 * @Kind WorldStory
	 * @Covers Mixin.GetAttachedActors
	 * @Inputs two spawned ATestMixinAttachChild actors attached KeepWorld
	 * @Return 1 when Before.Num()==0 and After.Num()==2; 10, 20, 30 or 40 on mismatch
	 */
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

	/**
	 * Observe that an unset parent handle is null.
	 *
	 * @Kind Observe
	 * @Covers Mixin.GetAttachedActors
	 * @Inputs an unset ATestMixinAttachParent handle
	 * @Return true when the handle is null
	 * @Boundary empty handle
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ATestMixinAttachParent Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe that GetAttachedActors starts empty before any children attach.
	 *
	 * @Kind Observe
	 * @Covers Mixin.GetAttachedActors
	 * @Inputs this parent with no attached children
	 * @Return Before.Num()
	 * @Boundary default empty list
	 */
	UFUNCTION()
	int EmptyAttachedList()
	{
		TArray<AActor> Before;
		GetAttachedActors(Before);
		return Before.Num();
	}
}
/** @end */
