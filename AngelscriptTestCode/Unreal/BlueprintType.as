/**
 * @version v1
 * @summary BlueprintType host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic BlueprintType
 *
 * ownership-script-owned-uobject
 * container-api
 * ownership-property-storage-script
 * ownership-call-borrows-object
 * ownership-borrowed-uclass-handle
 * ownership-wrappers-store-class
 * BlueprintType-Behavior_01-container-api
 * BlueprintType-Behavior_02-container-api
 * ownership-weak-wrapper-does
 * assignment
 * set
 * static-class
 * inputs-aactor-staticclass
 * equality
 * get
 * is-valid
 * is-child-of
 * get-default-object
 * is-stale
 * is-explicitly-null
 */
/**
 * @begin ownership-script-owned-uobject
 * @summary Ownership: script-owned UObject handle.
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary Ownership: script-owned UObject handle.
 * @covers BlueprintType.ownership-script-owned-uobject
 * @inputs BlueprintType values exercised by this observe
 * @return true when the observe comparison holds
 */
// TSubclassOf<T> Value;

bool ObserveSurface001Nominal()
{
	UTSBlueprintTypeBehaviorCarrier Object;
	if (Object is null)
	{
		throw("TS_BlueprintType_Behavior_01 setup: required Object is null");
	}
	return Object.StoredValue == 7;
}
/** @end */
/**
 * @begin container-api
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSurface003Nominal
 * @summary Observe the container API.
 * @covers BlueprintType.container-api
 * @inputs BlueprintType values exercised by this observe
 * @return true when the observe comparison holds
 */
// TSubclassOf<T> Value;

 Oracle: Get() identity equals StaticClass().
// Ownership: borrowed UClass; no new instance.
bool ObserveSurface003Nominal()
{
	TSubclassOf<UObject> StaticType = UTSBlueprintTypeBehaviorCarrier::StaticClass();
	UClass StaticClassValue = StaticType.Get();
	return StaticClassValue == UTSBlueprintTypeBehaviorCarrier::StaticClass();
}
/** @end */
/**
 * @begin ownership-property-storage-script
 * @summary Ownership: property storage on the script object.
 * @topic Unreal
 */
/**
 * @function ObserveSurface004Nominal
 * @summary Ownership: property storage on the script object.
 * @covers BlueprintType.ownership-property-storage-script
 * @inputs BlueprintType values exercised by this observe
 * @return true when the observe comparison holds
 */
// TSubclassOf<T> Value;

bool ObserveSurface004Nominal()
{
	UTSBlueprintTypeBehaviorCarrier Object;
	if (Object is null)
	{
		throw("TS_BlueprintType_Behavior_01 setup: required Object is null");
	}
	int Before = Object.StoredValue;
	Object.StoredValue = 11;
	int After = Object.StoredValue;
	return Before == 7 && After == 11;
}
/** @end */
/**
 * @begin ownership-call-borrows-object
 * @summary Ownership: call borrows Object.
 * @topic Unreal
 */
/**
 * @function ObserveSurface005Nominal
 * @summary Ownership: call borrows Object.
 * @covers BlueprintType.ownership-call-borrows-object
 * @inputs BlueprintType values exercised by this observe
 * @return true when the observe comparison holds
 */
// TSubclassOf<T> Value;

bool ObserveSurface005Nominal()
{
	UTSBlueprintTypeBehaviorCarrier Object;
	if (Object is null)
	{
		throw("TS_BlueprintType_Behavior_01 setup: required Object is null");
	}
	int Result = Object.ReadStoredValue();
	return Result == 7;
}
/** @end */
/**
 * @begin ownership-borrowed-uclass-handle
 * @summary Ownership: borrowed UClass handle.
 * @topic Unreal
 */
/**
 * @function ObserveSurface007Nominal
 * @summary Ownership: borrowed UClass handle.
 * @covers BlueprintType.ownership-borrowed-uclass-handle
 * @inputs BlueprintType values exercised by this observe
 * @return true when the observe comparison holds
 */
// TSubclassOf<T> Value;

bool ObserveSurface007Nominal()
{
	return UTSBlueprintTypeBehaviorCarrier::StaticClass() != nullptr;
}
/** @end */
/**
 * @begin ownership-wrappers-store-class
 * @summary Ownership: wrappers store class/object identity.
 * @topic Unreal
 */
