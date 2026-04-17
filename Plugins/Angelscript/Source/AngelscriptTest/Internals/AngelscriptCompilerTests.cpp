#include "Angelscript/AngelscriptTestSupport.h"
#include "../Shared/AngelscriptTestMacros.h"
#include "../Shared/AngelscriptTestEngineHelper.h"
#include "Misc/AutomationTest.h"
#include "Misc/Paths.h"

#include "StartAngelscriptHeaders.h"
#include "source/as_scriptfunction.h"
#include "source/as_scriptengine.h"
#include "EndAngelscriptHeaders.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Internals_AngelscriptCompilerTests_Private
{
	const AngelscriptTestSupport::FAngelscriptCompileTraceDiagnosticSummary* FindErrorDiagnosticContaining(
		const TArray<AngelscriptTestSupport::FAngelscriptCompileTraceDiagnosticSummary>& Diagnostics,
		const FString& Needle)
	{
		for (const AngelscriptTestSupport::FAngelscriptCompileTraceDiagnosticSummary& Diagnostic : Diagnostics)
		{
			if (Diagnostic.bIsError && Diagnostic.Message.Contains(Needle))
			{
				return &Diagnostic;
			}
		}

		return nullptr;
	}

	bool FindLastBytecodeOpcode(const asDWORD* Bytecode, asUINT BytecodeLength, asBYTE& OutOpcode)
	{
		if (Bytecode == nullptr || BytecodeLength == 0)
		{
			return false;
		}

		asUINT Cursor = 0;
		asBYTE LastOpcode = 0;
		while (Cursor < BytecodeLength)
		{
			const asBYTE Opcode = *reinterpret_cast<const asBYTE*>(&Bytecode[Cursor]);
			const int InstructionSize = asBCTypeSize[asBCInfo[Opcode].type];
			if (InstructionSize <= 0 || Cursor + static_cast<asUINT>(InstructionSize) > BytecodeLength)
			{
				return false;
			}

			LastOpcode = Opcode;
			Cursor += static_cast<asUINT>(InstructionSize);
		}

		OutOpcode = LastOpcode;
		return true;
	}
}

using namespace AngelscriptTest_Internals_AngelscriptCompilerTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerBytecodeGenerationTest,
	"Angelscript.TestModule.Internals.Compiler.BytecodeGeneration",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerBytecodeExecutionAndRetBoundaryTest,
	"Angelscript.TestModule.Internals.Compiler.BytecodeExecutionAndRetBoundary",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerVariableScopeTest,
	"Angelscript.TestModule.Internals.Compiler.VariableScopes",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerVariableScopeOutOfScopeUseRejectedTest,
	"Angelscript.TestModule.Internals.Compiler.VariableScopes.OutOfScopeUseRejected",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerFunctionCallTest,
	"Angelscript.TestModule.Internals.Compiler.FunctionCalls",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerTypeConversionTest,
	"Angelscript.TestModule.Internals.Compiler.TypeConversions",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerNegativeAndFloat64TypeConversionTest,
	"Angelscript.TestModule.Internals.Compiler.TypeConversions.NegativeAndFloat64Matrix",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptCompilerBytecodeGenerationTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	asIScriptModule* Module = AngelscriptTestSupport::BuildModule(
		*this,
		Engine,
		"CompilerBytecodeGeneration",
		TEXT("int Entry() { int A = 1; int B = 2; return A + B; }"));
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = AngelscriptTestSupport::GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	asUINT BytecodeLength = 0;
	asDWORD* Bytecode = Function->GetByteCode(&BytecodeLength);
	TestNotNull(TEXT("Compiled function should expose a bytecode buffer"), Bytecode);
	TestTrue(TEXT("Compiled function should emit at least one bytecode instruction"), BytecodeLength > 0);
	bPassed = Bytecode != nullptr && BytecodeLength > 0;
	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

