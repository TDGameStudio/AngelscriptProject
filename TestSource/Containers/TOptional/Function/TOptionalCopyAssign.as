/**
 * TOptional.opAssign copies another optional, preserving its set state in
 * both directions: assigning a set optional sets the target, and assigning
 * an unset one unsets it. opEquals compares presence first and, when both
 * are set, the contained value. The implicit value constructor is observed
 * here too because it is the third way to produce a set optional.
 * int is canonical; other element shapes repeat the same four entries with
 * a type suffix.
 *
 * @Theme Containers.TOptional
 * @Subject TOptional.opAssign
 * @Harness Function
 * @Tag Containers.TOptional.TOptionalCopyAssign
 * @Namespace TOptionalTest
 */

UCLASS()
class UTOptionalCopyAssignObject : UObject
{
}

namespace TOptionalTest
{
	/**
	 * Observe optional-to-optional assign: the set state and value are copied.
	 *
	 * @Kind Observe
	 * @Covers TOptional.opAssign
	 * @Inputs Source TOptional<int> set to 42; assign onto a default-constructed target
	 * @Return true when the target is set, holds 42, and equals the source
	 */
	UFUNCTION()
	bool AssignSetOptionalCopiesStateAndValue()
	{
		TOptional<int> Source;
		Source.Set(42);

		TOptional<int> Target;
		if (Target.IsSet())
		{
			return false;
		}

		Target = Source;
		return Target.IsSet()
			&& Target.GetValue() == 42
			&& Target == Source;
	}

	/**
	 * Observe that assigning an unset optional unsets an already-set target.
	 *
	 * @Kind Observe
	 * @Covers TOptional.opAssign
	 * @Inputs Target set to 42; assign a default-constructed unset optional onto it
	 * @Return true when the target ends up unset
	 */
	UFUNCTION()
	bool AssignUnsetOptionalClearsTarget()
	{
		TOptional<int> Target;
		Target.Set(42);
		if (!Target.IsSet())
		{
			return false;
		}

		TOptional<int> Unset;
		Target = Unset;
		return !Target.IsSet();
	}

	/**
	 * Observe that assignment copies by value: mutating the source afterwards
	 * leaves the target untouched.
	 *
	 * @Kind Observe
	 * @Covers TOptional.opAssign
	 * @Inputs Source set to 42; assign to Target; then Set(7) on the source
	 * @Return true when the target still holds 42 and the two differ
	 */
	UFUNCTION()
	bool AssignedOptionalIsIndependentOfSource()
	{
		TOptional<int> Source;
		Source.Set(42);

		TOptional<int> Target;
		Target = Source;

		Source.Set(7);
		return Target.GetValue() == 42
			&& Source.GetValue() == 7
			&& Target != Source;
	}

	/**
	 * Observe opEquals: two optionals holding the same value are equal.
	 *
	 * @Kind Observe
	 * @Covers TOptional.opEquals
	 * @Inputs Two TOptional<int> both set to 42
	 * @Return true when they compare equal
	 */
	UFUNCTION()
	bool SetOptionalsWithSameValueAreEqual()
	{
		TOptional<int> First;
		First.Set(42);

		TOptional<int> Second;
		Second.Set(42);

		return First == Second;
	}

	/**
	 * Observe opEquals: two set optionals holding different values are unequal.
	 *
	 * @Kind Observe
	 * @Covers TOptional.opEquals
	 * @Inputs Two TOptional<int> set to 42 and 43
	 * @Return true when they compare unequal
	 */
	UFUNCTION()
	bool SetOptionalsWithDifferentValuesDiffer()
	{
		TOptional<int> First;
		First.Set(42);

		TOptional<int> Second;
		Second.Set(43);

		return First != Second;
	}

	/**
	 * Observe the implicit value constructor: initializing from a value produces a set optional.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Construct
	 * @Inputs TOptional<int> initialized from the literal 42
	 * @Return true when the optional is set and holds 42
	 */
	UFUNCTION()
	bool ImplicitConstructFromValueIsSet()
	{
		TOptional<int> Opt = 42;
		return Opt.IsSet() && Opt.GetValue() == 42;
	}

