// Theme: Containers.TObjectPtr. WorldStory: TObjectPtr assign, Get, implicit convert, copy.
// C++ VerifyByPath: DefaultNullWorked, AssignmentWorked, GetMatchedRawHandle,
// ImplicitConversionWorked, CopyComparisonWorked true; StoredActor keeps CPF_TObjectPtr.
// Extra: StoredActor default null until BeginPlay. FixtureIsolated.

UCLASS()
class ACoverageHandleTObjectPtrActor : AActor
{
	UPROPERTY()
	TObjectPtr<AActor> StoredActor;

	UPROPERTY()
	bool DefaultNullWorked = false;

	UPROPERTY()
	bool AssignmentWorked = false;

	UPROPERTY()
	bool GetMatchedRawHandle = false;

	UPROPERTY()
	bool ImplicitConversionWorked = false;

	UPROPERTY()
	bool CopyComparisonWorked = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TObjectPtr<AActor> Empty;
		DefaultNullWorked = Empty.Get() == nullptr;

		AActor SpawnedActor = SpawnActor(AActor::StaticClass());
		StoredActor = SpawnedActor;

		AssignmentWorked = StoredActor == SpawnedActor;
		GetMatchedRawHandle = StoredActor.Get() == SpawnedActor;

		AActor RawActor = StoredActor;
		ImplicitConversionWorked = RawActor == SpawnedActor;

		TObjectPtr<AActor> CopiedActor = StoredActor;
		CopyComparisonWorked = CopiedActor == StoredActor;
	}
}
