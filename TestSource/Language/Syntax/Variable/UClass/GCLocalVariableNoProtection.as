/**
 * A local variable in AngelScript does not keep a UObject alive across garbage
 * collection, unlike a C++ stack variable. BeginPlay holds an object only in a
 * local, forces collection, and records whether a weak reference to it died.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Variable.GCLocalVariableNoProtection
 * @Harness UClass
 * @Tag Language.Syntax.Variable.GCLocalVariableNoProtection
 * @Provenance C++: AngelscriptCoverageGCTests.cpp::GCLocalVariableNoProtection
 * @Provenance spawn + BeginPlay + VerifyByPath LocalVariableDidNotProtect == true.
 * @Provenance sha256=42f2db16891617ea4231522ba85b3e4cfcc54c105250c92a28d1a1766e2815f2; lines 483-515.
 * @Provenance Extra: local construct leaves LocalVariableDidNotProtect false. FixtureIsolated.
 */

UCLASS()
class ACoverageGCLocalVariableNoProtectionActor : AActor
{
	UPROPERTY()
	bool LocalVariableDidNotProtect = false;

	/**
	 * Holds an object only in a local, then forces collection.
	 *
	 * @Covers Syntax.Variable
	 * @Inputs none
	 * @Return nothing; LocalVariableDidNotProtect records the outcome
	 */
	void TestLocalScope()
	{
		// Create object in local scope
		UObject LocalObject = NewObject(GetTransientPackage(), UTexture2D::StaticClass());

		// Create weak reference to track it
		TWeakObjectPtr<UObject> WeakRef = LocalObject;

		// Force GC while local variable still exists
		CoverageGC::ForceGarbageCollectionNow();

		// Local variables in AngelScript do NOT protect from GC
		// (Unlike C++ stack variables which do protect)
		if (!WeakRef.IsValid())
		{
			LocalVariableDidNotProtect = true;
		}
	}

	/**
	 * Runs the local-scope probe during play.
	 *
	 * @Covers Syntax.Variable
	 * @Inputs none
	 * @Return nothing; the flag is set by TestLocalScope
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TestLocalScope();
	}

	/**
	 * Observe the state of a locally constructed actor before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Variable
	 * @Inputs a locally constructed actor
	 * @Return true when the flag is still false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool GCLocalFlagDefaultsToFalse()
	{
		return LocalVariableDidNotProtect == false;
	}
}
