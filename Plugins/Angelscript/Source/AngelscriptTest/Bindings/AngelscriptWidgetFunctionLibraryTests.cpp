#include "../Shared/AngelscriptTestMacros.h"
#include "../Shared/AngelscriptTestUtilities.h"

#include "Components/Button.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "Templates/Function.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Bindings_AngelscriptWidgetFunctionLibraryTests_Private
{
	static constexpr ANSICHAR ModuleName[] = "ASWidgetRenderTransformNullGuard";

	bool SetArgObjectChecked(
		FAutomationTestBase& Test,
		asIScriptContext& Context,
		asUINT ArgumentIndex,
		void* Object,
		const TCHAR* ContextLabel)
	{
		return Test.TestEqual(
			*FString::Printf(TEXT("%s should bind object argument %u"), ContextLabel, static_cast<uint32>(ArgumentIndex)),
			Context.SetArgObject(ArgumentIndex, Object),
			static_cast<int32>(asSUCCESS));
	}

	bool ExecuteIntFunction(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		asIScriptModule& Module,
		const TCHAR* FunctionDecl,
		TFunctionRef<bool(asIScriptContext&)> BindArguments,
		const TCHAR* ContextLabel,
		int32& OutResult)
	{
		asIScriptFunction* Function = GetFunctionByDecl(Test, Module, FunctionDecl);
		if (Function == nullptr)
		{
			return false;
		}

		FAngelscriptEngineScope EngineScope(Engine);
		asIScriptContext* Context = Engine.CreateContext();
		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should create an execution context"), ContextLabel), Context))
		{
			return false;
		}

		ON_SCOPE_EXIT
		{
			Context->Release();
		};

		const int PrepareResult = Context->Prepare(Function);
		if (!Test.TestEqual(
			*FString::Printf(TEXT("%s should prepare successfully"), ContextLabel),
			PrepareResult,
			static_cast<int32>(asSUCCESS)))
		{
			return false;
		}

		if (!BindArguments(*Context))
		{
			return false;
		}

		const int ExecuteResult = Context->Execute();
		if (!Test.TestEqual(
			*FString::Printf(TEXT("%s should execute successfully"), ContextLabel),
			ExecuteResult,
			static_cast<int32>(asEXECUTION_FINISHED)))
		{
			return false;
		}

		OutResult = static_cast<int32>(Context->GetReturnDWord());
		return true;
	}

	bool ExecuteFunctionExpectingException(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		asIScriptModule& Module,
		const TCHAR* FunctionDecl,
		TFunctionRef<bool(asIScriptContext&)> BindArguments,
		const TCHAR* ContextLabel,
		FString& OutExceptionString)
	{
		asIScriptFunction* Function = GetFunctionByDecl(Test, Module, FunctionDecl);
		if (Function == nullptr)
		{
			return false;
		}

		FAngelscriptEngineScope EngineScope(Engine);
		asIScriptContext* Context = Engine.CreateContext();
		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should create an execution context"), ContextLabel), Context))
		{
			return false;
		}

		ON_SCOPE_EXIT
		{
			Context->Release();
		};

		const int PrepareResult = Context->Prepare(Function);
		if (!Test.TestEqual(
			*FString::Printf(TEXT("%s should prepare successfully"), ContextLabel),
			PrepareResult,
			static_cast<int32>(asSUCCESS)))
		{
			return false;
		}

		if (!BindArguments(*Context))
		{
			return false;
		}

		const int ExecuteResult = Context->Execute();
		if (!Test.TestEqual(
			*FString::Printf(TEXT("%s should fail with a script exception"), ContextLabel),
			ExecuteResult,
			static_cast<int32>(asEXECUTION_EXCEPTION)))
		{
			return false;
		}

		OutExceptionString = Context->GetExceptionString() != nullptr ? UTF8_TO_TCHAR(Context->GetExceptionString()) : TEXT("");
		return true;
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptWidgetFunctionLibraryTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptWidgetRenderTransformNullGuardTest,
	"Angelscript.TestModule.FunctionLibraries.WidgetRenderTransformNullGuard",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptWidgetRenderTransformNullGuardTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	AddExpectedError(TEXT("Null pointer access"), EAutomationExpectedErrorFlags::Contains, 0);
	AddExpectedError(TEXT("ASWidgetRenderTransformNullGuard"), EAutomationExpectedErrorFlags::Contains, 0);
	AddExpectedError(TEXT("int ReadWidgetTransform(UWidget) | Line 4 | Col 2"), EAutomationExpectedErrorFlags::Contains, 1, false);

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_FULL();
	ASTEST_BEGIN_FULL

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		ModuleName,
		TEXT(R"(
int ReadWidgetTransform(UWidget Widget)
{
	const FWidgetTransform Transform = Widget.GetRenderTransform();
	if (Transform.Translation.X != 13.5f || Transform.Translation.Y != -9.25f)
		return 10;
	if (Transform.Scale.X != 1.25f || Transform.Scale.Y != 0.75f)
		return 20;
	if (Transform.Angle != 42.0f)
		return 30;
	return 1;
}
)"));
	if (Module == nullptr)
	{
		return false;
	}

	UButton* TestWidget = NewObject<UButton>(GetTransientPackage(), TEXT("FunctionLibraryWidget"));
	if (!TestNotNull(TEXT("Widget function library test should create a concrete widget"), TestWidget))
	{
		return false;
	}

	FWidgetTransform ExpectedTransform;
	ExpectedTransform.Translation = FVector2D(13.5f, -9.25f);
	ExpectedTransform.Scale = FVector2D(1.25f, 0.75f);
	ExpectedTransform.Angle = 42.0f;
	TestWidget->SetRenderTransform(ExpectedTransform);

	int32 ScriptResult = INDEX_NONE;
	if (!ExecuteIntFunction(
		*this,
		Engine,
		*Module,
		TEXT("int ReadWidgetTransform(UWidget Widget)"),
		[this, TestWidget](asIScriptContext& Context)
		{
			return SetArgObjectChecked(*this, Context, 0, TestWidget, TEXT("ReadWidgetTransform(valid)"));
		},
		TEXT("ReadWidgetTransform(valid)"),
		ScriptResult))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("GetRenderTransform should preserve the native translation, scale, and angle for a valid widget"),
		ScriptResult,
		1);

	FString NullWidgetException;
	if (!ExecuteFunctionExpectingException(
		*this,
		Engine,
		*Module,
		TEXT("int ReadWidgetTransform(UWidget Widget)"),
		[this](asIScriptContext& Context)
		{
			return SetArgObjectChecked(*this, Context, 0, nullptr, TEXT("ReadWidgetTransform(null)"));
		},
		TEXT("ReadWidgetTransform(null)"),
		NullWidgetException))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("GetRenderTransform should report a stable null-pointer diagnostic for a null widget receiver"),
		NullWidgetException,
		FString(TEXT("Null pointer access")));

	ASTEST_END_FULL
	return bPassed;
}

#endif