bool FAngelscriptCompilerBytecodeExecutionAndRetBoundaryTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	asIScriptModule* Module = AngelscriptTestSupport::BuildModule(
		*this,
		Engine,
		"CompilerBytecodeExecutionAndRetBoundary",
		TEXT("int Entry(int A) { int B = 2; return A + B; }"));
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = AngelscriptTestSupport::GetFunctionByDecl(*this, *Module, TEXT("int Entry(int)"));
	if (Function == nullptr)
	{
		return false;
	}

	asIScriptContext* Context = Engine.CreateContext();
	if (!TestNotNull(TEXT("Compiler bytecode boundary test should create a script context"), Context))
	{
		return false;
	}

	const int PrepareResult = Context->Prepare(Function);
	const int SetArgResult = PrepareResult == asSUCCESS ? Context->SetArgDWord(0, 1) : PrepareResult;
	const int ExecuteResult = SetArgResult == asSUCCESS ? Context->Execute() : SetArgResult;
	const int32 Result = ExecuteResult == asEXECUTION_FINISHED ? static_cast<int32>(Context->GetReturnDWord()) : 0;
	Context->Release();

	if (!TestEqual(TEXT("Compiler bytecode boundary test should prepare successfully"), PrepareResult, asSUCCESS))
	{
		return false;
	}
	if (!TestEqual(TEXT("Compiler bytecode boundary test should accept the integer argument"), SetArgResult, asSUCCESS))
	{
		return false;
	}
	if (!TestEqual(TEXT("Compiler bytecode boundary test should execute successfully"), ExecuteResult, asEXECUTION_FINISHED))
	{
		return false;
	}
	if (!TestEqual(TEXT("Compiler bytecode boundary test should execute the compiled arithmetic function"), Result, 3))
	{
		return false;
	}

	asUINT BytecodeLength = 0;
	asDWORD* Bytecode = Function->GetByteCode(&BytecodeLength);
	if (!TestNotNull(TEXT("Compiler bytecode boundary test should expose a bytecode buffer"), Bytecode))
	{
		return false;
	}
	if (!TestTrue(TEXT("Compiler bytecode boundary test should emit more than one dword"), BytecodeLength > 1))
	{
		return false;
	}

	const asBYTE FirstOpcode = *reinterpret_cast<const asBYTE*>(&Bytecode[0]);
	if (!TestNotEqual(TEXT("Compiler bytecode boundary test should not begin with RET"), static_cast<int32>(FirstOpcode), static_cast<int32>(asBC_RET)))
	{
		return false;
	}

	asBYTE LastOpcode = 0;
	if (!TestTrue(TEXT("Compiler bytecode boundary test should walk the bytecode to a valid end boundary"), FindLastBytecodeOpcode(Bytecode, BytecodeLength, LastOpcode)))
	{
		return false;
	}
	if (!TestEqual(TEXT("Compiler bytecode boundary test should end with RET"), static_cast<int32>(LastOpcode), static_cast<int32>(asBC_RET)))
	{
		return false;
	}
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptCompilerVariableScopeTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	asIScriptModule* Module = AngelscriptTestSupport::BuildModule(
		*this,
		Engine,
		"CompilerVariableScopes",
		TEXT("int Entry() { int Outer = 1; { int Inner = 2; Outer += Inner; } return Outer; }"));
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = AngelscriptTestSupport::GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	TestTrue(TEXT("Compiled function should report local variables for scoped declarations"), Function->GetVarCount() >= 2);

	const char* FirstVarName = nullptr;
	Function->GetVar(0, &FirstVarName, nullptr);
	TestNotNull(TEXT("Compiler should record the first local variable name"), FirstVarName);
	bPassed = Function->GetVarCount() >= 2;
	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

