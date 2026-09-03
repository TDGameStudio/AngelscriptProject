/**
 * Math::Abs, Min, Max, and Clamp as Suite usage.
 *
 * @Theme TestFramework.Usage.Math
 * @Subject Math.Abs
 * @Harness SuiteUsage
 * @Tag TestFramework.Usage.Math.ScalarAbsMinMax
 * @Provenance TestSource/Bindings/FMath/Test_NamespaceAndGlobalFunctions_16.as
 * @Provenance TestSource/Bindings/FMath/Test_Queries_03.as
 * @Provenance TestSource/Bindings/FMath/Test_NamespaceAndGlobalFunctions_02.as
 */

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UScalarAbsMinMaxScriptTests : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void AbsOfSignedIntegers()
	{
		AssertEquals(3, Math::Abs(int32(3)));
		AssertEquals(3, Math::Abs(int32(-3)));
		AssertEquals(0, Math::Abs(int32(0)));
	}

	UFUNCTION(meta=(AngelscriptTest))
	void MinAndMaxOfPair()
	{
		AssertEquals(-1, Math::Min(int32(3), int32(-1)));
		AssertEquals(3, Math::Max(int32(3), int32(-1)));
		AssertEquals(4, Math::Min(int32(4), int32(4)));
		AssertEquals(5.0, Math::Max3(1.0, 5.0, 3.0));
	}

	UFUNCTION(meta=(AngelscriptTest))
	void ClampKeepsValueInsideRange()
	{
		AssertEquals(0, Math::Clamp(int32(-1), int32(0), int32(10)));
		AssertEquals(5, Math::Clamp(int32(5), int32(0), int32(10)));
		AssertEquals(10, Math::Clamp(int32(15), int32(0), int32(10)));
	}
}