/**
 * @function ObserveValueNominal
 * @summary Ownership: wrappers store class/object identity.
 * @covers BlueprintType.ownership-wrappers-store-class
 * @inputs BlueprintType values exercised by this observe
 * @return true when the observe comparison holds
 */
// TSubclassOf<T> Value;

bool ObserveValueNominal()
{
	TSubclassOf<AActor> DeclaredValue;
	TSubclassOf<AActor> DefaultConstructed = TSubclassOf<AActor>();
	bool bEmptySubclassIsInvalid = !DeclaredValue.IsValid() && !DefaultConstructed.IsValid();

	TSubclassOf<AActor> Other = AActor::StaticClass();
	TSubclassOf<AActor> Copied(Other);
	bool bCopyConstructorPreservesIdentity = Copied.Get() == AActor::StaticClass();

	TSubclassOf<AActor> FromClass(APawn::StaticClass());
	bool bUClassConstructorValidatesSubtype = FromClass.Get() == APawn::StaticClass();

	TObjectPtr<AActor> DeclaredPtr;
	TObjectPtr<AActor> NullConstructed = TObjectPtr<AActor>();
	AActor DeclaredResolved = DeclaredPtr;
	AActor NullResolved = NullConstructed;
	bool bObjectPtrDefaultIsNull = DeclaredResolved is null && NullResolved is null;

	return bEmptySubclassIsInvalid &&
		bCopyConstructorPreservesIdentity &&
		bUClassConstructorValidatesSubtype &&
		bObjectPtrDefaultIsNull;
}
/** @end */
/**
 * @begin BlueprintType-Behavior_01-container-api
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSurface022Nominal
 * @summary Observe the container API.
 * @covers BlueprintType.container-api
 * @inputs BlueprintType values exercised by this observe
 * @return true when the observe comparison holds
 */
// TSubclassOf<T> Value;

 Oracle: Get() is null for both.
// Ownership: strong wrapper of a null handle; no UObject is created.
bool ObserveSurface022Nominal()
{
	TObjectPtr<UTSBlueprintTypeBehaviorCarrier> DeclaredPtr;
	TObjectPtr<UTSBlueprintTypeBehaviorCarrier> NullConstructed;
	UTSBlueprintTypeBehaviorCarrier FromDeclared = DeclaredPtr.Get();
	UTSBlueprintTypeBehaviorCarrier FromNull = NullConstructed.Get();
	return FromDeclared is null && FromNull is null;
}
/** @end */
/**
 * @begin BlueprintType-Behavior_02-container-api
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveValueNominal
 * @summary Observe the container API.
 * @covers BlueprintType.container-api
 * @inputs BlueprintType values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 TObjectPtr<T> Value(T Object);
// TWeakObjectPtr<T> Value;
// TWeakObjectPtr<T> Value();
// TWeakObjectPtr<T> Value(const TWeakObjectPtr<T>& Other);
// TWeakObjectPtr<T> Value(T Object);
// Inputs: A live actor CDO, a null UObject, a copied pointer wrapper, and
// default/empty weak pointer construction as the empty state.
// Expected observations: Copy construction preserves object identity.
// Construction from a live object resolves to that object. Construction from
// null or default yields a null or explicitly-null wrapper.
// Boundary/ownership: TObjectPtr construction from a UObject is a strong
// wrapper copy of the handle, not a new UObject. TWeakObjectPtr construction
// from a UObject does not keep the object alive.
// TObjectPtr copy and object constructors preserve or null identity.
// Inputs: actor CDO, copied TObjectPtr, null UObject.
// Oracle: copy and object ctor match CDO; null ctor Get() is null.
// Ownership: strong wrapper copy; CDO is not owned by the wrapper.
bool ObserveValueNominal()
{
	AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
	if (LiveCdo is null)
	{
		throw("TS_BlueprintType_Behavior_02 setup: required Actor CDO is null");
	}
	TObjectPtr<AActor> Other = LiveCdo;
	TObjectPtr<AActor> Copied(Other);
	AActor CopiedResolved = Copied.Get();
	TObjectPtr<AActor> FromObject(LiveCdo);
	AActor FromObjectResolved = FromObject.Get();
	AActor NullObject = nullptr;
	TObjectPtr<AActor> FromNull(NullObject);
	AActor NullResolved = FromNull.Get();
	return CopiedResolved == LiveCdo && FromObjectResolved == LiveCdo && NullResolved is null;
}
/** @end */
/**
 * @begin ownership-weak-wrapper-does
 * @summary Ownership: weak wrapper does not keep the object alive.
 * @topic Unreal
 */
