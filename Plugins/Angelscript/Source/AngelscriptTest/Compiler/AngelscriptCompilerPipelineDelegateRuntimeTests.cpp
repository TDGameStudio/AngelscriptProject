#include "../Shared/AngelscriptTestEngineHelper.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Containers/StringConv.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace CompilerPipelineDelegateRuntimeTest
{
	static const FName ModuleName(TEXT("Tests.Compiler.DelegateExecuteReportsUnboundRuntimeError"));
	static const FString ScriptFilename(TEXT("Tests/Compiler/DelegateExecuteReportsUnboundRuntimeError.as"));
	static const TCHAR* EntryFunctionDeclaration(TEXT("int Entry()"));
	static const TCHAR* ExpectedExceptionString(TEXT("Executing unbound delegate."));
	static const TCHAR* ExpectedExceptionFunctionDeclaration(TEXT("int FRuntimeValueDelegate::Execute() const"));
	static constexpr int32 ExpectedExceptionLine = 11;

	struct FExecutionExceptionResult
	{
		int32 PrepareResult = MIN_int32;
		int32 ExecuteResult = MIN_int32;
		FString ExceptionString;
		int32 ExceptionLine = 0;
		FString ExceptionFunctionDeclaration;
	};

	static asIScriptModule* GetCompiledModule(FAutomationTestBase& Test, FAngelscriptEngine& Engine)
	{
		const auto ModuleNameUtf8 = StringCast<ANSICHAR>(*ModuleName.ToString());
		asIScriptModule* Module = Engine.GetScriptEngine()->GetModule(ModuleNameUtf8.Get(), asGM_ONLY_IF_EXISTS);
		Test.TestNotNull(TEXT("Delegate execute runtime error compile should publish a script module"), Module);
		return Module;
	}

	static bool ExecuteEntryAndCaptureException(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		asIScriptModule& Module,
		FExecutionExceptionResult& OutResult)
	{
		asIScriptFunction* EntryFunction = GetFunctionByDecl(Test, Module, EntryFunctionDeclaration);
		if (EntryFunction == nullptr)
		{
			return false;
		}

		FAngelscriptEngineScope EngineScope(Engine);
		asIScriptContext* Context = Engine.CreateContext();
		if (!Test.TestNotNull(TEXT("Delegate execute runtime error scenario should create an execution context"), Context))
		{
			return false;
		}

		ON_SCOPE_EXIT
		{
			Context->Release();
		};

		OutResult.PrepareResult = Context->Prepare(EntryFunction);
		OutResult.ExecuteResult = OutResult.PrepareResult == asSUCCESS ? Context->Execute() : OutResult.PrepareResult;
		OutResult.ExceptionString = Context->GetExceptionString() != nullptr ? UTF8_TO_TCHAR(Context->GetExceptionString()) : TEXT("");
		OutResult.ExceptionLine = Context->GetExceptionLineNumber();

		if (asIScriptFunction* ExceptionFunction = Context->GetExceptionFunction())
		{
			OutResult.ExceptionFunctionDeclaration = UTF8_TO_TCHAR(ExceptionFunction->GetDeclaration());
		}

		return true;
	}
}

using namespace CompilerPipelineDelegateRuntimeTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerDelegateExecuteReportsUnboundRuntimeErrorTest,
	"Angelscript.TestModule.Compiler.EndToEnd.DelegateExecuteReportsUnboundRuntimeError",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerDelegateExecuteIfBoundReturnsDefaultValueTest,
	"Angelscript.TestModule.Compiler.EndToEnd.DelegateExecuteIfBoundReturnsDefaultValue",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptCompilerDelegateExecuteReportsUnboundRuntimeErrorTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	const FString ScriptSource = TEXT(R"AS(
delegate int FRuntimeValueDelegate();

int Entry()
{
	FRuntimeValueDelegate Delegate;
	return Delegate.Execute();
}
)AS");

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*CompilerPipelineDelegateRuntimeTest::ModuleName.ToString());
	};

	FAngelscriptCompileTraceSummary Summary;
	const bool bCompiled = CompileModuleWithSummary(
		&Engine,
		ECompileType::FullReload,
		CompilerPipelineDelegateRuntimeTest::ModuleName,
		CompilerPipelineDelegateRuntimeTest::ScriptFilename,
		ScriptSource,
		true,
		Summary);

	bPassed &= TestTrue(
		TEXT("Delegate execute runtime error scenario should compile successfully"),
		bCompiled);
	bPassed &= TestTrue(
		TEXT("Delegate execute runtime error scenario should run through the preprocessor pipeline"),
		Summary.bUsedPreprocessor);
	bPassed &= TestTrue(
		TEXT("Delegate execute runtime error scenario should report compile success before execution"),
		Summary.bCompileSucceeded);
	bPassed &= TestEqual(
		TEXT("Delegate execute runtime error scenario should finish with FullyHandled"),
		Summary.CompileResult,
		ECompileResult::FullyHandled);
	bPassed &= TestEqual(
		TEXT("Delegate execute runtime error scenario should keep compile diagnostics empty"),
		Summary.Diagnostics.Num(),
		0);
	if (!bCompiled)
	{
		return false;
	}

	asIScriptModule* Module = CompilerPipelineDelegateRuntimeTest::GetCompiledModule(*this, Engine);
	if (Module == nullptr)
	{
		return false;
	}

	AddExpectedError(TEXT("Executing unbound delegate."), EAutomationExpectedErrorFlags::Contains, 1);
	AddExpectedError(*CompilerPipelineDelegateRuntimeTest::ModuleName.ToString(), EAutomationExpectedErrorFlags::Contains, 0);
	AddExpectedError(TEXT("int FRuntimeValueDelegate::Execute() const | Line 11"), EAutomationExpectedErrorFlags::Contains, 1, false);
	AddExpectedError(TEXT("int Entry() | Line 7"), EAutomationExpectedErrorFlags::Contains, 1, false);

	CompilerPipelineDelegateRuntimeTest::FExecutionExceptionResult ExecutionResult;
	const bool bExecuted = CompilerPipelineDelegateRuntimeTest::ExecuteEntryAndCaptureException(
		*this,
		Engine,
		*Module,
		ExecutionResult);
	bPassed &= TestTrue(
		TEXT("Delegate execute runtime error scenario should reach the manual execution path"),
		bExecuted);
	if (!bExecuted)
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("Delegate execute runtime error scenario should prepare the entry function successfully"),
		ExecutionResult.PrepareResult,
		static_cast<int32>(asSUCCESS));
	bPassed &= TestEqual(
		TEXT("Delegate execute runtime error scenario should fail during execution with a script exception"),
		ExecutionResult.ExecuteResult,
		static_cast<int32>(asEXECUTION_EXCEPTION));
	bPassed &= TestEqual(
		TEXT("Delegate execute runtime error scenario should report the generated unbound delegate message"),
		ExecutionResult.ExceptionString,
		FString(CompilerPipelineDelegateRuntimeTest::ExpectedExceptionString));
	bPassed &= TestEqual(
		TEXT("Delegate execute runtime error scenario should report the generated delegate Execute wrapper line"),
		ExecutionResult.ExceptionLine,
		CompilerPipelineDelegateRuntimeTest::ExpectedExceptionLine);
	bPassed &= TestEqual(
		TEXT("Delegate execute runtime error scenario should attribute the exception to the generated delegate Execute wrapper"),
		ExecutionResult.ExceptionFunctionDeclaration,
		FString(CompilerPipelineDelegateRuntimeTest::ExpectedExceptionFunctionDeclaration));

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

