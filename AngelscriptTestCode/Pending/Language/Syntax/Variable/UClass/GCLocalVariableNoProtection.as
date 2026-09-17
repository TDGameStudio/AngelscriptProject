/**
 * @version v1
 * @summary A local variable in AngelScript does not keep a UObject alive across garbage collection, unlike a C++ stack variable. BeginPlay holds an object only in a local, forces collection, and records whether a weak reference to.
 * @topic Language
 */
/**
 * @version root
 * @summary A local variable in AngelScript does not keep a UObject alive across garbage collection, unlike a C++ stack variable. BeginPlay holds an object only in a local, forces collection, and records whether a weak reference to.
 * @topic Baseline
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
/** @end */