/**
 * @function ObserveSurface032Nominal
 * @summary Ownership: weak wrapper does not keep the object alive.
 * @covers BlueprintType.ownership-weak-wrapper-does
 * @inputs BlueprintType values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface032Nominal()
{
	TWeakObjectPtr<AActor> DeclaredValue;
	TWeakObjectPtr<AActor> DefaultConstructed = TWeakObjectPtr<AActor>();
	bool bDeclaredIsExplicitlyNull = DeclaredValue.IsExplicitlyNull();
	bool bDefaultIsExplicitlyNull = DefaultConstructed.IsExplicitlyNull();

	AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
	if (LiveCdo is null)
	{
		throw("TS_BlueprintType_Behavior_02 setup: required Actor CDO is null");
	}
	TWeakObjectPtr<AActor> Other = LiveCdo;
	TWeakObjectPtr<AActor> Copied(Other);
	AActor CopiedResolved = Copied.Get();
	TWeakObjectPtr<AActor> FromObject(LiveCdo);
	AActor FromObjectResolved = FromObject.Get();
	AActor NullObject = nullptr;
	TWeakObjectPtr<AActor> FromNull(NullObject);
	bool bNullWeakIsExplicitlyNull = FromNull.IsExplicitlyNull() && FromNull.Get() is null;

	return bDeclaredIsExplicitlyNull &&
		bDefaultIsExplicitlyNull &&
		CopiedResolved == LiveCdo &&
		FromObjectResolved == LiveCdo &&
		bNullWeakIsExplicitlyNull;
}
/** @end */
/**
 * @begin assignment
 * @summary alive.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary alive.
 * @covers BlueprintType.assignment
 * @inputs BlueprintType values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAssignmentNominal()
{
	TSubclassOf<AActor> EmptySubclass;
	TSubclassOf<AActor> Other = AActor::StaticClass();
	TSubclassOf<AActor> Subclass = EmptySubclass;
	Subclass = Other;
	UClass CopiedClass = Subclass.Get();
	bool bCopiedSubclassIdentity = CopiedClass == AActor::StaticClass();

	Subclass = APawn::StaticClass();
	UClass AssignedClass = Subclass;
	UObject AssignedAsObject = Subclass;
	bool bAssignedClassIdentity = AssignedClass == APawn::StaticClass();
	bool bAssignedObjectIdentity = AssignedAsObject == APawn::StaticClass();

	AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
	if (LiveCdo is null)
	{
		throw("TS_BlueprintType_ConstructionAndAssignment_01 setup: required Actor CDO is null");
	}
	TObjectPtr<AActor> EmptyObjectPtr;
	TObjectPtr<AActor> OtherPtr = LiveCdo;
	TObjectPtr<AActor> ObjectPtr = EmptyObjectPtr;
	ObjectPtr = OtherPtr;
	AActor CopiedFromPtr = ObjectPtr;
	bool bCopiedObjectPtrIdentity = CopiedFromPtr == LiveCdo;

	ObjectPtr = LiveCdo;
	AActor AssignedFromObject = ObjectPtr;
	bool bAssignedObjectPtrIdentity = AssignedFromObject == LiveCdo;

	AActor NullObject = nullptr;
	TObjectPtr<AActor> NullPtr;
	NullPtr = NullObject;
	AActor NullResolved = NullPtr;
	bool bNullObjectPtrResolvesNull = NullResolved is null;

	TWeakObjectPtr<AActor> EmptyWeak;
	TWeakObjectPtr<AActor> OtherWeak = LiveCdo;
	TWeakObjectPtr<AActor> WeakPtr = EmptyWeak;
	WeakPtr = OtherWeak;
	AActor CopiedWeak = WeakPtr;
	bool bCopiedWeakIdentity = CopiedWeak == LiveCdo;

	WeakPtr = LiveCdo;
	AActor AssignedWeak = WeakPtr;
	bool bAssignedWeakIdentity = AssignedWeak == LiveCdo;

	WeakPtr = NullObject;
	AActor NullWeakResolved = WeakPtr;
	bool bNullWeakResolvesNull = NullWeakResolved is null;

	return bCopiedSubclassIdentity &&
		bAssignedClassIdentity &&
		bAssignedObjectIdentity &&
		bCopiedObjectPtrIdentity &&
		bAssignedObjectPtrIdentity &&
		bNullObjectPtrResolvesNull &&
		bCopiedWeakIdentity &&
		bAssignedWeakIdentity &&
		bNullWeakResolvesNull;
}
/** @end */
/**
 * @begin set
 * @summary Expected observations:
 * @topic Unreal
 */
