/**
 * @version v1
 * @summary TestFramework Assertions Test_NearValueAssertions
 * @topic TestFramework
 */
/**
 * @version root
 * @summary TestFramework Assertions Test_NearValueAssertions
 * @topic Baseline
 */
// Framework contract: AssertNear covers scalar float32/float64 and
// FVector/FRotator/FQuat/FTransform. Within-tolerance and boundary-equal
// cases are silent; outside-tolerance cases emit one diagnostic each.
// Payload: exact copies, a 0.00001 delta inside 0.0001, a boundary-equal
// 0.01/0.01 pair, and a 1.0 delta outside 0.0001 are enough for every
// family.
// Expected observations: the passing leaf is silent; each failing family
// reports one precise diagnostic with its unique message.
// C++ oracle required: per-family pass/fail, tolerance text, and source
// locations.

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceNearValueAssertionsSuite : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void VerifyNearValueAssertions()
	{
		const FVector VectorA(1.0, 2.0, 3.0);
		const FRotator RotatorA(1.0, 2.0, 3.0);
		const FQuat QuatA = FQuat::Identity;
		const FTransform TransformA(QuatA, VectorA, FVector::OneVector);

		AssertNear(float32(1.0), float32(1.0));
		AssertNear(float64(1.0), float64(1.0));
		AssertNear(float32(1.0), float32(1.00001));
		AssertNear(float64(1.0), float64(1.00001));
		AssertNear(float32(1.0), float32(1.01), float32(0.01));
		AssertNear(float64(1.0), float64(1.01), float64(0.01));
		AssertNear(VectorA, FVector(1.00001, 2.0, 3.0));
		AssertNear(RotatorA, FRotator(1.00001, 2.0, 3.0));
		AssertNear(QuatA, QuatA);
		AssertNear(TransformA, TransformA);
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailAssertNearFloat32()
	{
		AssertNear(
			float32(1.0),
			float32(2.0),
			float32(0.0001),
			"TS-FW-ASSERTIONS-003 AssertNear float32 fail");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailAssertNearFloat64()
	{
		AssertNear(
			float64(1.0),
			float64(2.0),
			float64(0.0001),
			"TS-FW-ASSERTIONS-003 AssertNear float64 fail");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailAssertNearVector()
	{
		AssertNear(
			FVector(1.0, 2.0, 3.0),
			FVector::ZeroVector,
			0.0001,
			"TS-FW-ASSERTIONS-003 AssertNear FVector fail");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailAssertNearRotator()
	{
		AssertNear(
			FRotator(1.0, 2.0, 3.0),
			FRotator::ZeroRotator,
			0.0001,
			"TS-FW-ASSERTIONS-003 AssertNear FRotator fail");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailAssertNearQuat()
	{
		AssertNear(
			FQuat::Identity,
			FQuat(1.0, 0.0, 0.0, 0.0),
			0.0001,
			"TS-FW-ASSERTIONS-003 AssertNear FQuat fail");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailAssertNearTransform()
	{
		AssertNear(
			FTransform(FQuat::Identity, FVector(1.0, 2.0, 3.0), FVector::OneVector),
			FTransform(FQuat::Identity, FVector::ZeroVector, FVector::OneVector),
			0.0001,
			"TS-FW-ASSERTIONS-003 AssertNear FTransform fail");
	}
}
/** @end */