	/**
	 * In-only: compare a const&in TOptional<int> against a locally built one.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.opAssign
	 * @Param Value Source optional received as const TOptional<int>&in
	 * @Inputs Value holds 42
	 * @Return true when a local copy of Value equals a locally built 42
	 */
	UFUNCTION()
	bool ReadAndCompareAssignedOptional(const TOptional<int>&in Value)
	{
		TOptional<int> Copy;
		Copy = Value;

		TOptional<int> Expected = 42;
		return Copy.IsSet() && Copy == Expected;
	}

	/**
	 * Out-only: copy a locally built optional into an empty &out.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.opAssign
	 * @Param Result Destination received as TOptional<int>&out
	 * @Inputs Empty &out TOptional<int>
	 * @Return void; Result holds 42
	 */
	UFUNCTION()
	void FillByAssigningOptional(TOptional<int>&out Result)
	{
		TOptional<int> Source = 42;
		Result = Source;
	}

	/**
	 * Inout: overwrite an assigned optional with a different set one.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.opAssign
	 * @Param Value Optional received as TOptional<int>&inout, starts holding 42
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value holds 7
	 */
	UFUNCTION()
	void ReassignDifferentOptional(TOptional<int>&inout Value)
	{
		TOptional<int> Other = 7;
		Value = Other;
	}


	/**
	 * Observe optional-to-optional assign for FString.
	 *
	 * @Kind Observe
	 * @Covers TOptional.opAssign
	 * @Inputs Source TOptional<FString> set to "alpha"; assign onto a default target
	 * @Return true when the target is set, holds "alpha", and equals the source
	 */
	UFUNCTION()
	bool AssignSetOptionalCopiesStateAndValue_FString()
	{
		TOptional<FString> Source;
		Source.Set("alpha");

		TOptional<FString> Target;
		Target = Source;
		return Target.IsSet()
			&& Target.GetValue() == "alpha"
			&& Target == Source;
	}

	/**
	 * Observe that assigning an unset optional unsets a set FString target.
	 *
	 * @Kind Observe
	 * @Covers TOptional.opAssign
	 * @Inputs Target set to "alpha"; assign an unset optional onto it
	 * @Return true when the target ends up unset
	 */
	UFUNCTION()
	bool AssignUnsetOptionalClearsTarget_FString()
	{
		TOptional<FString> Target;
		Target.Set("alpha");

		TOptional<FString> Unset;
		Target = Unset;
		return !Target.IsSet();
	}

	/**
	 * Observe copy independence for FString after an optional-to-optional assign.
	 *
	 * @Kind Observe
	 * @Covers TOptional.opAssign
	 * @Inputs Source set to "alpha"; assign to Target; then Set("beta") on the source
	 * @Return true when the target still holds "alpha" and the two differ
	 */
	UFUNCTION()
	bool AssignedOptionalIsIndependentOfSource_FString()
	{
		TOptional<FString> Source;
		Source.Set("alpha");

		TOptional<FString> Target;
		Target = Source;

		Source.Set("beta");
		return Target.GetValue() == "alpha"
			&& Source.GetValue() == "beta"
			&& Target != Source;
	}

	/**
	 * In-only: compare a const&in TOptional<FString> against a locally built one.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.opAssign
	 * @Param Value Source optional received as const TOptional<FString>&in
	 * @Inputs Value holds "alpha"
	 * @Return true when a local copy equals a locally built "alpha"
	 */
	UFUNCTION()
	bool ReadAndCompareAssignedOptional_FString(const TOptional<FString>&in Value)
	{
		TOptional<FString> Copy;
		Copy = Value;

		TOptional<FString> Expected = "alpha";
		return Copy.IsSet() && Copy == Expected;
	}

	/**
	 * Out-only: copy a locally built optional into an empty &out.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.opAssign
	 * @Param Result Destination received as TOptional<FString>&out
	 * @Inputs Empty &out TOptional<FString>
	 * @Return void; Result holds "alpha"
	 */
	UFUNCTION()
	void FillByAssigningOptional_FString(TOptional<FString>&out Result)
	{
		TOptional<FString> Source = "alpha";
		Result = Source;
	}

