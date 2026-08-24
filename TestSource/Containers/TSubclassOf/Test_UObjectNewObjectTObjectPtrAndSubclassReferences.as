// Theme: Containers.TSubclassOf. WorldStory: NewObject outer, TObjectPtr, TSubclassOf params.
// C++: AngelscriptCoverageHandlesTests.cpp::UObjectNewObjectTObjectPtrAndSubclassReferences
// CompileScriptModule + spawn + BeginPlay. Oracle: UObjectNullAssignmentEqualityWorked,
// NewObjectOuterWorked, TObjectPtrRoutedToObjectProperty, SubclassParameterWorked,
// SubclassCreatedInstance true.
// Extra: local construct leaves flags false and handles null.
// FixtureIsolated. Runner owns NewObject instances.

UCLASS()
class ACoverageHandlesAdvancedRefsActor : AActor
{
	UPROPERTY()
	UObject GenericObject;

	UPROPERTY()
	TObjectPtr<UObject> SmartObject;

	UPROPERTY()
	TSubclassOf<UObject> ObjectClass;

	UPROPERTY()
	bool UObjectNullAssignmentEqualityWorked = false;

	UPROPERTY()
	bool NewObjectOuterWorked = false;

	UPROPERTY()
	bool TObjectPtrRoutedToObjectProperty = false;

	UPROPERTY()
	bool SubclassParameterWorked = false;

	UPROPERTY()
	bool ReflectedSubclassParameterWorked = false;

	UPROPERTY()
	bool SubclassCreatedInstance = false;

	void AcceptObjectClass(TSubclassOf<UObject> InClass)
	{
		SubclassParameterWorked = InClass != nullptr && InClass.IsChildOf(UTexture2D::StaticClass());
		ObjectClass = InClass;
	}

	UFUNCTION()
	void AcceptClassFromCpp(TSubclassOf<UObject> InClass)
	{
		ReflectedSubclassParameterWorked = InClass != nullptr && InClass.IsChildOf(UTexture2D::StaticClass());
		AcceptObjectClass(InClass);
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject EmptyObject = nullptr;
		UObjectNullAssignmentEqualityWorked = EmptyObject == nullptr;

		GenericObject = NewObject(this, UTexture2D::StaticClass(), n"CoverageHandlesAdvancedRefsTexture");
		NewObjectOuterWorked = GenericObject != nullptr &&
			GenericObject.GetOuter() == this &&
			GenericObject.IsA(UTexture2D::StaticClass());

		SmartObject = GenericObject;
		UObject RawObject = SmartObject;
		TObjectPtrRoutedToObjectProperty = RawObject == GenericObject &&
			SmartObject.Get() == GenericObject;

		AcceptObjectClass(UTexture2D::StaticClass());
		UObject CreatedFromSubclass = NewObject(this, ObjectClass, n"CoverageHandlesAdvancedRefsSubclassTexture");
		SubclassCreatedInstance = CreatedFromSubclass != nullptr &&
			CreatedFromSubclass.GetOuter() == this &&
			CreatedFromSubclass.IsA(UTexture2D::StaticClass());
	}
}

bool Observe_AdvancedRefs_DefaultEmpty(ACoverageHandlesAdvancedRefsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UObjectNewObjectTObjectPtrAndSubclassReferences setup: required Actor is null");
	}
	return Actor.UObjectNullAssignmentEqualityWorked == false
		&& Actor.NewObjectOuterWorked == false
		&& Actor.TObjectPtrRoutedToObjectProperty == false
		&& Actor.SubclassParameterWorked == false
		&& Actor.ReflectedSubclassParameterWorked == false
		&& Actor.SubclassCreatedInstance == false
		&& Actor.GenericObject == nullptr
		&& Actor.ObjectClass == nullptr;
}

bool Observe_AdvancedRefs_NullObjectEquality()
{
	UObject EmptyObject = nullptr;
	return EmptyObject == nullptr;
}

bool Observe_AdvancedRefs_AcceptNullBoundary(ACoverageHandlesAdvancedRefsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UObjectNewObjectTObjectPtrAndSubclassReferences setup: required Actor is null");
	}
	Actor.AcceptObjectClass(nullptr);
	return Actor.SubclassParameterWorked == false && Actor.ObjectClass == nullptr;
}