/**
 * @function ObserveSetNominal
 * @summary Expected observations:
 * @covers BlueprintType.set
 * @inputs BlueprintType values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 After Set(APawn) Get() identity is APawn. A second
// identical Set leaves identity unchanged. Set(null) clears IsValid().
// Boundary/ownership: Class must derive from T or the call is a diagnostic
// failure. The wrapper does not own the UClass object; it only stores the
// selected class identity.
bool ObserveSetNominal()
{
	TSubclassOf<AActor> Subclass = AActor::StaticClass();
	UClass Before = Subclass.Get();
	Subclass.Set(APawn::StaticClass());
	UClass AfterFirst = Subclass.Get();
	bool bSetReplacedSelectedClass = Before == AActor::StaticClass() && AfterFirst == APawn::StaticClass();

	Subclass.Set(APawn::StaticClass());
	UClass AfterRepeat = Subclass.Get();
	bool bRepeatedSetIsStable = AfterRepeat == APawn::StaticClass();

	Subclass.Set(nullptr);
	UClass AfterNull = Subclass.Get();
	bool bNullSetClearsSelection = AfterNull is null && !Subclass.IsValid();

	return bSetReplacedSelectedClass && bRepeatedSetIsStable && bNullSetClearsSelection;
}
/** @end */
/**
 * @begin static-class
 * @summary Ownership: borrowed UClass.
 * @topic Unreal
 */
/**
 * @function ObserveStaticClassNominal
 * @summary Ownership: borrowed UClass.
 * @covers BlueprintType.static-class
 * @inputs BlueprintType values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveStaticClassNominal()
{
	UClass ActorClass = AActor::StaticClass();
	UClass ObjectClass = UObject::StaticClass();
	UClass ActorClassAgain = AActor::StaticClass();
	return ActorClass != nullptr && ActorClass != ObjectClass && ActorClass == ActorClassAgain;
}
/** @end */
/**
 * @begin inputs-aactor-staticclass
 * @summary Inputs: AActor::StaticClass()
 * @topic Unreal
 */
/**
 * @function ObserveSurface006Nominal
 * @summary Inputs: AActor::StaticClass()
 * @covers BlueprintType.inputs-aactor-staticclass
 * @inputs BlueprintType values exercised by this observe
 * @return true when the observe comparison holds
 */
 then GetName().