	/**
	 * Inout: overwrite an assigned optional with a different set one.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.opAssign
	 * @Param Value Optional received as TOptional<FString>&inout, starts holding "alpha"
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value holds "beta"
	 */
	UFUNCTION()
	void ReassignDifferentOptional_FString(TOptional<FString>&inout Value)
	{
		TOptional<FString> Other = "beta";
		Value = Other;
	}


	/**
	 * Observe optional-to-optional assign for FName.
	 *
	 * @Kind Observe
	 * @Covers TOptional.opAssign
	 * @Inputs Source TOptional<FName> set to n"Red"; assign onto a default target
	 * @Return true when the target is set, holds n"Red", and equals the source
	 */
	UFUNCTION()
	bool AssignSetOptionalCopiesStateAndValue_FName()
	{
		TOptional<FName> Source;
		Source.Set(n"Red");

		TOptional<FName> Target;
		Target = Source;
		return Target.IsSet()
			&& Target.GetValue() == n"Red"
			&& Target == Source;
	}

	/**
	 * Observe copy independence for FName after an optional-to-optional assign.
	 *
	 * @Kind Observe
	 * @Covers TOptional.opAssign
	 * @Inputs Source set to n"Red"; assign to Target; then Set(n"Green") on the source
	 * @Return true when the target still holds n"Red" and the two differ
	 */
	UFUNCTION()
	bool AssignedOptionalIsIndependentOfSource_FName()
	{
		TOptional<FName> Source;
		Source.Set(n"Red");

		TOptional<FName> Target;
		Target = Source;

		Source.Set(n"Green");
		return Target.GetValue() == n"Red"
			&& Source.GetValue() == n"Green"
			&& Target != Source;
	}

	/**
	 * In-only: compare a const&in TOptional<FName> against a locally built one.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.opAssign
	 * @Param Value Source optional received as const TOptional<FName>&in
	 * @Inputs Value holds n"Red"
	 * @Return true when a local copy equals a locally built n"Red"
	 */
	UFUNCTION()
	bool ReadAndCompareAssignedOptional_FName(const TOptional<FName>&in Value)
	{
		TOptional<FName> Copy;
		Copy = Value;

		TOptional<FName> Expected = n"Red";
		return Copy.IsSet() && Copy == Expected;
	}

	/**
	 * Out-only: copy a locally built optional into an empty &out.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.opAssign
	 * @Param Result Destination received as TOptional<FName>&out
	 * @Inputs Empty &out TOptional<FName>
	 * @Return void; Result holds n"Red"
	 */
	UFUNCTION()
	void FillByAssigningOptional_FName(TOptional<FName>&out Result)
	{
		TOptional<FName> Source = n"Red";
		Result = Source;
	}

	/**
	 * Inout: overwrite an assigned optional with a different set one.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.opAssign
	 * @Param Value Optional received as TOptional<FName>&inout, starts holding n"Red"
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value holds n"Green"
	 */
	UFUNCTION()
	void ReassignDifferentOptional_FName(TOptional<FName>&inout Value)
	{
		TOptional<FName> Other = n"Green";
		Value = Other;
	}


	/**
	 * Observe optional-to-optional assign for bool, including equality of two stored falses.
	 *
	 * @Kind Observe
	 * @Covers TOptional.opAssign
	 * @Inputs Source TOptional<bool> set to false; assign onto a default target
	 * @Return true when the target is set, holds false, and equals the source
	 */
	UFUNCTION()
	bool AssignSetOptionalCopiesStateAndValue_bool()
	{
		TOptional<bool> Source;
		Source.Set(false);

		TOptional<bool> Target;
		Target = Source;
		return Target.IsSet()
			&& Target.GetValue() == false
			&& Target == Source;
	}

