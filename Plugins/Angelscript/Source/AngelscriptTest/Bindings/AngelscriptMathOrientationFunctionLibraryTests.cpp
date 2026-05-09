// ============================================================================
// AngelscriptMathOrientationFunctionLibraryTests.cpp
//
// Math orientation function library binding coverage — CQTest refactor.
// Automation ID:
//   Angelscript.TestModule.FunctionLibraries.MathOrientation.FAngelscriptMathOrientationFunctionLibraryTest.*
//
// Sections:
//   FactoriesAndTransformMutators — FRotator factories, FQuat factories,
//     FTransform Blend/BlendWith/SetRotation parity
//
// CQTest adaptation notes:
//   One IMPLEMENT_SIMPLE_AUTOMATION_TEST merged into one TEST_CLASS.
//   This test retains the custom ExecuteValueFunction helper because each
//   script function returns a struct (FRotator/FQuat/FTransform) that must
//   be read via GetAddressOfReturnValue.
// ============================================================================

#include "CQTest.h"
#include "Shared/AngelscriptTestMacros.h"
#include "Shared/AngelscriptTestUtilities.h"
#include "Shared/AngelscriptTestEngineHelper.h"
#include "Shared/AngelscriptBindingsCoverage.h"
#include "Shared/AngelscriptBindingsModuleBuilder.h"
#include "Shared/AngelscriptBindingsAssertions.h"

#include "Math/Quat.h"
#include "Math/RotationMatrix.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptTestBindings;
using namespace AngelscriptReflectiveAccess;

static const FBindingsCoverageProfile GMathOrientProfile{
	TEXT("MathOrientation"), TEXT(""), TEXT("ASMathOrient"), TEXT("MathOrient"), TEXT("MathOrientationBindings")
};

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