// Oracle: class name is "Actor".
// Ownership: GetName returns a new FString; UClass is borrowed.
bool ObserveSurface006Nominal()
{
	UClass ActorClass = AActor::StaticClass();
	if (ActorClass is null)
	{
		throw("TS_BlueprintType_NamespaceAndGlobalFunctions_01 setup: required ActorClass is null");
	}
	FString ClassName = ActorClass.GetName();
	return ClassName == "Actor";
}
/** @end */
/**
 * @begin equality
 * @summary are value-returning and do not mutate either operand.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary are value-returning and do not mutate either operand.
 * @covers BlueprintType.equality
 * @inputs BlueprintType values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	TSubclassOf<AActor> Left = AActor::StaticClass();
	TSubclassOf<AActor> RightSame = AActor::StaticClass();
	TSubclassOf<AActor> RightDifferent = APawn::StaticClass();
	UClass ActorClass = AActor::StaticClass();
	UClass PawnClass = APawn::StaticClass();

	bool bSubclassSame = Left == RightSame;
	bool bSubclassDifferent = Left == RightDifferent;
	bool bSubclassEqualsClass = Left == ActorClass;
	bool bSubclassNotEqualsOtherClass = Left == PawnClass;
	bool bSubclassEqualityExact = bSubclassSame && !bSubclassDifferent && bSubclassEqualsClass && !bSubclassNotEqualsOtherClass;

	AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
	if (LiveCdo is null)
	{
		throw("TS_BlueprintType_Operators_01 setup: required Actor CDO is null");
	}
	AActor NullObject = nullptr;
	TObjectPtr<AActor> ObjectPtr = LiveCdo;
	TObjectPtr<AActor> OtherPtr = LiveCdo;
	TObjectPtr<AActor> NullPtr;
	bool bObjectPtrSame = ObjectPtr == OtherPtr;
	bool bObjectPtrEqualsObject = ObjectPtr == LiveCdo;
	bool bObjectPtrNotNull = ObjectPtr == NullObject;
	bool bNullPtrsEqual = NullPtr == NullObject;
	bool bObjectPtrEqualityExact = bObjectPtrSame && bObjectPtrEqualsObject && !bObjectPtrNotNull && bNullPtrsEqual;

	TWeakObjectPtr<AActor> WeakPtr = LiveCdo;
	TWeakObjectPtr<AActor> OtherWeak = LiveCdo;
	TWeakObjectPtr<AActor> NullWeak;
	bool bWeakSame = WeakPtr == OtherWeak;
	bool bWeakEqualsObject = WeakPtr == LiveCdo;
	bool bWeakNotNull = WeakPtr == NullObject;
	bool bNullWeaksEqual = NullWeak == NullObject;
	bool bWeakEqualityExact = bWeakSame && bWeakEqualsObject && !bWeakNotNull && bNullWeaksEqual;

	return bSubclassEqualityExact && bObjectPtrEqualityExact && bWeakEqualityExact;
}
/** @end */
/**
 * @begin get
 * @summary Expected observations:
 * @topic Unreal
 */
/**
 * @function ObserveGetNominal
 * @summary Expected observations:
 * @covers BlueprintType.get
 * @inputs BlueprintType values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 Empty Get() is null and IsValid() is false. Pawn
// IsChildOf(AActor) is true. Live Get() returns the same CDO identity.
// Explicitly null weak pointers report IsExplicitlyNull true and IsStale false.
// Boundary/ownership: GetDefaultObject returns the class CDO without transferring
// ownership. Weak Get() returns null when the object is gone. Assigning an
// incompatible UClass is the expected-failure path.
bool ObserveGetNominal()
{
	TSubclassOf<AActor> EmptySubclass;
	UClass EmptyClass = EmptySubclass.Get();
	bool bEmptyGetIsNull = EmptyClass is null;

	TSubclassOf<AActor> ActorSubclass = AActor::StaticClass();
	UClass SelectedClass = ActorSubclass.Get();
	bool bSelectedGetMatches = SelectedClass == AActor::StaticClass();

	AActor LiveCdo = ActorSubclass.GetDefaultObject();
	if (LiveCdo is null)
	{
		throw("TS_BlueprintType_Queries_01 setup: required Actor CDO is null");
	}
	TObjectPtr<AActor> ObjectPtr = LiveCdo;
	AActor FromObjectPtr = ObjectPtr.Get();
	bool bObjectPtrGetMatches = FromObjectPtr == LiveCdo;

	TObjectPtr<AActor> NullPtr;
	AActor FromNullPtr = NullPtr.Get();
	bool bNullObjectPtrGetIsNull = FromNullPtr is null;

	TWeakObjectPtr<AActor> WeakPtr = LiveCdo;
	AActor FromWeak = WeakPtr.Get();
	bool bWeakGetMatches = FromWeak == LiveCdo;

	TWeakObjectPtr<AActor> NullWeak;
	AActor FromNullWeak = NullWeak.Get();
	bool bNullWeakGetIsNull = FromNullWeak is null;

	return bEmptyGetIsNull &&
		bSelectedGetMatches &&
		bObjectPtrGetMatches &&
		bNullObjectPtrGetIsNull &&
		bWeakGetMatches &&
		bNullWeakGetIsNull;
}
/** @end */
/**
 * @begin is-valid
 * @summary incompatible UClass is the expected-failure path.
 * @topic Unreal
 */
