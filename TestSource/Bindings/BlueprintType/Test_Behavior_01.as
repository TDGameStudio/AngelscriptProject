// Purpose: Observe BlueprintType runtime patterns: reference-type declaration,
// __StaticType class values, property/function expansion, and TSubclassOf /
// TObjectPtr construction overloads.
// AS-facing API: <TypeName> Object;
// const TSubclassOf<UObject> __StaticType_<TypeName>;
// <PropertyType> <TypeName>.<PropertyName>;
// <ReturnType> <TypeName>.<FunctionName>(<Parameters>);
// TSubclassOf<T> Value; TSubclassOf<T> Value();
// TSubclassOf<T> Value(const TSubclassOf<T>& Other);
// TSubclassOf<T> Value(UClass Class);
// TObjectPtr<T> Value; TObjectPtr<T> Value();
// Inputs: A live UObject-derived actor CDO, empty/default wrappers, a copied
// TSubclassOf, and APawn::StaticClass() as a boundary subclass.
// Expected observations: Declared objects are usable handles. Empty TSubclassOf
// and TObjectPtr construct as null. Copy and UClass constructors preserve
// identity. Reading a reflected property and calling a reflected function
// consume their results.
// Boundary/ownership: TypeName comes from the bind database or reflected
// metadata. Property read/write follows metadata. TSubclassOf(UClass) validates
// the template subtype. TObjectPtr() is a null strong wrapper.

UCLASS(BlueprintType)
class UTSBlueprintTypeBehaviorCarrier : UObject
{
	UPROPERTY()
	int StoredValue = 7;

	UFUNCTION(BlueprintCallable)
	int ReadStoredValue()
	{
		return StoredValue;
	}
}

namespace TS_BlueprintType_Behavior_01
{
	// <TypeName> Object declares a live BlueprintType reference handle.
	// Inputs: default UTSBlueprintTypeBehaviorCarrier Object.
	// Oracle: Object is non-null.
	// Ownership: script-owned UObject handle; null Object is setup failure.
	bool Observe_Surface001_Nominal()
	{
		UTSBlueprintTypeBehaviorCarrier Object;
		if (Object is null)
		{
			throw("TS_BlueprintType_Behavior_01 setup: required Object is null");
		}
		return Object.StoredValue == 7;
	}

	// const TSubclassOf<UObject> __StaticType / StaticClass exposes the reflected class.
	// Inputs: UTSBlueprintTypeBehaviorCarrier::StaticClass().
	// Oracle: Get() identity equals StaticClass().
	// Ownership: borrowed UClass; no new instance.
	bool Observe_Surface003_Nominal()
	{
		TSubclassOf<UObject> StaticType = UTSBlueprintTypeBehaviorCarrier::StaticClass();
		UClass StaticClassValue = StaticType.Get();
		return StaticClassValue == UTSBlueprintTypeBehaviorCarrier::StaticClass();
	}

	// <PropertyType> <TypeName>.<PropertyName> follows UPROPERTY metadata.
	// Inputs: StoredValue default 7, write 11.
	// Oracle: before is 7 and after is 11.
	// Ownership: property storage on the script object.
	bool Observe_Surface004_Nominal()
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

	// <ReturnType> <TypeName>.<FunctionName>(<Parameters>) calls the reflected UFUNCTION.
	// Inputs: default StoredValue 7, ReadStoredValue().
	// Oracle: result is 7.
	// Ownership: call borrows Object; no extra instance.
	bool Observe_Surface005_Nominal()
	{
		UTSBlueprintTypeBehaviorCarrier Object;
		if (Object is null)
		{
			throw("TS_BlueprintType_Behavior_01 setup: required Object is null");
		}
		int Result = Object.ReadStoredValue();
		return Result == 7;
	}

	// <TypeName>::StaticClass() is the static namespace surface for the class.
	// Inputs: UTSBlueprintTypeBehaviorCarrier::StaticClass().
	// Oracle: returned UClass is non-null.
	// Ownership: borrowed UClass handle.
	bool Observe_Surface007_Nominal()
	{
		return UTSBlueprintTypeBehaviorCarrier::StaticClass() != nullptr;
	}

	// TSubclassOf/TObjectPtr default, copy, and UClass constructors.
	// Inputs: empty wrappers, AActor copy, APawn UClass, default TObjectPtr.
	// Oracle: empty is invalid/null; copy and UClass preserve identity.
	// Ownership: wrappers store class/object identity; they do not own UClass/UObject.
	bool Observe_Value_Nominal()
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

	// TObjectPtr<T> default construction is a null strong wrapper.
	// Inputs: declared and default TObjectPtr of the carrier type.
	// Oracle: Get() is null for both.
	// Ownership: strong wrapper of a null handle; no UObject is created.
	bool Observe_Surface022_Nominal()
	{
		TObjectPtr<UTSBlueprintTypeBehaviorCarrier> DeclaredPtr;
		TObjectPtr<UTSBlueprintTypeBehaviorCarrier> NullConstructed;
		UTSBlueprintTypeBehaviorCarrier FromDeclared = DeclaredPtr.Get();
		UTSBlueprintTypeBehaviorCarrier FromNull = NullConstructed.Get();
		return FromDeclared is null && FromNull is null;
	}
}