bool FAngelscriptCompilerDelegateExecuteIfBoundReturnsDefaultValueTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	const FString ScriptSource = TEXT(R"AS(
delegate int FRuntimeValueDelegate();
delegate bool FRuntimeBoolDelegate();

int Entry()
{
	FRuntimeValueDelegate Delegate;
	return Delegate.ExecuteIfBound();
}

int EntryBool()
{
	FRuntimeBoolDelegate Delegate;
	return Delegate.ExecuteIfBound() ? 1 : 0;
}
)AS");

	const FName LocalModuleName(TEXT("Tests.Compiler.DelegateExecuteIfBoundReturnsDefaultValue"));
	const FString LocalScriptFilename(TEXT("Tests/Compiler/DelegateExecuteIfBoundReturnsDefaultValue.as"));

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*LocalModuleName.ToString());
	};

	FAngelscriptCompileTraceSummary Summary;
	const bool bCompiled = CompileModuleWithSummary(
		&Engine,
		ECompileType::FullReload,
		LocalModuleName,
		LocalScriptFilename,
		ScriptSource,
		true,
		Summary);

	bPassed &= TestTrue(
		TEXT("Delegate ExecuteIfBound default-value scenario should compile successfully"),
		bCompiled);
	bPassed &= TestTrue(
		TEXT("Delegate ExecuteIfBound default-value scenario should run through the preprocessor pipeline"),
		Summary.bUsedPreprocessor);
	bPassed &= TestTrue(
		TEXT("Delegate ExecuteIfBound default-value scenario should report compile success before execution"),
		Summary.bCompileSucceeded);
	bPassed &= TestEqual(
		TEXT("Delegate ExecuteIfBound default-value scenario should finish with FullyHandled"),
		Summary.CompileResult,
		ECompileResult::FullyHandled);
	bPassed &= TestEqual(
		TEXT("Delegate ExecuteIfBound default-value scenario should keep compile diagnostics empty"),
		Summary.Diagnostics.Num(),
		0);
	if (!bCompiled)
	{
		return false;
	}

	const auto ModuleNameUtf8 = StringCast<ANSICHAR>(*LocalModuleName.ToString());
	asIScriptModule* Module = Engine.GetScriptEngine()->GetModule(ModuleNameUtf8.Get(), asGM_ONLY_IF_EXISTS);
	if (!TestNotNull(TEXT("Delegate ExecuteIfBound default-value scenario should publish a script module"), Module))
	{
		return false;
	}

	asIScriptFunction* EntryFunction = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	asIScriptFunction* EntryBoolFunction = GetFunctionByDecl(*this, *Module, TEXT("int EntryBool()"));
	if (EntryFunction == nullptr || EntryBoolFunction == nullptr)
	{
		return false;
	}

	int32 IntResult = MIN_int32;
	int32 BoolResult = MIN_int32;
	bPassed &= ExecuteIntFunction(*this, Engine, *EntryFunction, IntResult);
	bPassed &= ExecuteIntFunction(*this, Engine, *EntryBoolFunction, BoolResult);

	bPassed &= TestEqual(
		TEXT("Delegate ExecuteIfBound default-value scenario should return 0 for unbound int delegates"),
		IntResult,
		0);
	bPassed &= TestEqual(
		TEXT("Delegate ExecuteIfBound default-value scenario should return 0 for unbound bool delegates"),
		BoolResult,
		0);

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