/**
 * @function ObserveIsValidNominal
 * @summary incompatible UClass is the expected-failure path.
 * @covers BlueprintType.is-valid
 * @inputs BlueprintType values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveIsValidNominal()
{
	TSubclassOf<AActor> EmptySubclass;
	bool bEmptySubclassInvalid = EmptySubclass.IsValid();
	TSubclassOf<AActor> ActorSubclass = AActor::StaticClass();
	bool bActorSubclassValid = ActorSubclass.IsValid();

	AActor LiveCdo = ActorSubclass.GetDefaultObject();
	if (LiveCdo is null)
	{
		throw("TS_BlueprintType_Queries_01 setup: required Actor CDO is null");
	}
	TWeakObjectPtr<AActor> LiveWeak = LiveCdo;
	bool bLiveWeakValid = LiveWeak.IsValid();
	TWeakObjectPtr<AActor> NullWeak;
	bool bNullWeakValid = NullWeak.IsValid();

	return !bEmptySubclassInvalid && bActorSubclassValid && bLiveWeakValid && !bNullWeakValid;
}
/** @end */
/**
 * @begin is-child-of
 * @summary incompatible UClass is the expected-failure path.
 * @topic Unreal
 */
/**
 * @function ObserveIsChildOfNominal
 * @summary incompatible UClass is the expected-failure path.
 * @covers BlueprintType.is-child-of
 * @inputs BlueprintType values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveIsChildOfNominal()
{
	TSubclassOf<AActor> PawnSubclass = APawn::StaticClass();
	bool bPawnIsChildOfActor = PawnSubclass.IsChildOf(AActor::StaticClass());
	bool bPawnIsChildOfPawn = PawnSubclass.IsChildOf(APawn::StaticClass());
	bool bPawnIsChildOfObject = PawnSubclass.IsChildOf(UObject::StaticClass());
	bool bPawnIsChildOfPlayerController = PawnSubclass.IsChildOf(APlayerController::StaticClass());
	return bPawnIsChildOfActor && bPawnIsChildOfPawn && bPawnIsChildOfObject && !bPawnIsChildOfPlayerController;
}
/** @end */
/**
 * @begin get-default-object
 * @summary incompatible UClass is the expected-failure path.
 * @topic Unreal
 */
/**
 * @function ObserveGetDefaultObjectNominal
 * @summary incompatible UClass is the expected-failure path.
 * @covers BlueprintType.get-default-object
 * @inputs BlueprintType values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveGetDefaultObjectNominal()
{
	TSubclassOf<AActor> EmptySubclass;
	AActor EmptyCdo = EmptySubclass.GetDefaultObject();
	bool bEmptyCdoIsNull = EmptyCdo is null;

	TSubclassOf<AActor> ActorSubclass = AActor::StaticClass();
	AActor ActorCdo = ActorSubclass.GetDefaultObject();
	bool bActorCdoIsLive = ActorCdo != nullptr;
	return bEmptyCdoIsNull && bActorCdoIsLive;
}
/** @end */
/**
 * @begin is-stale
 * @summary incompatible UClass is the expected-failure path.
 * @topic Unreal
 */
/**
 * @function ObserveIsStaleNominal
 * @summary incompatible UClass is the expected-failure path.
 * @covers BlueprintType.is-stale
 * @inputs BlueprintType values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveIsStaleNominal()
{
	AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
	if (LiveCdo is null)
	{
		throw("TS_BlueprintType_Queries_01 setup: required Actor CDO is null");
	}
	TWeakObjectPtr<AActor> LiveWeak = LiveCdo;
	bool bLiveIsStale = LiveWeak.IsStale();
	TWeakObjectPtr<AActor> NullWeak;
	bool bExplicitNullIsStale = NullWeak.IsStale();
	return !bLiveIsStale && !bExplicitNullIsStale;
}
/** @end */
/**
 * @begin is-explicitly-null
 * @summary incompatible UClass is the expected-failure path.
 * @topic Unreal
 */
/**
 * @function ObserveIsExplicitlyNullNominal
 * @summary incompatible UClass is the expected-failure path.
 * @covers BlueprintType.is-explicitly-null
 * @inputs BlueprintType values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveIsExplicitlyNullNominal()
{
	AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
	if (LiveCdo is null)
	{
		throw("TS_BlueprintType_Queries_01 setup: required Actor CDO is null");
	}
	TWeakObjectPtr<AActor> LiveWeak = LiveCdo;
	bool bLiveIsExplicitlyNull = LiveWeak.IsExplicitlyNull();
	TWeakObjectPtr<AActor> NullWeak;
	bool bNullIsExplicitlyNull = NullWeak.IsExplicitlyNull();
	return !bLiveIsExplicitlyNull && bNullIsExplicitlyNull;
}
/** @end */
