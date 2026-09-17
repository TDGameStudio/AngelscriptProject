/**
 * @version v1
 * @summary Observe TSoftObjectPtr and TSoftClassPtr assignment from path, live object/class, copy, and TSubclassOf.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe TSoftObjectPtr and TSoftClassPtr assignment from path, live object/class, copy, and TSubclassOf.
 * @topic Baseline
 */
// ClassRef = Path; ClassRef = Object; ClassRef = OtherClassRef;
// ClassRef = Subclass;
// Inputs: Live actor CDO, AActor::StaticClass(), empty path, a copied other
// pointer, and TSubclassOf<AActor>.
// Expected observations: Assignment from a live CDO Get() matches that
// identity. Copy assignment preserves ToSoftObjectPath. Null object
// assignment yields IsNull. ClassRef from StaticClass Get() is AActor.
// Boundary/ownership: Assignment copies the path/handle and does not take
// extra UObject ownership. TSoftClassPtr from TSubclassOf stores the class
// path without constructing an instance.

namespace TS_TSoftObjectPtr_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_TSoftObjectPtr_ConstructionAndAssignment_01 setup: required AActor CDO is null");
		}
		FSoftObjectPath Path(LiveCdo);
		TSoftObjectPtr<UObject> ObjectRef;
		ObjectRef = Path;
		bool bAssignedPath = !ObjectRef.IsNull() && ObjectRef.ToSoftObjectPath() == Path;

		ObjectRef = LiveCdo;
		bool bAssignedObject = ObjectRef.Get() == LiveCdo && ObjectRef.IsValid();

		TSoftObjectPtr<UObject> Other = LiveCdo;
		ObjectRef = Other;
		bool bAssignedOther = ObjectRef.Get() == LiveCdo;

		UObject NullObject = nullptr;
		ObjectRef = NullObject;
		bool bAssignedNull = ObjectRef.IsNull() && ObjectRef.Get() == nullptr;

		TSubclassOf<AActor> Subclass = AActor::StaticClass();
		TSoftClassPtr<AActor> ClassRef;
		FSoftObjectPath ClassPath = TSoftClassPtr<AActor>(AActor::StaticClass()).ToSoftObjectPath();
		ClassRef = ClassPath;
		bool bAssignedClassPath = !ClassRef.IsNull();

		ClassRef = AActor::StaticClass();
		bool bAssignedClass = ClassRef.Get().Get() == AActor::StaticClass();

		TSoftClassPtr<AActor> OtherClassRef = AActor::StaticClass();
		ClassRef = OtherClassRef;
		bool bAssignedOtherClass = ClassRef.Get().Get() == AActor::StaticClass();

		ClassRef = Subclass;
		return bAssignedPath &&
			bAssignedObject &&
			bAssignedOther &&
			bAssignedNull &&
			bAssignedClassPath &&
			bAssignedClass &&
			bAssignedOtherClass &&
			ClassRef == Subclass;
	}
}
/** @end */
