#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"
#include "../Shared/AngelscriptTestEngineHelper.h"

#include "Math/Quat.h"
#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptQuatBindingsTest,
	"Angelscript.TestModule.Bindings.QuatRotationCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Bindings_AngelscriptQuatBindingsTests_Private
{
	bool ReadReturnValue(FAutomationTestBase&, asIScriptContext& Context, float& OutValue) { OutValue = Context.GetReturnFloat(); return true; }
	bool ReadReturnValue(FAutomationTestBase&, asIScriptContext& Context, double& OutValue) { OutValue = Context.GetReturnDouble(); return true; }

	template <typename TValue>
	bool ReadReturnValue(FAutomationTestBase& Test, asIScriptContext& Context, TValue& OutValue)
	{
		void* ReturnValueAddress = Context.GetAddressOfReturnValue();
		return Test.TestNotNull(TEXT("Quat bindings test should expose return value storage"), ReturnValueAddress)
			&& (OutValue = *static_cast<TValue*>(ReturnValueAddress), true);
	}

	template <typename TValue>
	bool ExecuteValueFunction(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		asIScriptFunction& Function,
		TValue& OutValue)
	{
		asIScriptContext* Context = Engine.CreateContext();
		if (!Test.TestNotNull(TEXT("Quat bindings test should create an execution context"), Context))
		{
			return false;
		}

		const int PrepareResult = Context->Prepare(&Function);
		if (!Test.TestEqual(TEXT("Quat bindings test should prepare the script function"), PrepareResult, asSUCCESS))
		{
			Context->Release();
			return false;
		}

		const int ExecuteResult = Context->Execute();
		if (!Test.TestEqual(TEXT("Quat bindings test should execute the script function"), ExecuteResult, asEXECUTION_FINISHED))
		{
			if (ExecuteResult == asEXECUTION_EXCEPTION && Context->GetExceptionString() != nullptr)
			{
				Test.AddError(FString::Printf(
					TEXT("Quat bindings test saw a script exception: %s"),
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

	bool RotatorMatches(const FRotator& Actual, const FRotator& Expected, double ToleranceDegrees = 0.05)
	{
		return QuatMatches(FQuat(Actual), FQuat(Expected), ToleranceDegrees);
	}

	bool VerifyQuat(
		FAutomationTestBase& Test,
		const TCHAR* What,
		const FQuat& Actual,
		const FQuat& Expected,
		double ToleranceDegrees = 0.05)
	{
		return Test.TestTrue(What, QuatMatches(Actual, Expected, ToleranceDegrees));
	}

	bool VerifyVector(
		FAutomationTestBase& Test,
		const TCHAR* What,
		const FVector& Actual,
		const FVector& Expected,
		double Tolerance = KINDA_SMALL_NUMBER)
	{
		return Test.TestTrue(What, Actual.Equals(Expected, Tolerance));
	}

	bool VerifyRotator(
		FAutomationTestBase& Test,
		const TCHAR* What,
		const FRotator& Actual,
		const FRotator& Expected,
		double ToleranceDegrees = 0.05)
	{
		return Test.TestTrue(What, RotatorMatches(Actual, Expected, ToleranceDegrees));
	}

	bool VerifyNumeric(
		FAutomationTestBase& Test,
		const TCHAR* What,
		double Actual,
		double Expected,
		double Tolerance)
	{
		return Test.TestTrue(What, FMath::Abs(Actual - Expected) <= Tolerance);
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptQuatBindingsTests_Private;

bool FAngelscriptQuatBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASQuatRotationCompat",
		TEXT(R"AS(
FQuat GetIdentityQuat()
{
	return FQuat::Identity;
}

FQuat GetNormalizedQuarterTurn()
{
	FQuat Value = FQuat(FVector::UpVector, 1.5707963267948966) * 3.0;
	Value.Normalize();
	return Value;
}

FVector GetRotatedForward()
{
	const FQuat QuarterTurn = FQuat(FVector::UpVector, 1.5707963267948966);
	return QuarterTurn.RotateVector(FVector::ForwardVector);
}

FVector GetUnrotatedForward()
{
	const FQuat QuarterTurn = FQuat(FVector::UpVector, 1.5707963267948966);
	return QuarterTurn.UnrotateVector(QuarterTurn.RotateVector(FVector::ForwardVector));
}

FQuat GetInverseQuarterTurn()
{
	return FQuat(FVector::UpVector, 1.5707963267948966).Inverse();
}

FVector GetQuarterTurnAxis()
{
	FVector Axis;
	float64 Angle = 0.0;
	FQuat(FVector::UpVector, 1.5707963267948966).ToAxisAndAngle(Axis, Angle);
	return Axis;
}

float64 GetQuarterTurnAngle()
{
	FVector Axis;
	float64 Angle = 0.0;
	FQuat(FVector::UpVector, 1.5707963267948966).ToAxisAndAngle(Axis, Angle);
	return Angle;
}

FRotator GetQuarterTurnRotator()
{
	return FQuat(FVector::UpVector, 1.5707963267948966).Rotator();
}

FRotator GetMakeFromEulerRotator()
{
	return FQuat::MakeFromEuler(FVector(10.0, 20.0, 30.0)).Rotator();
}

FQuat GetHalfSlerp()
{
	return FQuat::Slerp(FQuat::Identity, FQuat(FVector::UpVector, 1.5707963267948966), 0.5);
}
)AS"));
	if (Module == nullptr)
	{
		return false;
	}

	const FQuat QuarterTurn(FVector::UpVector, UE_HALF_PI);
	const FQuat ExpectedIdentity = FQuat::Identity;
	FQuat ExpectedNormalizedQuarterTurn = QuarterTurn * 3.0;
	ExpectedNormalizedQuarterTurn.Normalize();
	const FVector ExpectedRotatedForward = QuarterTurn.RotateVector(FVector::ForwardVector);
	const FVector ExpectedUnrotatedForward = QuarterTurn.UnrotateVector(ExpectedRotatedForward);
	const FQuat ExpectedInverseQuarterTurn = QuarterTurn.Inverse();
	FVector ExpectedAxis = FVector::ZeroVector;
	double ExpectedAngle = 0.0;
	QuarterTurn.ToAxisAndAngle(ExpectedAxis, ExpectedAngle);
	const FRotator ExpectedQuarterTurnRotator = QuarterTurn.Rotator();
	const FRotator ExpectedEulerRotator = FQuat::MakeFromEuler(FVector(10.0, 20.0, 30.0)).Rotator();
	FQuat ExpectedHalfSlerp = FQuat::Slerp(FQuat::Identity, QuarterTurn, 0.5);
	ExpectedHalfSlerp.Normalize();

	FQuat ScriptIdentity;
	FQuat ScriptNormalizedQuarterTurn;
	FVector ScriptRotatedForward;
	FVector ScriptUnrotatedForward;
	FQuat ScriptInverseQuarterTurn;
	FVector ScriptAxis;
	double ScriptAngle = 0.0;
	FRotator ScriptQuarterTurnRotator;
	FRotator ScriptEulerRotator;
	FQuat ScriptHalfSlerp;

	asIScriptFunction* IdentityFunction = GetFunctionByDecl(*this, *Module, TEXT("FQuat GetIdentityQuat()"));
	asIScriptFunction* NormalizedQuarterTurnFunction = GetFunctionByDecl(*this, *Module, TEXT("FQuat GetNormalizedQuarterTurn()"));
	asIScriptFunction* RotatedForwardFunction = GetFunctionByDecl(*this, *Module, TEXT("FVector GetRotatedForward()"));
	asIScriptFunction* UnrotatedForwardFunction = GetFunctionByDecl(*this, *Module, TEXT("FVector GetUnrotatedForward()"));
	asIScriptFunction* InverseQuarterTurnFunction = GetFunctionByDecl(*this, *Module, TEXT("FQuat GetInverseQuarterTurn()"));
	asIScriptFunction* QuarterTurnAxisFunction = GetFunctionByDecl(*this, *Module, TEXT("FVector GetQuarterTurnAxis()"));
	asIScriptFunction* QuarterTurnAngleFunction = GetFunctionByDecl(*this, *Module, TEXT("float64 GetQuarterTurnAngle()"));
	asIScriptFunction* QuarterTurnRotatorFunction = GetFunctionByDecl(*this, *Module, TEXT("FRotator GetQuarterTurnRotator()"));
	asIScriptFunction* EulerRotatorFunction = GetFunctionByDecl(*this, *Module, TEXT("FRotator GetMakeFromEulerRotator()"));
	asIScriptFunction* HalfSlerpFunction = GetFunctionByDecl(*this, *Module, TEXT("FQuat GetHalfSlerp()"));
	if (IdentityFunction == nullptr
		|| NormalizedQuarterTurnFunction == nullptr
		|| RotatedForwardFunction == nullptr
		|| UnrotatedForwardFunction == nullptr
		|| InverseQuarterTurnFunction == nullptr
		|| QuarterTurnAxisFunction == nullptr
		|| QuarterTurnAngleFunction == nullptr
		|| QuarterTurnRotatorFunction == nullptr
		|| EulerRotatorFunction == nullptr
		|| HalfSlerpFunction == nullptr)
	{
		return false;
	}

	const bool bExecutedAll =
		ExecuteValueFunction(*this, Engine, *IdentityFunction, ScriptIdentity) &&
		ExecuteValueFunction(*this, Engine, *NormalizedQuarterTurnFunction, ScriptNormalizedQuarterTurn) &&
		ExecuteValueFunction(*this, Engine, *RotatedForwardFunction, ScriptRotatedForward) &&
		ExecuteValueFunction(*this, Engine, *UnrotatedForwardFunction, ScriptUnrotatedForward) &&
		ExecuteValueFunction(*this, Engine, *InverseQuarterTurnFunction, ScriptInverseQuarterTurn) &&
		ExecuteValueFunction(*this, Engine, *QuarterTurnAxisFunction, ScriptAxis) &&
		ExecuteValueFunction(*this, Engine, *QuarterTurnAngleFunction, ScriptAngle) &&
		ExecuteValueFunction(*this, Engine, *QuarterTurnRotatorFunction, ScriptQuarterTurnRotator) &&
		ExecuteValueFunction(*this, Engine, *EulerRotatorFunction, ScriptEulerRotator) &&
		ExecuteValueFunction(*this, Engine, *HalfSlerpFunction, ScriptHalfSlerp);
	if (!bExecutedAll)
	{
		return false;
	}

	const bool bIdentityMatches = VerifyQuat(
		*this,
		TEXT("FQuat::Identity should round-trip through the static binding"),
		ScriptIdentity,
		ExpectedIdentity);
	const bool bIdentityReportsIdentity = TestTrue(
		TEXT("FQuat::Identity should still report IsIdentity after script round-trip"),
		ScriptIdentity.IsIdentity());
	const bool bNormalizeMatches = VerifyQuat(
		*this,
		TEXT("FQuat::Normalize should recover the original quarter-turn rotation after scalar inflation"),
		ScriptNormalizedQuarterTurn,
		QuarterTurn);
	const bool bNormalizeProducesUnitQuat = TestTrue(
		TEXT("FQuat::Normalize should leave the quaternion in a normalized state"),
		ScriptNormalizedQuarterTurn.IsNormalized());
	const bool bRotateVectorMatches = VerifyVector(
		*this,
		TEXT("FQuat::RotateVector should match the native quarter-turn rotation"),
		ScriptRotatedForward,
		ExpectedRotatedForward);
	const bool bUnrotateVectorMatches = VerifyVector(
		*this,
		TEXT("FQuat::UnrotateVector should recover the original forward vector"),
		ScriptUnrotatedForward,
		ExpectedUnrotatedForward);
	const bool bInverseMatches = VerifyQuat(
		*this,
		TEXT("FQuat::Inverse should match the native inverse quaternion"),
		ScriptInverseQuarterTurn,
		ExpectedInverseQuarterTurn);
	const bool bAxisMatches = VerifyVector(
		*this,
		TEXT("FQuat::ToAxisAndAngle should report the native rotation axis"),
		ScriptAxis,
		ExpectedAxis,
		0.001);
	const bool bAngleMatches = VerifyNumeric(
		*this,
		TEXT("FQuat::ToAxisAndAngle should report the native quarter-turn angle"),
		ScriptAngle,
		ExpectedAngle,
		0.001);
	const bool bQuarterTurnRotatorMatches = VerifyRotator(
		*this,
		TEXT("FQuat::Rotator should match the native axis-angle conversion"),
		ScriptQuarterTurnRotator,
		ExpectedQuarterTurnRotator);
	const bool bMakeFromEulerMatches = VerifyRotator(
		*this,
		TEXT("FQuat::MakeFromEuler(...).Rotator() should match the native Euler conversion"),
		ScriptEulerRotator,
		ExpectedEulerRotator);
	const bool bHalfSlerpMatches = VerifyQuat(
		*this,
		TEXT("FQuat::Slerp should match the native half-way interpolation result"),
		ScriptHalfSlerp,
		ExpectedHalfSlerp);
	const bool bHalfSlerpIsNormalized = TestTrue(
		TEXT("FQuat::Slerp should return a normalized quaternion for this deterministic case"),
		ScriptHalfSlerp.IsNormalized());

	bPassed =
		bIdentityMatches &&
		bIdentityReportsIdentity &&
		bNormalizeMatches &&
		bNormalizeProducesUnitQuat &&
		bRotateVectorMatches &&
		bUnrotateVectorMatches &&
		bInverseMatches &&
		bAxisMatches &&
		bAngleMatches &&
		bQuarterTurnRotatorMatches &&
		bMakeFromEulerMatches &&
		bHalfSlerpMatches &&
		bHalfSlerpIsNormalized;

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
