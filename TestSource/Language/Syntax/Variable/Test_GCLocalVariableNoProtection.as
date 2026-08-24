// Theme: Language.Syntax.Variable. WorldStory: AS locals do not keep UObjects alive across GC.
// C++: AngelscriptCoverageGCTests.cpp::GCLocalVariableNoProtection
// spawn + BeginPlay + VerifyByPath LocalVariableDidNotProtect == true.
// sha256=42f2db16891617ea4231522ba85b3e4cfcc54c105250c92a28d1a1766e2815f2; lines 483-515.
// Extra: local construct leaves LocalVariableDidNotProtect false. FixtureIsolated.

UCLASS()
class ACoverageGCLocalVariableNoProtectionActor : AActor
{
	UPROPERTY()
	bool LocalVariableDidNotProtect = false;

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

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TestLocalScope();
	}
}

bool Observe_GCLocal_DefaultFalse(ACoverageGCLocalVariableNoProtectionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_GCLocalVariableNoProtection setup: required Actor is null");
	}
	return Actor.LocalVariableDidNotProtect == false;
}
