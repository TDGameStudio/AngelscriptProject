/**
 * @version v1
 * @summary Observe equality operators for typed class values, object pointers, and weak pointers against both wrapper and UObject operands.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe equality operators for typed class values, object pointers, and weak pointers against both wrapper and UObject operands.
 * @topic Baseline
 */
// bool bEqual = ObjectPtr == Other; bool bEqual = ObjectPtr == Object;
// bool bEqual = WeakPtr == Other; bool bEqual = WeakPtr == Object;
// Inputs: Two TSubclassOf values that share AActor::StaticClass(), one that
// selects APawn::StaticClass(), matching and distinct TObjectPtr/TWeakObjectPtr
// wrappers around the actor CDO, and an explicit null object as the zero operand.
// Expected observations: Same identity compares true; different class or object
// identity compares false; null compared with a live pointer is false.
// Boundary/ownership: Comparison uses UClass or UObject identity, not script
// wrapper identity. Weak equality also considers serial state. These operators
// are value-returning and do not mutate either operand.

namespace TS_BlueprintType_Operators_01
{
	bool Observe_Equality_Nominal()
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
}
/** @end */
