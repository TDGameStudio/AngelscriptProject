// Theme: Containers.TWeakObjectPtr. WorldStory: destroy target then IsValid/Get fail.
// CSV NegativeDiagnostic is wrong; C++ compiles and VerifyByPath InitiallyValid /
// InvalidAfterDestroy / GetReturnsNull all true after BeginPlay (+ tick).
// Extra: local construct leaves flags false and WeakTarget null.
// FixtureIsolated. Runner owns spawned actors.

UCLASS()
class ACoverageWeakRefInvalidationActor : AActor
{
	UPROPERTY()
	TWeakObjectPtr<AActor> WeakTarget;

	UPROPERTY()
	bool InitiallyValid = false;

	UPROPERTY()
	bool InvalidAfterDestroy = false;

	UPROPERTY()
	bool GetReturnsNull = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Spawn a temporary actor
		AActor TempActor = SpawnActor(AActor::StaticClass());

		// Assign to weak pointer
		WeakTarget = TempActor;

		// Check initially valid
		if (WeakTarget.IsValid())
		{
			InitiallyValid = true;
		}

		// Destroy the actor
		TempActor.DestroyActor();

		// Check that weak pointer is now invalid
		if (!WeakTarget.IsValid())
		{
			InvalidAfterDestroy = true;
		}

		// Check that Get returns null
		AActor Retrieved = WeakTarget.Get();
		if (Retrieved == nullptr)
		{
			GetReturnsNull = true;
		}
	}
}

bool Observe_WeakRefInvalidation_DefaultEmpty(ACoverageWeakRefInvalidationActor Actor)
{
	if (Actor is null)
	{
		throw("Test_WeakObjectPtrInvalidation setup: required Actor is null");
	}
	return Actor.WeakTarget == nullptr
		&& Actor.WeakTarget.Get() == nullptr
		&& Actor.WeakTarget.IsValid() == false
		&& Actor.InitiallyValid == false
		&& Actor.InvalidAfterDestroy == false
		&& Actor.GetReturnsNull == false;
}

bool Observe_WeakRefInvalidation_CopyIndependence(ACoverageWeakRefInvalidationActor First, ACoverageWeakRefInvalidationActor Second)
{
	if (First is null)
	{
		throw("Test_WeakObjectPtrInvalidation setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_WeakObjectPtrInvalidation setup: required Second is null");
	}
	First.InitiallyValid = true;
	return First.InitiallyValid == true
		&& Second.InitiallyValid == false
		&& Second.WeakTarget == nullptr
		&& Second.GetReturnsNull == false;
}
