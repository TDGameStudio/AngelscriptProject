/**
 * A compile-events compatibility carrier. The module compiles and
 * UCompilationEventsDelegates.Entry() returns 13.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.ExistingCompileDelegatesRemainCompatible
 * @Harness UClass
 * @Tag Feature.Delegates.ExistingCompileDelegatesRemainCompatible
 * @Provenance Theme: Feature.Delegates. Positive compile-events compatibility carrier.
 * @Provenance C++: AngelscriptCompilerEventsTests.cpp::ExistingCompileDelegatesRemainCompatible
 * @Provenance Oracle: module compiles; UCompilationEventsDelegates.Entry()==13.
 * @Provenance Extra: empty object is null. DefaultSafe.
 */

UCLASS()
class UCompilationEventsDelegates : UObject
{
	/**
	 * The C++ execution oracle.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Inputs none
	 * @Return 13
	 */
	UFUNCTION()
	int Entry()
	{
		return 13;
	}

	/**
	 * Observe that a default-constructed handle is null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Inputs a local UCompilationEventsDelegates
	 * @Return true when the handle is null
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		UCompilationEventsDelegates Obj;
		return Obj == nullptr;
	}

	/**
	 * Observe Entry on a runner-owned instance.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Inputs this
	 * @Return 13
	 */
	UFUNCTION()
	int EntryOnThis()
	{
		return Entry();
	}
}