TEST_CLASS_WITH_FLAGS(FAngelscriptMathOrientationFunctionLibraryTest, "Angelscript.TestModule.FunctionLibraries.MathOrientation",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	BEFORE_ALL()
	{
		ASTEST_CREATE_ENGINE();
	}

	AFTER_ALL() { FAngelscriptEngine& Engine = ASTEST_GET_ENGINE(); ASTEST_RESET_ENGINE(Engine); }

	TEST_METHOD(FactoriesAndTransformMutators)
	{
		using namespace AngelscriptTest_Bindings_AngelscriptMathOrientationFunctionLibraryTests_Private;
		FAngelscriptEngine& Engine = ASTEST_GET_ENGINE();
		FAngelscriptEngineScope Scope(Engine);

		FCoverageModuleScope Mod(*TestRunner, Engine, GMathOrientProfile, TEXT("FactoriesAndMutators"), TEXT(R"(
FRotator GetAxesRotator()
{
	return FRotator::MakeFromAxes(FVector(1.0f, 0.0f, 0.0f), FVector(0.0f, 1.0f, 0.0f), FVector(0.0f, 0.0f, 1.0f));
}

FVector GetAxesForward()
{
	return FRotator::GetForwardVector(GetAxesRotator());
}

FVector GetAxesForwardMember()
{
	const FRotator Rotator = GetAxesRotator();
	return Rotator.GetForwardVector();
}

FVector GetAxesRight()
{
	return FRotator::GetRightVector(GetAxesRotator());
}

FVector GetAxesRightMember()
{
	const FRotator Rotator = GetAxesRotator();
	return Rotator.GetRightVector();
}

FVector GetAxesUp()
{
	return FRotator::GetUpVector(GetAxesRotator());
}

FVector GetAxesUpMember()
{
	const FRotator Rotator = GetAxesRotator();
	return Rotator.GetUpVector();
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
		if (!Mod.IsValid()) return;
		auto& Module = Mod.GetModule();

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
		FVector ScriptAxesForwardMember;
		FVector ScriptAxesRight;
		FVector ScriptAxesRightMember;
		FVector ScriptAxesUp;
		FVector ScriptAxesUpMember;
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

		asIScriptFunction* AxesRotatorFunction = GetFunctionByDecl(*TestRunner, Module, TEXT("FRotator GetAxesRotator()"));
		asIScriptFunction* AxesForwardFunction = GetFunctionByDecl(*TestRunner, Module, TEXT("FVector GetAxesForward()"));
		asIScriptFunction* AxesForwardMemberFunction = GetFunctionByDecl(*TestRunner, Module, TEXT("FVector GetAxesForwardMember()"));
		asIScriptFunction* AxesRightFunction = GetFunctionByDecl(*TestRunner, Module, TEXT("FVector GetAxesRight()"));
		asIScriptFunction* AxesRightMemberFunction = GetFunctionByDecl(*TestRunner, Module, TEXT("FVector GetAxesRightMember()"));
		asIScriptFunction* AxesUpFunction = GetFunctionByDecl(*TestRunner, Module, TEXT("FVector GetAxesUp()"));
		asIScriptFunction* AxesUpMemberFunction = GetFunctionByDecl(*TestRunner, Module, TEXT("FVector GetAxesUpMember()"));
		asIScriptFunction* ComposedRotatorFunction = GetFunctionByDecl(*TestRunner, Module, TEXT("FRotator GetComposedRotator()"));
		asIScriptFunction* QuatFromXFunction = GetFunctionByDecl(*TestRunner, Module, TEXT("FQuat GetQuatFromX()"));
		asIScriptFunction* QuatFromYFunction = GetFunctionByDecl(*TestRunner, Module, TEXT("FQuat GetQuatFromY()"));
		asIScriptFunction* QuatFromZFunction = GetFunctionByDecl(*TestRunner, Module, TEXT("FQuat GetQuatFromZ()"));
		asIScriptFunction* QuatFromXYFunction = GetFunctionByDecl(*TestRunner, Module, TEXT("FQuat GetQuatFromXY()"));
		asIScriptFunction* QuatFromXZFunction = GetFunctionByDecl(*TestRunner, Module, TEXT("FQuat GetQuatFromXZ()"));
		asIScriptFunction* QuatFromYXFunction = GetFunctionByDecl(*TestRunner, Module, TEXT("FQuat GetQuatFromYX()"));
		asIScriptFunction* QuatFromYZFunction = GetFunctionByDecl(*TestRunner, Module, TEXT("FQuat GetQuatFromYZ()"));
		asIScriptFunction* QuatFromZXFunction = GetFunctionByDecl(*TestRunner, Module, TEXT("FQuat GetQuatFromZX()"));
		asIScriptFunction* QuatFromZYFunction = GetFunctionByDecl(*TestRunner, Module, TEXT("FQuat GetQuatFromZY()"));
		asIScriptFunction* BlendTransformFunction = GetFunctionByDecl(*TestRunner, Module, TEXT("FTransform GetBlendTransform()"));
		asIScriptFunction* BlendWithTransformFunction = GetFunctionByDecl(*TestRunner, Module, TEXT("FTransform GetBlendWithTransform()"));
		asIScriptFunction* SetRotationTransformFunction = GetFunctionByDecl(*TestRunner, Module, TEXT("FTransform GetSetRotationTransform()"));
		if (AxesRotatorFunction == nullptr
			|| AxesForwardFunction == nullptr
			|| AxesForwardMemberFunction == nullptr
			|| AxesRightFunction == nullptr
			|| AxesRightMemberFunction == nullptr
			|| AxesUpFunction == nullptr
			|| AxesUpMemberFunction == nullptr
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
			return;
		}

		const bool bExecutedAll =
			ExecuteValueFunction(*TestRunner, Engine, *AxesRotatorFunction, ScriptAxesRotator) &&
			ExecuteValueFunction(*TestRunner, Engine, *AxesForwardFunction, ScriptAxesForward) &&
			ExecuteValueFunction(*TestRunner, Engine, *AxesForwardMemberFunction, ScriptAxesForwardMember) &&
			ExecuteValueFunction(*TestRunner, Engine, *AxesRightFunction, ScriptAxesRight) &&
			ExecuteValueFunction(*TestRunner, Engine, *AxesRightMemberFunction, ScriptAxesRightMember) &&
			ExecuteValueFunction(*TestRunner, Engine, *AxesUpFunction, ScriptAxesUp) &&
			ExecuteValueFunction(*TestRunner, Engine, *AxesUpMemberFunction, ScriptAxesUpMember) &&
			ExecuteValueFunction(*TestRunner, Engine, *ComposedRotatorFunction, ScriptComposedRotator) &&
			ExecuteValueFunction(*TestRunner, Engine, *QuatFromXFunction, ScriptQuatFromX) &&
			ExecuteValueFunction(*TestRunner, Engine, *QuatFromYFunction, ScriptQuatFromY) &&
			ExecuteValueFunction(*TestRunner, Engine, *QuatFromZFunction, ScriptQuatFromZ) &&
			ExecuteValueFunction(*TestRunner, Engine, *QuatFromXYFunction, ScriptQuatFromXY) &&
			ExecuteValueFunction(*TestRunner, Engine, *QuatFromXZFunction, ScriptQuatFromXZ) &&
			ExecuteValueFunction(*TestRunner, Engine, *QuatFromYXFunction, ScriptQuatFromYX) &&
			ExecuteValueFunction(*TestRunner, Engine, *QuatFromYZFunction, ScriptQuatFromYZ) &&
			ExecuteValueFunction(*TestRunner, Engine, *QuatFromZXFunction, ScriptQuatFromZX) &&
			ExecuteValueFunction(*TestRunner, Engine, *QuatFromZYFunction, ScriptQuatFromZY) &&
			ExecuteValueFunction(*TestRunner, Engine, *BlendTransformFunction, ScriptBlendTransform) &&
			ExecuteValueFunction(*TestRunner, Engine, *BlendWithTransformFunction, ScriptBlendWithTransform) &&
			ExecuteValueFunction(*TestRunner, Engine, *SetRotationTransformFunction, ScriptSetRotationTransform);
		if (!bExecutedAll)
		{
			return;
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

		VerifyRotator(
			*TestRunner,
			TEXT("FRotator::MakeFromAxes should build the same orientation as the native matrix conversion"),
			ScriptAxesRotator,
			ExpectedAxesRotator);
		VerifyVector(
			*TestRunner,
			TEXT("FRotator::GetForwardVector should recover the canonical forward axis from MakeFromAxes"),
			ScriptAxesForward,
			CanonicalForward);
		VerifyVector(
			*TestRunner,
			TEXT("FRotator.GetForwardVector should recover the canonical forward axis from MakeFromAxes"),
			ScriptAxesForwardMember,
			CanonicalForward);
		VerifyVector(
			*TestRunner,
			TEXT("FRotator::GetRightVector should recover the canonical right axis from MakeFromAxes"),
			ScriptAxesRight,
			CanonicalRight);
		VerifyVector(
			*TestRunner,
			TEXT("FRotator.GetRightVector should recover the canonical right axis from MakeFromAxes"),
			ScriptAxesRightMember,
			CanonicalRight);
		VerifyVector(
			*TestRunner,
			TEXT("FRotator::GetUpVector should recover the canonical up axis from MakeFromAxes"),
			ScriptAxesUp,
			CanonicalUp);
		VerifyVector(
			*TestRunner,
			TEXT("FRotator.GetUpVector should recover the canonical up axis from MakeFromAxes"),
			ScriptAxesUpMember,
			CanonicalUp);
		VerifyRotator(
			*TestRunner,
			TEXT("FRotator::Compose should preserve the native B * A multiplication order"),
			ScriptComposedRotator,
			ExpectedComposedRotator);
		VerifyQuat(
			*TestRunner,
			TEXT("FQuat::MakeFromX should match the native rotation matrix factory"),
			ScriptQuatFromX,
			ExpectedQuatFromX);
		VerifyQuat(
			*TestRunner,
			TEXT("FQuat::MakeFromY should match the native rotation matrix factory"),
			ScriptQuatFromY,
			ExpectedQuatFromY);
		VerifyQuat(
			*TestRunner,
			TEXT("FQuat::MakeFromZ should match the native rotation matrix factory"),
			ScriptQuatFromZ,
			ExpectedQuatFromZ);
		VerifyQuat(
			*TestRunner,
			TEXT("FQuat::MakeFromXY should match the native rotation matrix factory"),
			ScriptQuatFromXY,
			ExpectedQuatFromXY);
		VerifyQuat(
			*TestRunner,
			TEXT("FQuat::MakeFromXZ should match the native rotation matrix factory"),
			ScriptQuatFromXZ,
			ExpectedQuatFromXZ);
		VerifyQuat(
			*TestRunner,
			TEXT("FQuat::MakeFromYX should match the native rotation matrix factory"),
			ScriptQuatFromYX,
			ExpectedQuatFromYX);
		VerifyQuat(
			*TestRunner,
			TEXT("FQuat::MakeFromYZ should match the native rotation matrix factory"),
			ScriptQuatFromYZ,
			ExpectedQuatFromYZ);
		VerifyQuat(
			*TestRunner,
			TEXT("FQuat::MakeFromZX should match the native rotation matrix factory"),
			ScriptQuatFromZX,
			ExpectedQuatFromZX);
		VerifyQuat(
			*TestRunner,
			TEXT("FQuat::MakeFromZY should match the native rotation matrix factory"),
			ScriptQuatFromZY,
			ExpectedQuatFromZY);
		VerifyTransform(
			*TestRunner,
			TEXT("FTransform::Blend should match native transform blending"),
			ScriptBlendTransform,
			ExpectedBlendTransform);
		VerifyTransform(
			*TestRunner,
			TEXT("FTransform::BlendWith should match native in-place blending"),
			ScriptBlendWithTransform,
			ExpectedBlendWithTransform);
		VerifyTransform(
			*TestRunner,
			TEXT("FTransform::SetRotation should update only the rotation component"),
			ScriptSetRotationTransform,
			ExpectedSetRotationTransform);
		VerifyVector(
			*TestRunner,
			TEXT("FTransform::SetRotation should preserve the original translation"),
			ScriptSetRotationTransform.GetLocation(),
			TransformA.GetLocation());
		VerifyVector(
			*TestRunner,
			TEXT("FTransform::SetRotation should preserve the original scale"),
			ScriptSetRotationTransform.GetScale3D(),
			TransformA.GetScale3D());
	}
};

#endif