	/**
	 * Observe that assigning an unset optional unsets a set bool target.
	 *
	 * @Kind Observe
	 * @Covers TOptional.opAssign
	 * @Inputs Target set to true; assign an unset optional onto it
	 * @Return true when the target ends up unset
	 */
	UFUNCTION()
	bool AssignUnsetOptionalClearsTarget_bool()
	{
		TOptional<bool> Target;
		Target.Set(true);

		TOptional<bool> Unset;
		Target = Unset;
		return !Target.IsSet();
	}

	/**
	 * In-only: compare a const&in TOptional<bool> against a locally built one.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.opAssign
	 * @Param Value Source optional received as const TOptional<bool>&in
	 * @Inputs Value holds true
	 * @Return true when a local copy equals a locally built true
	 */
	UFUNCTION()
	bool ReadAndCompareAssignedOptional_bool(const TOptional<bool>&in Value)
	{
		TOptional<bool> Copy;
		Copy = Value;

		TOptional<bool> Expected = true;
		return Copy.IsSet() && Copy == Expected;
	}

	/**
	 * Out-only: copy a locally built optional into an empty &out.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.opAssign
	 * @Param Result Destination received as TOptional<bool>&out
	 * @Inputs Empty &out TOptional<bool>
	 * @Return void; Result holds true
	 */
	UFUNCTION()
	void FillByAssigningOptional_bool(TOptional<bool>&out Result)
	{
		TOptional<bool> Source = true;
		Result = Source;
	}

	/**
	 * Inout: overwrite an assigned optional with a different set one.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.opAssign
	 * @Param Value Optional received as TOptional<bool>&inout, starts holding true
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value holds false
	 */
	UFUNCTION()
	void ReassignDifferentOptional_bool(TOptional<bool>&inout Value)
	{
		TOptional<bool> Other = false;
		Value = Other;
	}


	/**
	 * Observe optional-to-optional assign for FVector.
	 *
	 * @Kind Observe
	 * @Covers TOptional.opAssign
	 * @Inputs Source TOptional<FVector> set to the X axis; assign onto a default target
	 * @Return true when the target is set, holds the X axis, and equals the source
	 */
	UFUNCTION()
	bool AssignSetOptionalCopiesStateAndValue_FVector()
	{
		TOptional<FVector> Source;
		Source.Set(FVector(1.0f, 0.0f, 0.0f));

		TOptional<FVector> Target;
		Target = Source;
		return Target.IsSet()
			&& Target.GetValue().Equals(FVector(1.0f, 0.0f, 0.0f))
			&& Target == Source;
	}

	/**
	 * Observe copy independence for FVector after an optional-to-optional assign.
	 *
	 * @Kind Observe
	 * @Covers TOptional.opAssign
	 * @Inputs Source set to the X axis; assign to Target; then Set(Y axis) on the source
	 * @Return true when the target still holds the X axis and the two differ
	 */
	UFUNCTION()
	bool AssignedOptionalIsIndependentOfSource_FVector()
	{
		TOptional<FVector> Source;
		Source.Set(FVector(1.0f, 0.0f, 0.0f));

		TOptional<FVector> Target;
		Target = Source;

		Source.Set(FVector(0.0f, 1.0f, 0.0f));
		return Target.GetValue().Equals(FVector(1.0f, 0.0f, 0.0f))
			&& Source.GetValue().Equals(FVector(0.0f, 1.0f, 0.0f))
			&& Target != Source;
	}

	/**
	 * In-only: compare a const&in TOptional<FVector> against a locally built one.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.opAssign
	 * @Param Value Source optional received as const TOptional<FVector>&in
	 * @Inputs Value holds the X axis
	 * @Return true when a local copy equals a locally built X axis
	 */
	UFUNCTION()
	bool ReadAndCompareAssignedOptional_FVector(const TOptional<FVector>&in Value)
	{
		TOptional<FVector> Copy;
		Copy = Value;

		TOptional<FVector> Expected = FVector(1.0f, 0.0f, 0.0f);
		return Copy.IsSet() && Copy == Expected;
	}

