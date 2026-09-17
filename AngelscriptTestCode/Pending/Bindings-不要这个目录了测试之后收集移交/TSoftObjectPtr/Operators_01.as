/**
 * @version v1
 * @summary Observe TSoftObjectPtr/TSoftClassPtr equality against other wrappers, live objects, and TSubclassOf.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe TSoftObjectPtr/TSoftClassPtr equality against other wrappers, live objects, and TSubclassOf.
 * @topic Baseline
 */
// bool bEqual = ClassRef == OtherClassRef; bool bEqual = ClassRef == Subclass;
// bool bEqual = ClassRef == Object;
// Inputs: Two pointers to the same actor CDO, an empty pointer as the zero
// operand, AActor::StaticClass() vs UObject::StaticClass().
// Expected observations: Same CDO pointers compare true. Live pointer vs
// null object is false. Matching class refs and TSubclassOf compare true.
// Distinct class identity compares false.
// Boundary/ownership: Equality uses referenced identity, not wrapper
// identity, and does not load a pending path.

namespace TS_TSoftObjectPtr_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_TSoftObjectPtr_Operators_01 setup: required AActor CDO is null");
		}
		TSoftObjectPtr<UObject> ObjectRef = LiveCdo;
		TSoftObjectPtr<UObject> Other = LiveCdo;
		TSoftObjectPtr<UObject> Empty;
		UObject NullObject = nullptr;

		TSubclassOf<AActor> Subclass = AActor::StaticClass();
		TSoftClassPtr<AActor> ClassRef = AActor::StaticClass();
		TSoftClassPtr<AActor> OtherClassRef = AActor::StaticClass();
		UClass ActorClass = AActor::StaticClass();
		UClass ObjectClass = UObject::StaticClass();

		return ObjectRef == Other &&
			ObjectRef == LiveCdo &&
			!(ObjectRef == NullObject) &&
			Empty == NullObject &&
			ClassRef == OtherClassRef &&
			ClassRef == Subclass &&
			ClassRef == ActorClass &&
			!(ClassRef == ObjectClass);
	}
}
/** @end */