bool FAngelscriptCompilerVariableScopeOutOfScopeUseRejectedTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	const FName ModuleName(TEXT("CompilerVariableScopesOutOfScope"));
	const FString ScriptFilename = FPaths::Combine(
		FPaths::ProjectSavedDir(),
		TEXT("NegativeCompileIsolation"),
		TEXT("CompilerVariableScopesOutOfScope.as"));
	const FString ScriptSource = TEXT(R"AS(
int Entry()
{
	{
		int Inner = 2;
	}
	return Inner;
}
)AS");

	AngelscriptTestSupport::FAngelscriptCompileTraceSummary Summary;
	const bool bCompiled = AngelscriptTestSupport::CompileModuleWithSummary(
		&Engine,
		ECompileType::SoftReloadOnly,
		ModuleName,
		ScriptFilename,
		ScriptSource,
		false,
		Summary,
		true);
	const AngelscriptTestSupport::FAngelscriptCompileTraceDiagnosticSummary* Diagnostic =
		FindErrorDiagnosticContaining(Summary.Diagnostics, TEXT("is not declared"));

	bPassed &= TestFalse(
		TEXT("Compiler.VariableScopes.OutOfScopeUseRejected should reject out-of-scope locals"),
		bCompiled);
	bPassed &= TestFalse(
		TEXT("Compiler.VariableScopes.OutOfScopeUseRejected should report bCompileSucceeded=false"),
		Summary.bCompileSucceeded);
	bPassed &= TestEqual(
		TEXT("Compiler.VariableScopes.OutOfScopeUseRejected should surface ECompileResult::Error"),
		Summary.CompileResult,
		ECompileResult::Error);
	bPassed &= TestTrue(
		TEXT("Compiler.VariableScopes.OutOfScopeUseRejected should capture at least one diagnostic"),
		Summary.Diagnostics.Num() > 0);
	bPassed &= TestNotNull(
		TEXT("Compiler.VariableScopes.OutOfScopeUseRejected should surface a scope diagnostic"),
		Diagnostic);
	if (Diagnostic != nullptr)
	{
		bPassed &= TestTrue(
			TEXT("Compiler.VariableScopes.OutOfScopeUseRejected should keep the missing variable name in the diagnostic"),
			Diagnostic->Message.Contains(TEXT("Inner")));
		bPassed &= TestTrue(
			TEXT("Compiler.VariableScopes.OutOfScopeUseRejected should report a non-zero row"),
			Diagnostic->Row > 0);
		bPassed &= TestTrue(
			TEXT("Compiler.VariableScopes.OutOfScopeUseRejected should report a non-zero column"),
			Diagnostic->Column > 0);
	}
	bPassed &= TestTrue(
		TEXT("Compiler.VariableScopes.OutOfScopeUseRejected should not leave a compiled module behind"),
		!Engine.GetModuleByModuleName(ModuleName.ToString()).IsValid());

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

bool FAngelscriptCompilerFunctionCallTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	asIScriptModule* Module = AngelscriptTestSupport::BuildModule(
		*this,
		Engine,
		"CompilerFunctionCalls",
		TEXT("int Add(int A, int B) { return A + B; } int Entry() { return Add(7, 5); }"));
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = AngelscriptTestSupport::GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	int32 Result = 0;
	if (!AngelscriptTestSupport::ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}

	TestEqual(TEXT("Compiler should generate callable bytecode for function invocations"), Result, 12);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptCompilerTypeConversionTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	asIScriptModule* Module = AngelscriptTestSupport::BuildModule(
		*this,
		Engine,
		"CompilerTypeConversions",
		TEXT("float32 Entry() { int Value = 7; return float32(Value); }"));
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = AngelscriptTestSupport::GetFunctionByDecl(*this, *Module, TEXT("float32 Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	asIScriptContext* Context = Engine.CreateContext();
	if (!TestNotNull(TEXT("Compiler conversion test should create a script context"), Context))
	{
		return false;
	}

	const int PrepareResult = Context->Prepare(Function);
	const int ExecuteResult = PrepareResult == asSUCCESS ? Context->Execute() : PrepareResult;
	const float Result = Context->GetReturnFloat();
	Context->Release();

	TestEqual(TEXT("Compiler conversion test should prepare successfully"), PrepareResult, asSUCCESS);
	TestEqual(TEXT("Compiler conversion test should execute successfully"), ExecuteResult, asEXECUTION_FINISHED);
	TestTrue(TEXT("Compiler should emit a numeric conversion that preserves the value"), FMath::IsNearlyEqual(Result, 7.0f));
	bPassed = PrepareResult == asSUCCESS && ExecuteResult == asEXECUTION_FINISHED && FMath::IsNearlyEqual(Result, 7.0f);
	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

bool FAngelscriptCompilerNegativeAndFloat64TypeConversionTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	asIScriptModule* Module = AngelscriptTestSupport::BuildModule(
		*this,
		Engine,
		"CompilerTypeConversionsNegativeAndFloat64Matrix",
		TEXT("int Entry() { float32 A = -3.75f; float64 B = 9.25; int FromA = int(A); int FromB = int(B); return (FromA + 10) * 100 + FromB; }"));
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = AngelscriptTestSupport::GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	int32 Result = 0;
	if (!AngelscriptTestSupport::ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}

	if (!TestEqual(
		TEXT("Compiler type conversion matrix should truncate both float32 negatives and float64 positives toward zero"),
		Result,
		709))
	{
		return false;
	}

	asUINT BytecodeLength = 0;
	asDWORD* Bytecode = Function->GetByteCode(&BytecodeLength);
	if (!TestNotNull(TEXT("Compiler type conversion matrix should expose generated bytecode"), Bytecode))
	{
		return false;
	}
	if (!TestTrue(TEXT("Compiler type conversion matrix should emit at least one bytecode instruction"), BytecodeLength > 0))
	{
		return false;
	}

	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
