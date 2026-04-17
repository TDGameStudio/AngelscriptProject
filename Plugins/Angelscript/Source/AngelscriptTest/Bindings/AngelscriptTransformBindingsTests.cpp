#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"
#include "../Shared/AngelscriptTestEngineHelper.h"

#include "Math/Quat.h"
#include "Math/Transform.h"
#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTransformBindingsTest,
	"Angelscript.TestModule.Bindings.TransformDeterministicCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Bindings_AngelscriptTransformBindingsTests_Private
{
	FString FormatScriptFloatLiteral(const double Value)
	{
		FString Literal = FString::Printf(TEXT("%.9g"), Value);
		if (!Literal.Contains(TEXT(".")) && !Literal.Contains(TEXT("e")) && !Literal.Contains(TEXT("E")))
		{
			Literal += TEXT(".0");
		}

		return Literal;
	}

	FString FormatScriptVectorLiteral(const FVector& Value)
	{
		return FString::Printf(
			TEXT("FVector(%s, %s, %s)"),
			*FormatScriptFloatLiteral(Value.X),
			*FormatScriptFloatLiteral(Value.Y),
			*FormatScriptFloatLiteral(Value.Z));
	}

	FString FormatScriptRotatorLiteral(const FRotator& Value)
	{
		return FString::Printf(
			TEXT("FRotator(%s, %s, %s)"),
			*FormatScriptFloatLiteral(Value.Pitch),
			*FormatScriptFloatLiteral(Value.Yaw),
			*FormatScriptFloatLiteral(Value.Roll));
	}

	FString FormatScriptQuatLiteral(const FQuat& Value)
	{
		return FString::Printf(
			TEXT("FQuat(%s, %s, %s, %s)"),
			*FormatScriptFloatLiteral(Value.X),
			*FormatScriptFloatLiteral(Value.Y),
			*FormatScriptFloatLiteral(Value.Z),
			*FormatScriptFloatLiteral(Value.W));
	}

	FString FormatScriptTransformLiteral(const FTransform& Value)
	{
		return FString::Printf(
			TEXT("FTransform(%s, %s, %s)"),
			*FormatScriptQuatLiteral(Value.GetRotation()),
			*FormatScriptVectorLiteral(Value.GetTranslation()),
			*FormatScriptVectorLiteral(Value.GetScale3D()));
	}

	template <typename TValue>
	bool ReadReturnValue(FAutomationTestBase& Test, asIScriptContext& Context, TValue& OutValue)
	{
		void* ReturnValueAddress = Context.GetAddressOfReturnValue();
		if (!Test.TestNotNull(TEXT("Transform bindings test should expose the return value storage"), ReturnValueAddress))
		{
			return false;
		}

		OutValue = *static_cast<TValue*>(ReturnValueAddress);
		return true;
	}

	template <typename TValue>
	bool ExecuteValueFunction(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		asIScriptFunction& Function,
		TValue& OutValue)
	{
		asIScriptContext* Context = Engine.CreateContext();
		if (!Test.TestNotNull(TEXT("Transform bindings test should create an execution context"), Context))
		{
			return false;
		}

		const int PrepareResult = Context->Prepare(&Function);
		if (!Test.TestEqual(TEXT("Transform bindings test should prepare the script function"), PrepareResult, asSUCCESS))
		{
			Context->Release();
			return false;
		}

		const int ExecuteResult = Context->Execute();
		if (!Test.TestEqual(TEXT("Transform bindings test should execute the script function"), ExecuteResult, asEXECUTION_FINISHED))
		{
			if (ExecuteResult == asEXECUTION_EXCEPTION && Context->GetExceptionString() != nullptr)
			{
				Test.AddError(FString::Printf(
					TEXT("Transform bindings test saw a script exception: %s"),
					UTF8_TO_TCHAR(Context->GetExceptionString())));
			}
			Context->Release();
			return false;
		}

		const bool bReadReturnValue = ReadReturnValue(Test, *Context, OutValue);
		Context->Release();
		return bReadReturnValue;
	}

	bool QuatMatches(const FQuat& Actual, const FQuat& Expected, double ToleranceDegrees = 0.05)
	{
		FQuat ActualQuat = Actual;
		FQuat ExpectedQuat = Expected;
		ActualQuat.Normalize();
		ExpectedQuat.Normalize();
		if ((ActualQuat | ExpectedQuat) < 0.0)
		{
			ExpectedQuat = FQuat(-ExpectedQuat.X, -ExpectedQuat.Y, -ExpectedQuat.Z, -ExpectedQuat.W);
		}

		return FMath::RadiansToDegrees(ActualQuat.AngularDistance(ExpectedQuat)) <= ToleranceDegrees;
	}

	bool VerifyVector(
		FAutomationTestBase& Test,
		const TCHAR* What,
		const FVector& Actual,
		const FVector& Expected,
		double Tolerance = KINDA_SMALL_NUMBER)
	{
		if (!Actual.Equals(Expected, Tolerance))
		{
			Test.AddInfo(FString::Printf(
				TEXT("%s actual=%s expected=%s tolerance=%.6f"),
				What,
				*Actual.ToCompactString(),
				*Expected.ToCompactString(),
				Tolerance));
		}

		return Test.TestTrue(What, Actual.Equals(Expected, Tolerance));
	}

	bool VerifyTransform(
		FAutomationTestBase& Test,
		const TCHAR* What,
		const FTransform& Actual,
		const FTransform& Expected,
		double Tolerance = 0.001)
	{
		const bool bRotationMatches = QuatMatches(Actual.GetRotation(), Expected.GetRotation(), Tolerance);
		const bool bTranslationMatches = Actual.GetTranslation().Equals(Expected.GetTranslation(), Tolerance);
		const bool bScaleMatches = Actual.GetScale3D().Equals(Expected.GetScale3D(), Tolerance);
		if (!(bRotationMatches && bTranslationMatches && bScaleMatches))
		{
			Test.AddInfo(FString::Printf(
				TEXT("%s actual rotation=%s expected rotation=%s actual translation=%s expected translation=%s actual scale=%s expected scale=%s"),
				What,
				*Actual.GetRotation().Rotator().ToCompactString(),
				*Expected.GetRotation().Rotator().ToCompactString(),
				*Actual.GetTranslation().ToCompactString(),
				*Expected.GetTranslation().ToCompactString(),
				*Actual.GetScale3D().ToCompactString(),
				*Expected.GetScale3D().ToCompactString()));
		}

		return Test.TestTrue(What, bRotationMatches && bTranslationMatches && bScaleMatches);
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptTransformBindingsTests_Private;

bool FAngelscriptTransformBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	constexpr double Tolerance = 0.001;

	const FRotator BaselineRotator(0.0, 90.0, 0.0);
	const FVector BaselineTranslation(10.0, 20.0, 30.0);
	const FVector BaselineScale(2.0, 3.0, 4.0);
	const FTransform Baseline(BaselineRotator, BaselineTranslation, BaselineScale);

	const FRotator OtherRotator(15.0, -45.0, 5.0);
	const FVector OtherTranslation(-5.0, 6.0, 7.0);
	const FVector OtherScale(1.5, 0.5, 2.0);
	const FTransform Other(OtherRotator, OtherTranslation, OtherScale);

	const FVector InputPosition(1.0, 0.0, 0.0);
	const FVector UpdatedTranslation(-11.0, 12.0, 13.0);
	const FVector UpdatedScale(8.0, 9.0, 10.0);

	const FVector ExpectedTransformPosition = Baseline.TransformPosition(InputPosition);
	const FVector ExpectedTransformPositionNoScale = Baseline.TransformPositionNoScale(InputPosition);
	const FVector ExpectedInverseTransformPosition = Baseline.InverseTransformPosition(ExpectedTransformPosition);
	const FTransform ExpectedRelative = Baseline.GetRelativeTransform(Other);

	FTransform ExpectedUpdated = Baseline;
	ExpectedUpdated.SetTranslation(UpdatedTranslation);
	ExpectedUpdated.SetScale3D(UpdatedScale);

	bPassed &= TestTrue(
		TEXT("Native transform baseline should apply scale before rotation and translation"),
		!ExpectedTransformPosition.Equals(ExpectedTransformPositionNoScale, 0.0));
	bPassed &= TestTrue(
		TEXT("Native inverse transform baseline should recover the original local input"),
		ExpectedInverseTransformPosition.Equals(InputPosition, Tolerance));
	bPassed &= TestTrue(
		TEXT("Native relative transform baseline should remain distinguishable from identity"),
		!ExpectedRelative.Equals(FTransform::Identity, Tolerance));
	bPassed &= TestTrue(
		TEXT("Native setter baseline should produce a transform different from the original baseline"),
		!ExpectedUpdated.Equals(Baseline, 0.0));
	if (!bPassed)
	{
		return false;
	}

	FString Script = TEXT(R"AS(
FTransform MakeBaseline()
{
	return FTransform($BASELINE_ROTATOR$, $BASELINE_TRANSLATION$, $BASELINE_SCALE$);
}

FTransform MakeOther()
{
	return FTransform($OTHER_ROTATOR$, $OTHER_TRANSLATION$, $OTHER_SCALE$);
}

FVector GetTransformedPosition()
{
	return MakeBaseline().TransformPosition($INPUT_POSITION$);
}

FVector GetTransformedPositionNoScale()
{
	return MakeBaseline().TransformPositionNoScale($INPUT_POSITION$);
}

FVector GetInverseTransformedPosition()
{
	return MakeBaseline().InverseTransformPosition($EXPECTED_TRANSFORM_POSITION$);
}

FTransform GetRelativeTransformResult()
{
	return MakeBaseline().GetRelativeTransform(MakeOther());
}

FTransform GetUpdatedTransformResult()
{
	FTransform Updated = MakeBaseline();
	Updated.SetTranslation($UPDATED_TRANSLATION$);
	Updated.SetScale3D($UPDATED_SCALE$);
	return Updated;
}

bool RelativeMatchesExpected()
{
	return GetRelativeTransformResult().Equals($EXPECTED_RELATIVE$, $TOLERANCE$);
}

bool UpdatedMatchesExpected()
{
	return GetUpdatedTransformResult().Equals($EXPECTED_UPDATED$, $TOLERANCE$);
}

bool UpdatedDiffersFromBaseline()
{
	return !GetUpdatedTransformResult().Equals(MakeBaseline(), $TOLERANCE$);
}
)AS");

	Script.ReplaceInline(TEXT("$BASELINE_ROTATOR$"), *FormatScriptRotatorLiteral(BaselineRotator));
	Script.ReplaceInline(TEXT("$BASELINE_TRANSLATION$"), *FormatScriptVectorLiteral(BaselineTranslation));
	Script.ReplaceInline(TEXT("$BASELINE_SCALE$"), *FormatScriptVectorLiteral(BaselineScale));
	Script.ReplaceInline(TEXT("$OTHER_ROTATOR$"), *FormatScriptRotatorLiteral(OtherRotator));
	Script.ReplaceInline(TEXT("$OTHER_TRANSLATION$"), *FormatScriptVectorLiteral(OtherTranslation));
	Script.ReplaceInline(TEXT("$OTHER_SCALE$"), *FormatScriptVectorLiteral(OtherScale));
	Script.ReplaceInline(TEXT("$INPUT_POSITION$"), *FormatScriptVectorLiteral(InputPosition));
	Script.ReplaceInline(TEXT("$EXPECTED_TRANSFORM_POSITION$"), *FormatScriptVectorLiteral(ExpectedTransformPosition));
	Script.ReplaceInline(TEXT("$UPDATED_TRANSLATION$"), *FormatScriptVectorLiteral(UpdatedTranslation));
	Script.ReplaceInline(TEXT("$UPDATED_SCALE$"), *FormatScriptVectorLiteral(UpdatedScale));
	Script.ReplaceInline(TEXT("$EXPECTED_RELATIVE$"), *FormatScriptTransformLiteral(ExpectedRelative));
	Script.ReplaceInline(TEXT("$EXPECTED_UPDATED$"), *FormatScriptTransformLiteral(ExpectedUpdated));
	Script.ReplaceInline(TEXT("$TOLERANCE$"), *FormatScriptFloatLiteral(Tolerance));

	asIScriptModule* Module = BuildModule(*this, Engine, "ASTransformDeterministicCompat", Script);
	if (Module == nullptr)
	{
		return false;
	}

	FVector ScriptTransformPosition = FVector::ZeroVector;
	FVector ScriptTransformPositionNoScale = FVector::ZeroVector;
	FVector ScriptInverseTransformPosition = FVector::ZeroVector;
	FTransform ScriptRelative = FTransform::Identity;
	FTransform ScriptUpdated = FTransform::Identity;
	bool bRelativeMatchesExpected = false;
	bool bUpdatedMatchesExpected = false;
	bool bUpdatedDiffersFromBaseline = false;

	asIScriptFunction* TransformPositionFunction = GetFunctionByDecl(*this, *Module, TEXT("FVector GetTransformedPosition()"));
	asIScriptFunction* TransformPositionNoScaleFunction = GetFunctionByDecl(*this, *Module, TEXT("FVector GetTransformedPositionNoScale()"));
	asIScriptFunction* InverseTransformPositionFunction = GetFunctionByDecl(*this, *Module, TEXT("FVector GetInverseTransformedPosition()"));
	asIScriptFunction* RelativeTransformFunction = GetFunctionByDecl(*this, *Module, TEXT("FTransform GetRelativeTransformResult()"));
	asIScriptFunction* UpdatedTransformFunction = GetFunctionByDecl(*this, *Module, TEXT("FTransform GetUpdatedTransformResult()"));
	asIScriptFunction* RelativeMatchesExpectedFunction = GetFunctionByDecl(*this, *Module, TEXT("bool RelativeMatchesExpected()"));
	asIScriptFunction* UpdatedMatchesExpectedFunction = GetFunctionByDecl(*this, *Module, TEXT("bool UpdatedMatchesExpected()"));
	asIScriptFunction* UpdatedDiffersFromBaselineFunction = GetFunctionByDecl(*this, *Module, TEXT("bool UpdatedDiffersFromBaseline()"));
	if (TransformPositionFunction == nullptr
		|| TransformPositionNoScaleFunction == nullptr
		|| InverseTransformPositionFunction == nullptr
		|| RelativeTransformFunction == nullptr
		|| UpdatedTransformFunction == nullptr
		|| RelativeMatchesExpectedFunction == nullptr
		|| UpdatedMatchesExpectedFunction == nullptr
		|| UpdatedDiffersFromBaselineFunction == nullptr)
	{
		return false;
	}

	const bool bExecutedAll =
		ExecuteValueFunction(*this, Engine, *TransformPositionFunction, ScriptTransformPosition) &&
		ExecuteValueFunction(*this, Engine, *TransformPositionNoScaleFunction, ScriptTransformPositionNoScale) &&
		ExecuteValueFunction(*this, Engine, *InverseTransformPositionFunction, ScriptInverseTransformPosition) &&
		ExecuteValueFunction(*this, Engine, *RelativeTransformFunction, ScriptRelative) &&
		ExecuteValueFunction(*this, Engine, *UpdatedTransformFunction, ScriptUpdated) &&
		ExecuteValueFunction(*this, Engine, *RelativeMatchesExpectedFunction, bRelativeMatchesExpected) &&
		ExecuteValueFunction(*this, Engine, *UpdatedMatchesExpectedFunction, bUpdatedMatchesExpected) &&
		ExecuteValueFunction(*this, Engine, *UpdatedDiffersFromBaselineFunction, bUpdatedDiffersFromBaseline);
	if (!bExecutedAll)
	{
		return false;
	}

	bPassed &= VerifyVector(
		*this,
		TEXT("FTransform::TransformPosition should match the native baseline exactly for the deterministic sample"),
		ScriptTransformPosition,
		ExpectedTransformPosition,
		Tolerance);
	bPassed &= VerifyVector(
		*this,
		TEXT("FTransform::TransformPositionNoScale should match the native baseline exactly for the deterministic sample"),
		ScriptTransformPositionNoScale,
		ExpectedTransformPositionNoScale,
		Tolerance);
	bPassed &= VerifyVector(
		*this,
		TEXT("FTransform::InverseTransformPosition should recover the original local point from the transformed sample"),
		ScriptInverseTransformPosition,
		ExpectedInverseTransformPosition,
		Tolerance);
	bPassed &= VerifyTransform(
		*this,
		TEXT("FTransform::GetRelativeTransform should match the native baseline transform result"),
		ScriptRelative,
		ExpectedRelative,
		Tolerance);
	bPassed &= VerifyTransform(
		*this,
		TEXT("FTransform::SetTranslation and SetScale3D should preserve the native updated transform result"),
		ScriptUpdated,
		ExpectedUpdated,
		Tolerance);
	bPassed &= VerifyVector(
		*this,
		TEXT("FTransform::GetTranslation should reflect the value set through SetTranslation"),
		ScriptUpdated.GetTranslation(),
		UpdatedTranslation,
		0.0);
	bPassed &= VerifyVector(
		*this,
		TEXT("FTransform::GetScale3D should reflect the value set through SetScale3D"),
		ScriptUpdated.GetScale3D(),
		UpdatedScale,
		0.0);
	bPassed &= TestTrue(
		TEXT("FTransform::Equals should confirm that GetRelativeTransform matches the native expected transform"),
		bRelativeMatchesExpected);
	bPassed &= TestTrue(
		TEXT("FTransform::Equals should confirm that the setter-mutated transform matches the native updated baseline"),
		bUpdatedMatchesExpected);
	bPassed &= TestTrue(
		TEXT("FTransform::Equals should report that the setter-mutated transform is no longer equal to the original baseline"),
		bUpdatedDiffersFromBaseline);

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
