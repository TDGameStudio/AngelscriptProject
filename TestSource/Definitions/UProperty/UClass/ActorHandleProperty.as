/**
 * An AActor handle UPROPERTY currently compiles because script object
 * references are handles, not raw pointers. C++ wraps the failure in #if 0
 * (structural-validation-absent). The observers cover the null default and a
 * this-assignment boundary.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.ActorHandleProperty
 * @Harness UClass
 * @Tag Definitions.UProperty.ActorHandleProperty
 * @Provenance Theme: Definitions.UProperty. CSV NegativeDiagnostic. C++ wraps AssertFailsToCompile
 * @Provenance in #if 0 (#as-engine-behavior: structural-validation-absent) so an AActor handle
 * @Provenance UPROPERTY currently compiles (script object references are handles, not raw pointers).
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Negative
 * @Provenance UPropTN_RawPointer; lines 497-503;
 * @Provenance sha256=dad58ce9af3f86de94ee038d0e2d7cc5907a205403257bc5846daea7546183be.
 * @Provenance Oracle: Ptr default is null. Extra: null empty/default; this-assignment is the live boundary.
 * @Provenance FixtureIsolated.
 */

class AUPropRawPtrActor : AActor
{
	UPROPERTY()
	AActor Ptr = nullptr;

	/**
	 * Observe the default Ptr of null.
	 *
	 * @Kind Observe
	 * @Covers UProperty.ActorHandleProperty
	 * @Inputs none
	 * @Return true when Ptr is null
	 */
	UFUNCTION()
	bool PtrDefault()
	{
		return Ptr == nullptr;
	}

	/**
	 * Observe that the empty default is null.
	 *
	 * @Kind Observe
	 * @Covers UProperty.ActorHandleProperty
	 * @Inputs none
	 * @Return true when Ptr is null
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool PtrEmptyDefault()
	{
		return Ptr == nullptr;
	}

	/**
	 * Observe assigning this to Ptr then restoring null.
	 *
	 * @Kind Observe
	 * @Covers UProperty.ActorHandleProperty
	 * @Inputs Ptr assigned to this then restored
	 * @Return true when the assignment is non-null and the saved default is null
	 * @Boundary this-assignment
	 */
	UFUNCTION()
	bool PtrAssignBoundary()
	{
		AActor Saved = Ptr;
		Ptr = this;
		bool bAssigned = Ptr != nullptr;
		Ptr = Saved;
		if (!bAssigned)
		{
			return false;
		}
		return Saved == nullptr;
	}
}
