// Theme: Containers.TSoftObjectPtr. WorldStory: TSoftObjectPtr and TSoftClassPtr usage.
// C++: AngelscriptCoverageHandlesTests.cpp::SoftReferenceUsage CompileScriptModule + spawn + BeginPlay.
// Oracle: SoftObject Declaration/Assignment/IsNull/IsValid/Get/ToString and SoftClass
// Declaration/Assignment/Get flags true.
// Extra: local construct leaves flags false; empty TempSoft.IsNull is the empty vector.
// FixtureIsolated. Runner owns spawned actors.

UCLASS()
class ACoverageHandlesSoftRefActor : AActor
{
	UPROPERTY()
	TSoftObjectPtr<AActor> SoftActorRef;

	UPROPERTY()
	TSoftClassPtr<AActor> SoftClassRef;

	UPROPERTY()
	bool SoftObjectDeclarationWorked = false;

	UPROPERTY()
	bool SoftObjectAssignmentWorked = false;

	UPROPERTY()
	bool SoftObjectIsNullWorked = false;

	UPROPERTY()
	bool SoftObjectIsValidWorked = false;

	UPROPERTY()
	bool SoftObjectGetWorked = false;

	UPROPERTY()
	bool SoftObjectToStringWorked = false;

	UPROPERTY()
	bool SoftClassDeclarationWorked = false;

	UPROPERTY()
	bool SoftClassAssignmentWorked = false;

	UPROPERTY()
	bool SoftClassGetWorked = false;

	UPROPERTY()
	FString SoftObjectPathString;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// --- TSoftObjectPtr tests ---

		// Test declaration
		TSoftObjectPtr<AActor> TempSoft;
		SoftObjectDeclarationWorked = true;

		// Test IsNull on empty soft reference
		if (TempSoft.IsNull())
		{
			SoftObjectIsNullWorked = true;
		}

		// Test assignment
		AActor SpawnedActor = SpawnActor(AActor::StaticClass());
		SoftActorRef = SpawnedActor;
		if (SoftActorRef.IsValid())
		{
			SoftObjectAssignmentWorked = true;
		}

		// Test IsValid
		if (!TempSoft.IsValid() && SoftActorRef.IsValid())
		{
			SoftObjectIsValidWorked = true;
		}

		// Test Get method
		AActor Retrieved = SoftActorRef.Get();
		if (Retrieved == SpawnedActor)
		{
			SoftObjectGetWorked = true;
		}

		// Test ToString path
		FString PathString = SoftActorRef.ToString();
		if (!PathString.IsEmpty())
		{
			SoftObjectToStringWorked = true;
			SoftObjectPathString = PathString;
		}

		// --- TSoftClassPtr tests ---

		// Test declaration
		TSoftClassPtr<AActor> TempSoftClass;
		SoftClassDeclarationWorked = true;

		// Test assignment
		SoftClassRef = AActor::StaticClass();
		if (!SoftClassRef.IsNull())
		{
			SoftClassAssignmentWorked = true;
		}

		// Test Get method
		TSubclassOf<AActor> ClassRef = SoftClassRef.Get();
		if (ClassRef.IsValid() && ClassRef.IsChildOf(AActor::StaticClass()))
		{
			SoftClassGetWorked = true;
		}
	}
}

bool Observe_SoftReference_DefaultEmpty(ACoverageHandlesSoftRefActor Actor)
{
	if (Actor is null)
	{
		throw("Test_SoftReferenceUsage setup: required Actor is null");
	}
	return Actor.SoftObjectDeclarationWorked == false
		&& Actor.SoftObjectAssignmentWorked == false
		&& Actor.SoftObjectIsNullWorked == false
		&& Actor.SoftClassDeclarationWorked == false
		&& Actor.SoftObjectPathString.IsEmpty();
}

bool Observe_SoftReference_EmptyIsNull()
{
	TSoftObjectPtr<AActor> TempSoft;
	return TempSoft.IsNull() && !TempSoft.IsValid() && TempSoft.Get() == nullptr;
}

bool Observe_SoftClass_CopyIndependence()
{
	TSoftClassPtr<AActor> First = AActor::StaticClass();
	TSoftClassPtr<AActor> Second;
	return First.IsValid() && Second.IsNull();
}
