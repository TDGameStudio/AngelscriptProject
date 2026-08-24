// Purpose: Observe TSubclassOf, TObjectPtr, and TWeakObjectPtr assignment and
// implicit conversion, including copy independence and null identity.
// AS-facing API: Subclass = Other; Subclass = Class; UClass Class = Subclass;
// UObject Object = Subclass; ObjectPtr = Other; ObjectPtr = Object;
// T Object = ObjectPtr; WeakPtr = Other; WeakPtr = Object; T Object = WeakPtr;
// Inputs: Default-empty wrappers, AActor::StaticClass(), APawn::StaticClass(),
// the actor class default object as a live handle, and an explicit null object.
// Expected observations: Copy assignment preserves UClass identity. Assigning
// a compatible UClass replaces the selected subclass. Implicit conversion to
// UClass and UObject yields the same identity. ObjectPtr and WeakPtr resolve
// to the live CDO or null without taking extra ownership of the UObject.
// Boundary/ownership: TSubclassOf validates that Class derives from T.
// TObjectPtr is a strong wrapper. TWeakObjectPtr does not keep the object
// alive; resolving a null weak pointer yields null rather than a stale object.

namespace TS_BlueprintType_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
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
}
