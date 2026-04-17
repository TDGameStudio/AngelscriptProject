#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"
#include "../Shared/AngelscriptTestEngineHelper.h"

#include "Math/Quat.h"
#include "Math/RotationMatrix.h"
#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptMathOrientationFactoriesAndTransformMutatorsTest,
	"Angelscript.TestModule.FunctionLibraries.MathOrientationFactoriesAndTransformMutators",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Bindings_AngelscriptMathOrientationFunctionLibraryTests_Private
{
	template <typename TValue>
	bool ExecuteValueFunction(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		asIScriptFunction& Function,
		TValue& OutValue)
	{
		asIScriptContext* Context = Engine.CreateContext();
		if (!Test.TestNotNull(TEXT("Math orientation test should create an execution context"), Context))
		{
			return false;
		}

		const int PrepareResult = Context->Prepare(&Function);
		if (!Test.TestEqual(TEXT("Math orientation test should prepare the script function"), PrepareResult, asSUCCESS))
		{
			Context->Release();
			return false;
		}

		const int ExecuteResult = Context->Execute();
		if (!Test.TestEqual(TEXT("Math orientation test should execute the script function"), ExecuteResult, asEXECUTION_FINISHED))
		{
			if (ExecuteResult == asEXECUTION_EXCEPTION && Context->GetExceptionString() != nullptr)
			{
				Test.AddError(FString::Printf(
					TEXT("Math orientation test saw a script exception: %s"),
					UTF8_TO_TCHAR(Context->GetExceptionString())));
			}
			Context->Release();
			return false;
		}

		void* ReturnValueAddress = Context->GetAddressOfReturnValue();
		if (!Test.TestNotNull(TEXT("Math orientation test should expose the return value storage"), ReturnValueAddress))
		{
			Context->Release();
			return false;
		}

		OutValue = *static_cast<TValue*>(ReturnValueAddress);
		Context->Release();
		return true;
	}

	bool RotatorMatches(const FRotator& Actual, const FRotator& Expected, double ToleranceDegrees = 0.05)
	{
		FQuat ActualQuat(Actual);
		FQuat ExpectedQuat(Expected);
		ActualQuat.Normalize();
		ExpectedQuat.Normalize();
		return FMath::RadiansToDegrees(ActualQuat.AngularDistance(ExpectedQuat)) <= ToleranceDegrees;
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

	bool VerifyTransform(
		FAutomationTestBase& Test,
		const TCHAR* What,
		const FTransform& Actual,
		const FTransform& Expected,
		double Tolerance = 0.01)
	{
		const bool bRotationMatches = RotatorMatches(Actual.Rotator(), Expected.Rotator(), Tolerance);
		const bool bTranslationMatches = Actual.GetLocation().Equals(Expected.GetLocation(), Tolerance);
		const bool bScaleMatches = Actual.GetScale3D().Equals(Expected.GetScale3D(), Tolerance);
		if (!(bRotationMatches && bTranslationMatches && bScaleMatches))
		{
			Test.AddInfo(FString::Printf(
				TEXT("%s actual rotation=%s expected rotation=%s actual translation=%s expected translation=%s actual scale=%s expected scale=%s"),
				What,
				*Actual.Rotator().ToCompactString(),
				*Expected.Rotator().ToCompactString(),
				*Actual.GetLocation().ToCompactString(),
				*Expected.GetLocation().ToCompactString(),
				*Actual.GetScale3D().ToCompactString(),
				*Expected.GetScale3D().ToCompactString()));
		}
		return Test.TestTrue(What, bRotationMatches && bTranslationMatches && bScaleMatches);
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptMathOrientationFunctionLibraryTests_Private;

bool FAngelscriptMathOrientationFactoriesAndTransformMutatorsTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASMathOrientationFactoriesAndTransformMutators",
		TEXT(R"(
FRotator GetAxesRotator()
{
	return FRotator::MakeFromAxes(FVector(1.0f, 0.0f, 0.0f), FVector(0.0f, 1.0f, 0.0f), FVector(0.0f, 0.0f, 1.0f));
}

FVector GetAxesForward()
{
	return FRotator::GetForwardVector(GetAxesRotator());
}

FVector GetAxesRight()
{
	return FRotator::GetRightVector(GetAxesRotator());
}

FVector GetAxesUp()
{
	return FRotator::GetUpVector(GetAxesRotator());
}

FRotator GetComposedRotator()
{
	const FRotator A = FRotator(0.0f, 90.0f, 0.0f);
	const FRotator B = FRotator(45.0f, 0.0f, 0.0f);
	return FRotator::Compose(A, B);
}

FQuat GetQuatFromX()
{
	return FQuat::MakeFromX(FVector(1.0f, 1.0f, 0.0f));
}

FQuat GetQuatFromY()
{
	return FQuat::MakeFromY(FVector(-1.0f, 1.0f, 0.0f));
}

FQuat GetQuatFromZ()
{
	return FQuat::MakeFromZ(FVector(0.0f, 0.0f, 1.0f));
}

FQuat GetQuatFromXY()
{
	return FQuat::MakeFromXY(FVector(1.0f, 1.0f, 0.0f), FVector(-1.0f, 1.0f, 0.0f));
}

FQuat GetQuatFromXZ()
{
	return FQuat::MakeFromXZ(FVector(1.0f, 1.0f, 0.0f), FVector(0.0f, 0.0f, 1.0f));
}

FQuat GetQuatFromYX()
{
	return FQuat::MakeFromYX(FVector(-1.0f, 1.0f, 0.0f), FVector(1.0f, 1.0f, 0.0f));
}

FQuat GetQuatFromYZ()
{
	return FQuat::MakeFromYZ(FVector(-1.0f, 1.0f, 0.0f), FVector(0.0f, 0.0f, 1.0f));
}

FQuat GetQuatFromZX()
{
	return FQuat::MakeFromZX(FVector(0.0f, 0.0f, 1.0f), FVector(1.0f, 1.0f, 0.0f));
}

FQuat GetQuatFromZY()
{
	return FQuat::MakeFromZY(FVector(0.0f, 0.0f, 1.0f), FVector(-1.0f, 1.0f, 0.0f));
}

FTransform GetBlendTransform()
{
	FTransform Result;
	const FTransform A = FTransform(FRotator(10.0f, 20.0f, 30.0f), FVector(100.0f, -50.0f, 25.0f), FVector(1.25f, 0.75f, 2.0f));
	const FTransform B = FTransform(FRotator(-20.0f, 70.0f, 10.0f), FVector(-40.0f, 80.0f, 5.0f), FVector(0.5f, 1.5f, 1.0f));
	Result.Blend(A, B, 0.25f);
	return Result;
}

FTransform GetBlendWithTransform()
{
	FTransform Result = FTransform(FRotator(10.0f, 20.0f, 30.0f), FVector(100.0f, -50.0f, 25.0f), FVector(1.25f, 0.75f, 2.0f));
	const FTransform Other = FTransform(FRotator(-20.0f, 70.0f, 10.0f), FVector(-40.0f, 80.0f, 5.0f), FVector(0.5f, 1.5f, 1.0f));
	Result.BlendWith(Other, 0.5f);
	return Result;
}

FTransform GetSetRotationTransform()
{
	FTransform Result = FTransform(FRotator(10.0f, 20.0f, 30.0f), FVector(100.0f, -50.0f, 25.0f), FVector(1.25f, 0.75f, 2.0f));
	Result.SetRotation(FQuat(FRotator(-30.0f, 15.0f, 45.0f)));
	return Result;
}
)"));
	if (Module == nullptr)
	{
		return false;
	}

	const FVector CanonicalForward(1.0f, 0.0f, 0.0f);
	const FVector CanonicalRight(0.0f, 1.0f, 0.0f);
	const FVector CanonicalUp(0.0f, 0.0f, 1.0f);
	const FRotator ComposeA(0.0f, 90.0f, 0.0f);
	const FRotator ComposeB(45.0f, 0.0f, 0.0f);
	const FVector FactoryX(1.0f, 1.0f, 0.0f);
	const FVector FactoryY(-1.0f, 1.0f, 0.0f);
	const FVector FactoryZ(0.0f, 0.0f, 1.0f);
	const FTransform TransformA(FRotator(10.0f, 20.0f, 30.0f), FVector(100.0f, -50.0f, 25.0f), FVector(1.25f, 0.75f, 2.0f));
	const FTransform TransformB(FRotator(-20.0f, 70.0f, 10.0f), FVector(-40.0f, 80.0f, 5.0f), FVector(0.5f, 1.5f, 1.0f));
	const FRotator ReplacementRotation(-30.0f, 15.0f, 45.0f);

	FRotator ScriptAxesRotator;
	FVector ScriptAxesForward;
	FVector ScriptAxesRight;
	FVector ScriptAxesUp;
	FRotator ScriptComposedRotator;
	FQuat ScriptQuatFromX;
	FQuat ScriptQuatFromY;
	FQuat ScriptQuatFromZ;
	FQuat ScriptQuatFromXY;
	FQuat ScriptQuatFromXZ;
	FQuat ScriptQuatFromYX;
	FQuat ScriptQuatFromYZ;
	FQuat ScriptQuatFromZX;
	FQuat ScriptQuatFromZY;
	FTransform ScriptBlendTransform;
	FTransform ScriptBlendWithTransform;
	FTransform ScriptSetRotationTransform;

	asIScriptFunction* AxesRotatorFunction = GetFunctionByDecl(*this, *Module, TEXT("FRotator GetAxesRotator()"));
	asIScriptFunction* AxesForwardFunction = GetFunctionByDecl(*this, *Module, TEXT("FVector GetAxesForward()"));
	asIScriptFunction* AxesRightFunction = GetFunctionByDecl(*this, *Module, TEXT("FVector GetAxesRight()"));
	asIScriptFunction* AxesUpFunction = GetFunctionByDecl(*this, *Module, TEXT("FVector GetAxesUp()"));
	asIScriptFunction* ComposedRotatorFunction = GetFunctionByDecl(*this, *Module, TEXT("FRotator GetComposedRotator()"));
	asIScriptFunction* QuatFromXFunction = GetFunctionByDecl(*this, *Module, TEXT("FQuat GetQuatFromX()"));
	asIScriptFunction* QuatFromYFunction = GetFunctionByDecl(*this, *Module, TEXT("FQuat GetQuatFromY()"));
	asIScriptFunction* QuatFromZFunction = GetFunctionByDecl(*this, *Module, TEXT("FQuat GetQuatFromZ()"));
	asIScriptFunction* QuatFromXYFunction = GetFunctionByDecl(*this, *Module, TEXT("FQuat GetQuatFromXY()"));
	asIScriptFunction* QuatFromXZFunction = GetFunctionByDecl(*this, *Module, TEXT("FQuat GetQuatFromXZ()"));
	asIScriptFunction* QuatFromYXFunction = GetFunctionByDecl(*this, *Module, TEXT("FQuat GetQuatFromYX()"));
	asIScriptFunction* QuatFromYZFunction = GetFunctionByDecl(*this, *Module, TEXT("FQuat GetQuatFromYZ()"));
	asIScriptFunction* QuatFromZXFunction = GetFunctionByDecl(*this, *Module, TEXT("FQuat GetQuatFromZX()"));
	asIScriptFunction* QuatFromZYFunction = GetFunctionByDecl(*this, *Module, TEXT("FQuat GetQuatFromZY()"));
	asIScriptFunction* BlendTransformFunction = GetFunctionByDecl(*this, *Module, TEXT("FTransform GetBlendTransform()"));
	asIScriptFunction* BlendWithTransformFunction = GetFunctionByDecl(*this, *Module, TEXT("FTransform GetBlendWithTransform()"));
	asIScriptFunction* SetRotationTransformFunction = GetFunctionByDecl(*this, *Module, TEXT("FTransform GetSetRotationTransform()"));
	if (AxesRotatorFunction == nullptr
		|| AxesForwardFunction == nullptr
		|| AxesRightFunction == nullptr
		|| AxesUpFunction == nullptr
		|| ComposedRotatorFunction == nullptr
		|| QuatFromXFunction == nullptr
		|| QuatFromYFunction == nullptr
		|| QuatFromZFunction == nullptr
		|| QuatFromXYFunction == nullptr
		|| QuatFromXZFunction == nullptr
		|| QuatFromYXFunction == nullptr
		|| QuatFromYZFunction == nullptr
		|| QuatFromZXFunction == nullptr
		|| QuatFromZYFunction == nullptr
		|| BlendTransformFunction == nullptr
		|| BlendWithTransformFunction == nullptr
		|| SetRotationTransformFunction == nullptr)
	{
		return false;
	}

	const bool bExecutedAll =
		ExecuteValueFunction(*this, Engine, *AxesRotatorFunction, ScriptAxesRotator) &&
		ExecuteValueFunction(*this, Engine, *AxesForwardFunction, ScriptAxesForward) &&
		ExecuteValueFunction(*this, Engine, *AxesRightFunction, ScriptAxesRight) &&
		ExecuteValueFunction(*this, Engine, *AxesUpFunction, ScriptAxesUp) &&
		ExecuteValueFunction(*this, Engine, *ComposedRotatorFunction, ScriptComposedRotator) &&
		ExecuteValueFunction(*this, Engine, *QuatFromXFunction, ScriptQuatFromX) &&
		ExecuteValueFunction(*this, Engine, *QuatFromYFunction, ScriptQuatFromY) &&
		ExecuteValueFunction(*this, Engine, *QuatFromZFunction, ScriptQuatFromZ) &&
		ExecuteValueFunction(*this, Engine, *QuatFromXYFunction, ScriptQuatFromXY) &&
		ExecuteValueFunction(*this, Engine, *QuatFromXZFunction, ScriptQuatFromXZ) &&
		ExecuteValueFunction(*this, Engine, *QuatFromYXFunction, ScriptQuatFromYX) &&
		ExecuteValueFunction(*this, Engine, *QuatFromYZFunction, ScriptQuatFromYZ) &&
		ExecuteValueFunction(*this, Engine, *QuatFromZXFunction, ScriptQuatFromZX) &&
		ExecuteValueFunction(*this, Engine, *QuatFromZYFunction, ScriptQuatFromZY) &&
		ExecuteValueFunction(*this, Engine, *BlendTransformFunction, ScriptBlendTransform) &&
		ExecuteValueFunction(*this, Engine, *BlendWithTransformFunction, ScriptBlendWithTransform) &&
		ExecuteValueFunction(*this, Engine, *SetRotationTransformFunction, ScriptSetRotationTransform);
	if (!bExecutedAll)
	{
		return false;
	}

	const FRotator ExpectedAxesRotator = FMatrix(CanonicalForward.GetSafeNormal(), CanonicalRight.GetSafeNormal(), CanonicalUp.GetSafeNormal(), FVector::ZeroVector).Rotator();
	const FRotator ExpectedComposedRotator = FRotator(FQuat(ComposeB) * FQuat(ComposeA));
	const FQuat ExpectedQuatFromX = FRotationMatrix::MakeFromX(FactoryX).ToQuat();
	const FQuat ExpectedQuatFromY = FRotationMatrix::MakeFromY(FactoryY).ToQuat();
	const FQuat ExpectedQuatFromZ = FRotationMatrix::MakeFromZ(FactoryZ).ToQuat();
	const FQuat ExpectedQuatFromXY = FRotationMatrix::MakeFromXY(FactoryX, FactoryY).ToQuat();
	const FQuat ExpectedQuatFromXZ = FRotationMatrix::MakeFromXZ(FactoryX, FactoryZ).ToQuat();
	const FQuat ExpectedQuatFromYX = FRotationMatrix::MakeFromYX(FactoryY, FactoryX).ToQuat();
	const FQuat ExpectedQuatFromYZ = FRotationMatrix::MakeFromYZ(FactoryY, FactoryZ).ToQuat();
	const FQuat ExpectedQuatFromZX = FRotationMatrix::MakeFromZX(FactoryZ, FactoryX).ToQuat();
	const FQuat ExpectedQuatFromZY = FRotationMatrix::MakeFromZY(FactoryZ, FactoryY).ToQuat();

	FTransform ExpectedBlendTransform;
	ExpectedBlendTransform.Blend(TransformA, TransformB, 0.25f);
	FTransform ExpectedBlendWithTransform = TransformA;
	ExpectedBlendWithTransform.BlendWith(TransformB, 0.5f);
	FTransform ExpectedSetRotationTransform = TransformA;
	ExpectedSetRotationTransform.SetRotation(ReplacementRotation.Quaternion());

	const bool bAxesRotatorMatches = VerifyRotator(
		*this,
		TEXT("FRotator::MakeFromAxes should build the same orientation as the native matrix conversion"),
		ScriptAxesRotator,
		ExpectedAxesRotator);
	const bool bForwardMatches = VerifyVector(
		*this,
		TEXT("FRotator::GetForwardVector should recover the canonical forward axis from MakeFromAxes"),
		ScriptAxesForward,
		CanonicalForward);
	const bool bRightMatches = VerifyVector(
		*this,
		TEXT("FRotator::GetRightVector should recover the canonical right axis from MakeFromAxes"),
		ScriptAxesRight,
		CanonicalRight);
	const bool bUpMatches = VerifyVector(
		*this,
		TEXT("FRotator::GetUpVector should recover the canonical up axis from MakeFromAxes"),
		ScriptAxesUp,
		CanonicalUp);
	const bool bComposeMatches = VerifyRotator(
		*this,
		TEXT("FRotator::Compose should preserve the native B * A multiplication order"),
		ScriptComposedRotator,
		ExpectedComposedRotator);
	const bool bQuatFromXMatches = VerifyQuat(
		*this,
		TEXT("FQuat::MakeFromX should match the native rotation matrix factory"),
		ScriptQuatFromX,
		ExpectedQuatFromX);
	const bool bQuatFromYMatches = VerifyQuat(
		*this,
		TEXT("FQuat::MakeFromY should match the native rotation matrix factory"),
		ScriptQuatFromY,
		ExpectedQuatFromY);
	const bool bQuatFromZMatches = VerifyQuat(
		*this,
		TEXT("FQuat::MakeFromZ should match the native rotation matrix factory"),
		ScriptQuatFromZ,
		ExpectedQuatFromZ);
	const bool bQuatFromXYMatches = VerifyQuat(
		*this,
		TEXT("FQuat::MakeFromXY should match the native rotation matrix factory"),
		ScriptQuatFromXY,
		ExpectedQuatFromXY);
	const bool bQuatFromXZMatches = VerifyQuat(
		*this,
		TEXT("FQuat::MakeFromXZ should match the native rotation matrix factory"),
		ScriptQuatFromXZ,
		ExpectedQuatFromXZ);
	const bool bQuatFromYXMatches = VerifyQuat(
		*this,
		TEXT("FQuat::MakeFromYX should match the native rotation matrix factory"),
		ScriptQuatFromYX,
		ExpectedQuatFromYX);
	const bool bQuatFromYZMatches = VerifyQuat(
		*this,
		TEXT("FQuat::MakeFromYZ should match the native rotation matrix factory"),
		ScriptQuatFromYZ,
		ExpectedQuatFromYZ);
	const bool bQuatFromZXMatches = VerifyQuat(
		*this,
		TEXT("FQuat::MakeFromZX should match the native rotation matrix factory"),
		ScriptQuatFromZX,
		ExpectedQuatFromZX);
	const bool bQuatFromZYMatches = VerifyQuat(
		*this,
		TEXT("FQuat::MakeFromZY should match the native rotation matrix factory"),
		ScriptQuatFromZY,
		ExpectedQuatFromZY);
	const bool bBlendMatches = VerifyTransform(
		*this,
		TEXT("FTransform::Blend should match native transform blending"),
		ScriptBlendTransform,
		ExpectedBlendTransform);
	const bool bBlendWithMatches = VerifyTransform(
		*this,
		TEXT("FTransform::BlendWith should match native in-place blending"),
		ScriptBlendWithTransform,
		ExpectedBlendWithTransform);
	const bool bSetRotationMatches = VerifyTransform(
		*this,
		TEXT("FTransform::SetRotation should update only the rotation component"),
		ScriptSetRotationTransform,
		ExpectedSetRotationTransform);
	const bool bSetRotationPreservesLocation = VerifyVector(
		*this,
		TEXT("FTransform::SetRotation should preserve the original translation"),
		ScriptSetRotationTransform.GetLocation(),
		TransformA.GetLocation());
	const bool bSetRotationPreservesScale = VerifyVector(
		*this,
		TEXT("FTransform::SetRotation should preserve the original scale"),
		ScriptSetRotationTransform.GetScale3D(),
		TransformA.GetScale3D());

	bPassed =
		bAxesRotatorMatches &&
		bForwardMatches &&
		bRightMatches &&
		bUpMatches &&
		bComposeMatches &&
		bQuatFromXMatches &&
		bQuatFromYMatches &&
		bQuatFromZMatches &&
		bQuatFromXYMatches &&
		bQuatFromXZMatches &&
		bQuatFromYXMatches &&
		bQuatFromYZMatches &&
		bQuatFromZXMatches &&
		bQuatFromZYMatches &&
		bBlendMatches &&
		bBlendWithMatches &&
		bSetRotationMatches &&
		bSetRotationPreservesLocation &&
		bSetRotationPreservesScale;

	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

#endif
