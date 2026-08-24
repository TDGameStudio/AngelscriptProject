// Framework contract: AssertTrue/False, AssertNull/NotNull, and
// AssertSame/NotSame report passing overloads silently and failing
// overloads with one source-located custom message each.
// Payload: true/false, this/nullptr, and distinct NewObject identities are
// enough to exercise each overload without depending on World APIs.
// Expected observations: the passing leaf is silent; each failing leaf
// emits exactly one diagnostic containing its unique message and call-site
// line.
// C++ oracle required: diagnostic count, custom text, source location, and
// that later statements in a failing leaf do not run.

UCLASS()
class UTestSourceBooleanIdentityObject : UObject
{
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceBooleanNullIdentityAssertionsSuite : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void VerifyBooleanNullIdentityAssertions()
	{
		UObject Other = FAngelscriptTest::SpawnObject(
			UTestSourceBooleanIdentityObject::StaticClass());
		AssertTrue(true);
		AssertFalse(false);
		AssertNull(nullptr);
		AssertNotNull(this);
		AssertSame(this, this);
		AssertNotSame(this, Other);
		AssertNotSame(this, nullptr);
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailAssertTrue()
	{
		AssertTrue(false, "TS-FW-ASSERTIONS-001 AssertTrue fail");
		Fail("TS-FW-ASSERTIONS-001 AssertTrue must fail-fast");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailAssertFalse()
	{
		AssertFalse(true, "TS-FW-ASSERTIONS-001 AssertFalse fail");
		Fail("TS-FW-ASSERTIONS-001 AssertFalse must fail-fast");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailAssertNull()
	{
		AssertNull(this, "TS-FW-ASSERTIONS-001 AssertNull fail");
		Fail("TS-FW-ASSERTIONS-001 AssertNull must fail-fast");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailAssertNotNull()
	{
		AssertNotNull(nullptr, "TS-FW-ASSERTIONS-001 AssertNotNull fail");
		Fail("TS-FW-ASSERTIONS-001 AssertNotNull must fail-fast");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailAssertSame()
	{
		UObject Other = FAngelscriptTest::SpawnObject(
			UTestSourceBooleanIdentityObject::StaticClass());
		AssertSame(this, Other, "TS-FW-ASSERTIONS-001 AssertSame fail");
		Fail("TS-FW-ASSERTIONS-001 AssertSame must fail-fast");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailAssertNotSame()
	{
		AssertNotSame(this, this, "TS-FW-ASSERTIONS-001 AssertNotSame fail");
		Fail("TS-FW-ASSERTIONS-001 AssertNotSame must fail-fast");
	}
}
