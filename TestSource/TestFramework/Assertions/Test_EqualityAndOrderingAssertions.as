// Framework contract: AssertEquals/NotEquals and Less/LessOrEqual/
// Greater/GreaterOrEqual overloads compare scalar and representative UE
// values. Failures must keep actual and expected text in the diagnostic.
// Payload: integer, floating, bool, FName, FString, FText.ToString(),
// EObjectTypeQuery tokens, and FVector/FRotator/FQuat/FTransform pairs
// cover the bound families without extra engine fixtures.
// Expected observations: the passing leaf is silent; each failing leaf
// reports one diagnostic with its unique message and both sides of the
// relation.
// C++ oracle required: per-overload pass/fail, diagnostic text containing
// actual/expected values, and source locations.

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceEqualityAndOrderingAssertionsSuite : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void VerifyEqualityAndOrderingAssertions()
	{
		AssertEquals(7, 7);
		AssertNotEquals(7, 8);
		AssertEquals(int64(9), int64(9));
		AssertNotEquals(int64(9), int64(10));
		AssertEquals(float32(1.25), float32(1.25));
		AssertNotEquals(float32(1.25), float32(2.25));
		AssertEquals(float64(2.5), float64(2.5));
		AssertNotEquals(float64(2.5), float64(3.5));
		AssertEquals(true, true);
		AssertNotEquals(true, false);
		AssertEquals(n"Alpha", n"Alpha");
		AssertNotEquals(n"Alpha", n"Beta");
		AssertEquals("Alpha", "Alpha");
		AssertNotEquals("Alpha", "Beta");

		FText TextA = FText::FromString("Alpha");
		FText TextB = FText::FromString("Alpha");
		AssertEquals(TextA.ToString(), TextB.ToString());
		AssertNotEquals(
			FText::FromString("Alpha").ToString(),
			FText::FromString("Beta").ToString());

		AssertTrue(
			EObjectTypeQuery::WorldStatic == EObjectTypeQuery::WorldStatic,
			"TS-FW-ASSERTIONS-002 enum equality payload");
		AssertTrue(
			EObjectTypeQuery::WorldStatic != EObjectTypeQuery::WorldDynamic,
			"TS-FW-ASSERTIONS-002 enum inequality payload");

		const FVector VectorA(1.0, 2.0, 3.0);
		const FRotator RotatorA(1.0, 2.0, 3.0);
		const FQuat QuatA = FQuat::Identity;
		const FTransform TransformA(QuatA, VectorA, FVector::OneVector);
		AssertEquals(VectorA, FVector(1.0, 2.0, 3.0));
		AssertEquals(RotatorA, FRotator(1.0, 2.0, 3.0));
		AssertEquals(QuatA, FQuat::Identity);
		AssertEquals(TransformA, FTransform(QuatA, VectorA, FVector::OneVector));
		AssertNotEquals(VectorA, FVector::ZeroVector);
		AssertNotEquals(RotatorA, FRotator::ZeroRotator);
		AssertNotEquals(QuatA, FQuat(1.0, 0.0, 0.0, 0.0));
		AssertNotEquals(
			TransformA,
			FTransform(QuatA, FVector::ZeroVector, FVector::OneVector));

		AssertLessThan(1, 2);
		AssertLessThanOrEqual(2, 2);
		AssertGreaterThan(2, 1);
		AssertGreaterThanOrEqual(2, 2);
		AssertLessThan(int64(1), int64(2));
		AssertLessThan(float32(1.0), float32(2.0));
		AssertLessThan(float64(1.0), float64(2.0));
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailAssertEqualsInt()
	{
		AssertEquals(1, 2, "TS-FW-ASSERTIONS-002 AssertEquals int fail");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailAssertNotEqualsInt()
	{
		AssertNotEquals(4, 4, "TS-FW-ASSERTIONS-002 AssertNotEquals int fail");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailAssertEqualsFloat64()
	{
		AssertEquals(
			float64(1.0),
			float64(2.0),
			"TS-FW-ASSERTIONS-002 AssertEquals float64 fail");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailAssertEqualsString()
	{
		AssertEquals(
			"Alpha",
			"Beta",
			"TS-FW-ASSERTIONS-002 AssertEquals FString fail");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailAssertEqualsName()
	{
		AssertEquals(
			n"Alpha",
			n"Beta",
			"TS-FW-ASSERTIONS-002 AssertEquals FName fail");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailAssertEqualsText()
	{
		AssertEquals(
			FText::FromString("Alpha").ToString(),
			FText::FromString("Beta").ToString(),
			"TS-FW-ASSERTIONS-002 AssertEquals FText fail");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailAssertEqualsEnum()
	{
		AssertTrue(
			EObjectTypeQuery::WorldStatic == EObjectTypeQuery::WorldDynamic,
			"TS-FW-ASSERTIONS-002 enum equals fail");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailAssertEqualsVector()
	{
		AssertEquals(
			FVector(1.0, 0.0, 0.0),
			FVector::ZeroVector,
			"TS-FW-ASSERTIONS-002 AssertEquals FVector fail");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailAssertLessThan()
	{
		AssertLessThan(2, 1, "TS-FW-ASSERTIONS-002 AssertLessThan fail");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailAssertLessThanOrEqual()
	{
		AssertLessThanOrEqual(
			3,
			2,
			"TS-FW-ASSERTIONS-002 AssertLessThanOrEqual fail");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailAssertGreaterThan()
	{
		AssertGreaterThan(1, 2, "TS-FW-ASSERTIONS-002 AssertGreaterThan fail");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailAssertGreaterThanOrEqual()
	{
		AssertGreaterThanOrEqual(
			1,
			2,
			"TS-FW-ASSERTIONS-002 AssertGreaterThanOrEqual fail");
	}
}