	/**
	 * Out-only: copy a locally built optional into an empty &out.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.opAssign
	 * @Param Result Destination received as TOptional<FVector>&out
	 * @Inputs Empty &out TOptional<FVector>
	 * @Return void; Result holds the X axis
	 */
	UFUNCTION()
	void FillByAssigningOptional_FVector(TOptional<FVector>&out Result)
	{
		TOptional<FVector> Source = FVector(1.0f, 0.0f, 0.0f);
		Result = Source;
	}

	/**
	 * Inout: overwrite an assigned optional with a different set one.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.opAssign
	 * @Param Value Optional received as TOptional<FVector>&inout, starts holding the X axis
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value holds the Y axis
	 */
	UFUNCTION()
	void ReassignDifferentOptional_FVector(TOptional<FVector>&inout Value)
	{
		TOptional<FVector> Other = FVector(0.0f, 1.0f, 0.0f);
		Value = Other;
	}


	/**
	 * Observe optional-to-optional assign for UObject: the pointer identity is shared.
	 *
	 * @Kind Observe
	 * @Covers TOptional.opAssign
	 * @Inputs Source TOptional<UObject> set to First; assign onto a default target
	 * @Return true when the target holds the same non-null pointer and equals the source
	 */
	UFUNCTION()
	bool AssignSetOptionalCopiesStateAndValue_UObject()
	{
		UObject First = NewObject(GetTransientPackage(), UTOptionalCopyAssignObject::StaticClass(), n"TOptionalCopyAssign_First", true);
		if (First == nullptr)
		{
			return false;
		}

		TOptional<UObject> Source;
		Source.Set(First);

		TOptional<UObject> Target;
		Target = Source;
		return Target.IsSet()
			&& Target.GetValue() == First
			&& Target == Source;
	}

	/**
	 * Observe that assigning an unset optional unsets a set UObject target.
	 *
	 * @Kind Observe
	 * @Covers TOptional.opAssign
	 * @Inputs Target set to an object; assign an unset optional onto it
	 * @Return true when the target ends up unset
	 */
	UFUNCTION()
	bool AssignUnsetOptionalClearsTarget_UObject()
	{
		TOptional<UObject> Target;
		Target.Set(NewObject(GetTransientPackage(), UTOptionalCopyAssignObject::StaticClass(), n"TOptionalCopyAssign_Clear", true));
		if (!Target.IsSet())
		{
			return false;
		}

		TOptional<UObject> Unset;
		Target = Unset;
		return !Target.IsSet();
	}

	/**
	 * In-only: compare a const&in TOptional<UObject> against a local copy.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.opAssign
	 * @Param Value Source optional received as const TOptional<UObject>&in
	 * @Inputs Value holds a non-null object
	 * @Return true when a local copy equals the source and is non-null
	 */
	UFUNCTION()
	bool ReadAndCompareAssignedOptional_UObject(const TOptional<UObject>&in Value)
	{
		TOptional<UObject> Copy;
		Copy = Value;
		return Copy.IsSet() && Copy == Value && Copy.GetValue() != nullptr;
	}

	/**
	 * Out-only: copy a locally built optional into an empty &out.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.opAssign
	 * @Param Result Destination received as TOptional<UObject>&out
	 * @Inputs Empty &out TOptional<UObject>
	 * @Return void; Result holds a non-null object
	 */
	UFUNCTION()
	void FillByAssigningOptional_UObject(TOptional<UObject>&out Result)
	{
		TOptional<UObject> Source;
		Source.Set(NewObject(GetTransientPackage(), UTOptionalCopyAssignObject::StaticClass(), n"TOptionalCopyAssign_Fill", true));
		Result = Source;
	}

	/**
	 * Inout: overwrite an assigned optional with a different set one.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.opAssign
	 * @Param Value Optional received as TOptional<UObject>&inout, starts holding an object
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value holds a different non-null object
	 */
	UFUNCTION()
	void ReassignDifferentOptional_UObject(TOptional<UObject>&inout Value)
	{
		TOptional<UObject> Other;
		Other.Set(NewObject(GetTransientPackage(), UTOptionalCopyAssignObject::StaticClass(), n"TOptionalCopyAssign_Reassign", true));
		Value = Other;
	}
}
