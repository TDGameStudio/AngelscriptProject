/**
 * @version v1
 * @summary Observe TObjectPtr and TWeakObjectPtr copy/object constructors.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe TObjectPtr and TWeakObjectPtr copy/object constructors.
 * @topic Baseline
 */
// TObjectPtr<T> Value(T Object);
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

namespace TS_BlueprintType_Behavior_02
{
	// TObjectPtr copy and object constructors preserve or null identity.
	// Inputs: actor CDO, copied TObjectPtr, null UObject.
	// Oracle: copy and object ctor match CDO; null ctor Get() is null.
	// Ownership: strong wrapper copy; CDO is not owned by the wrapper.
	bool Observe_Value_Nominal()
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

	// TWeakObjectPtr default, copy, object, and null constructors.
	// Inputs: default wrappers, actor CDO, null UObject.
	// Oracle: defaults are explicitly null; copy/object match CDO; null is explicit.
	// Ownership: weak wrapper does not keep the object alive.
	bool Observe_Surface032_Nominal()
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
}
/** @end */
