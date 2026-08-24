// Theme: Containers.TObjectPtr. WorldStory: UObject handle plus NewObject Outer/Name/Class.
// C++ VerifyByPath: UObjectDeclaredAndAssigned, NewObjectCreated, NewObjectOuterWorked,
// NewObjectNameWorked, NewObjectClassWorked true; GenericObject is UTexture2D.
// Extra: GenericObject default null until BeginPlay. FixtureIsolated.

UCLASS()
class ACoverageHandleUObjectNewObjectActor : AActor
{
	UPROPERTY()
	bool UObjectDeclaredAndAssigned = false;

	UPROPERTY()
	bool NewObjectCreated = false;

	UPROPERTY()
	bool NewObjectOuterWorked = false;

	UPROPERTY()
	bool NewObjectNameWorked = false;

	UPROPERTY()
	bool NewObjectClassWorked = false;

	UPROPERTY()
	UObject GenericObject;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject EmptyObject;
		if (EmptyObject != nullptr)
		{
			return;
		}

		GenericObject = NewObject(GetTransientPackage(), UTexture2D::StaticClass(), n"CoverageUObjectHandleTexture");
		if (GenericObject == nullptr)
		{
			return;
		}

		UObjectDeclaredAndAssigned = true;
		NewObjectCreated = IsValid(GenericObject);
		NewObjectOuterWorked = GenericObject.GetOuter() == GetTransientPackage();
		NewObjectNameWorked = GenericObject.GetName() == n"CoverageUObjectHandleTexture";
		NewObjectClassWorked = GenericObject.IsA(UTexture2D::StaticClass());
	}
}
