// ============================================================================
// AngelscriptSyntaxUFunctionTests.cpp
//
// Syntax coverage tests for UFUNCTION declarations — CQTest edition.
// Tests specifiers (positive/negative) and parameter forms (negative).
//
// Automation prefix: Angelscript.TestModule.Syntax.UFunction.*
// ============================================================================

#include "CQTest.h"
#include "Shared/AngelscriptTestMacros.h"
#include "Shared/AngelscriptBindingsCoverage.h"
#include "Shared/AngelscriptBindingsModuleBuilder.h"
#include "Shared/AngelscriptBindingsAssertions.h"
#include "Syntax/AngelscriptSyntaxTestHelpers.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptTestBindings;

// ----------------------------------------------------------------------------
// Profile
// ----------------------------------------------------------------------------

static const FBindingsCoverageProfile GSyntaxUFuncProfile{
	TEXT("Syntax"),          // Theme
	TEXT("UFunc"),           // Variant
	TEXT("ASSyntaxUF"),      // ModulePrefix
	TEXT("UFunc"),           // CasePrefix
	TEXT("SyntaxUFunc"),     // LogCategory
};

// ====================================================================
// Test Class
// ====================================================================

TEST_CLASS_WITH_FLAGS(FAngelscriptSyntaxUFunctionTest,
	"Angelscript.TestModule.Syntax.UFunction",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	BEFORE_ALL()
	{
		ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	}

	AFTER_ALL()
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		AngelscriptTestSupport::ResetSharedCloneEngine(Engine);
	}

	// ====================================================================
	// Specifiers — Positive
	// ====================================================================

	TEST_METHOD(Specifiers_Positive)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		// Basic UFUNCTION
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UFuncSP_Basic"),
			TEXT(R"(
class AUFuncBasicActor : AActor
{
	UFUNCTION()
	void DoSomething() { }
}
)"),
			TEXT("Basic UFUNCTION"));

		// BlueprintCallable
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UFuncSP_BPCallable"),
			TEXT(R"(
class AUFuncBPCallActor : AActor
{
	UFUNCTION(BlueprintCallable)
	void DoWork() { }
}
)"),
			TEXT("BlueprintCallable specifier"));

		// BlueprintPure
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UFuncSP_BPPure"),
			TEXT(R"(
class AUFuncBPPureActor : AActor
{
	UFUNCTION(BlueprintPure)
	int GetHealth() const { return 100; }
}
)"),
			TEXT("BlueprintPure specifier"));

		// BlueprintEvent
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UFuncSP_BPEvent"),
			TEXT(R"(
class AUFuncBPEventActor : AActor
{
	UFUNCTION(BlueprintEvent)
	void OnDamageReceived() { }
}
)"),
			TEXT("BlueprintEvent specifier"));

		// BlueprintOverride
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UFuncSP_BPOverride"),
			TEXT(R"(
class AUFuncBPOverrideActor : AActor
{
	UFUNCTION(BlueprintOverride)
	void ReceiveBeginPlay() { }
}
)"),
			TEXT("BlueprintOverride specifier"));

		// Category
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UFuncSP_Category"),
			TEXT(R"(
class AUFuncCategoryActor : AActor
{
	UFUNCTION(Category = "Combat")
	void Attack() { }
}
)"),
			TEXT("Category specifier"));

		// NetMulticast
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UFuncSP_NetMulticast"),
			TEXT(R"(
class AUFuncNetMCActor : AActor
{
	UFUNCTION(NetMulticast)
	void MulticastEffect() { }
}
)"),
			TEXT("NetMulticast specifier"));

		// Server
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UFuncSP_Server"),
			TEXT(R"(
class AUFuncServerActor : AActor
{
	UFUNCTION(Server)
	void ServerDoAction() { }
}
)"),
			TEXT("Server specifier"));

		// Client
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UFuncSP_Client"),
			TEXT(R"(
class AUFuncClientActor : AActor
{
	UFUNCTION(Client)
	void ClientReceiveData() { }
}
)"),
			TEXT("Client specifier"));

		// Multiple specifiers
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UFuncSP_Multiple"),
			TEXT(R"(
class AUFuncMultiSpecActor : AActor
{
	UFUNCTION(BlueprintCallable, Category = "Movement")
	void MoveForward() { }
}
)"),
			TEXT("Multiple specifiers combined"));

		// Return type
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UFuncSP_Return"),
			TEXT(R"(
class AUFuncReturnActor : AActor
{
	UFUNCTION(BlueprintCallable)
	int GetScore() { return 42; }
}
)"),
			TEXT("UFUNCTION with return type"));

		// Parameters
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UFuncSP_Params"),
			TEXT(R"(
class AUFuncParamsActor : AActor
{
	UFUNCTION(BlueprintCallable)
	void SetHealth(int NewHealth, bool bNotify) { }
}
)"),
			TEXT("UFUNCTION with parameters"));
	}

	// ====================================================================
	// Specifiers — Negative
	// ====================================================================

	TEST_METHOD(Specifiers_Negative)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		// Invalid specifier
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UFuncSN_Invalid"),
			TEXT(R"(
class AUFuncInvalidActor : AActor
{
	UFUNCTION(InvalidSpecifier)
	void Foo() { }
}
)"),
			TEXT("Invalid specifier should fail"));

		// UFUNCTION at global scope
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UFuncSN_GlobalScope"),
			TEXT(R"(
UFUNCTION() void GlobalFunc() { }
)"),
			TEXT("UFUNCTION at global scope should fail"));

		// Conflicting Server + Client
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UFuncSN_ConflictServerClient"),
			TEXT(R"(
class AUFuncSvrCliActor : AActor
{
	UFUNCTION(Server, Client)
	void Foo() { }
}
)"),
			TEXT("Conflicting Server and Client should fail"));

		// UFUNCTION on property
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UFuncSN_OnProperty"),
			TEXT(R"(
class AUFuncOnPropActor : AActor
{
	UFUNCTION()
	int X = 0;
}
)"),
			TEXT("UFUNCTION on property should fail"));

		// Missing parenthesis
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UFuncSN_MissingParen"),
			TEXT(R"(
class AUFuncMisParenActor : AActor
{
	UFUNCTION( void Foo() { }
}
)"),
			TEXT("Missing closing parenthesis should fail"));

		// Duplicate specifier
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UFuncSN_DuplicateSpec"),
			TEXT(R"(
class AUFuncDupSpecActor : AActor
{
	UFUNCTION(BlueprintCallable, BlueprintCallable)
	void Foo() { }
}
)"),
			TEXT("Duplicate specifier should fail"));

		// BlueprintEvent with non-void return
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UFuncSN_BPEventNonVoid"),
			TEXT(R"(
class AUFuncBPEvNVActor : AActor
{
	UFUNCTION(BlueprintEvent)
	int GetVal() { return 0; }
}
)"),
			TEXT("BlueprintEvent with non-void return should fail"));

		// Specifier typo / case sensitivity
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UFuncSN_CaseSensitive"),
			TEXT(R"(
class AUFuncCaseActor : AActor
{
	UFUNCTION(blueprintcallable)
	void Foo() { }
}
)"),
			TEXT("Lowercase specifier (case sensitivity) should fail"));

		// Trailing garbage after UFUNCTION
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UFuncSN_TrailingGarbage"),
			TEXT(R"(
class AUFuncGarbageActor : AActor
{
	UFUNCTION() garbage void Foo() { }
}
)"),
			TEXT("Trailing garbage after UFUNCTION should fail"));

		// Conflicting Server + NetMulticast
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UFuncSN_ConflictServerMulticast"),
			TEXT(R"(
class AUFuncSvrMCActor : AActor
{
	UFUNCTION(Server, NetMulticast)
	void Foo() { }
}
)"),
			TEXT("Conflicting Server and NetMulticast should fail"));

		// Numeric literal as specifier
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UFuncSN_NumberSpec"),
			TEXT(R"(
class AUFuncNumSpecActor : AActor
{
	UFUNCTION(999)
	void Foo() { }
}
)"),
			TEXT("Numeric literal as specifier should fail"));

		// Empty specifier with lone comma
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UFuncSN_EmptyComma"),
			TEXT(R"(
class AUFuncEmptyCommaActor : AActor
{
	UFUNCTION(,)
	void Foo() { }
}
)"),
			TEXT("Empty specifier with lone comma should fail"));

		// BlueprintPure on non-const void function
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UFuncSN_PureNonConst"),
			TEXT(R"(
class AUFuncPureNCActr : AActor
{
	UFUNCTION(BlueprintPure)
	void Mutate() { }
}
)"),
			TEXT("BlueprintPure on non-const void function should fail"));

		// UFUNCTION on constructor
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UFuncSN_Constructor"),
			TEXT(R"(
class AUFuncCtorActor : AActor
{
	UFUNCTION()
	AUFuncCtorActor() { }
}
)"),
			TEXT("UFUNCTION on constructor should fail"));
	}

	// ====================================================================
	// Parameters — Negative
	// ====================================================================

	TEST_METHOD(Params_Negative)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		// Non-existent parameter type
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UFuncPN_NonExistentType"),
			TEXT(R"(
class AUFuncPNBadTypeActor : AActor
{
	UFUNCTION()
	void Foo(FNonExistentType Param) { }
}
)"),
			TEXT("Non-existent parameter type should fail"));

		// void parameter
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UFuncPN_VoidParam"),
			TEXT(R"(
class AUFuncPNVoidActor : AActor
{
	UFUNCTION()
	void Foo(void Param) { }
}
)"),
			TEXT("void parameter type should fail"));

		// Duplicate parameter names
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UFuncPN_DuplicateNames"),
			TEXT(R"(
class AUFuncPNDupNameActor : AActor
{
	UFUNCTION()
	void Foo(int X, float X) { }
}
)"),
			TEXT("Duplicate parameter names should fail"));

		// auto parameter type
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UFuncPN_AutoParam"),
			TEXT(R"(
class AUFuncPNAutoActor : AActor
{
	UFUNCTION()
	void Foo(auto X) { }
}
)"),
			TEXT("auto parameter type should fail"));

		// Reference to non-existent type
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UFuncPN_RefBadType"),
			TEXT(R"(
class AUFuncPNRefBadActor : AActor
{
	UFUNCTION()
	void Foo(FNonExistent& Ref) { }
}
)"),
			TEXT("Reference to non-existent type should fail"));

		// TArray with non-existent element type in param
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UFuncPN_TArrayBadElem"),
			TEXT(R"(
class AUFuncPNArrBadActor : AActor
{
	UFUNCTION()
	void Foo(TArray<FBogus> Items) { }
}
)"),
			TEXT("TArray param with non-existent element type should fail"));

		// Non-existent return type
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UFuncPN_BadReturnType"),
			TEXT(R"(
class AUFuncPNBadRetActor : AActor
{
	UFUNCTION()
	FNonExistentType Foo() { }
}
)"),
			TEXT("Non-existent return type should fail"));

		// Missing parameter name
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UFuncPN_NoParamName"),
			TEXT(R"(
class AUFuncPNNoNameActor : AActor
{
	UFUNCTION()
	void Foo(int) { }
}
)"),
			TEXT("Parameter without name should fail"));

		// Keyword as parameter name
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UFuncPN_KeywordName"),
			TEXT(R"(
class AUFuncPNKeywordActor : AActor
{
	UFUNCTION()
	void Foo(int class) { }
}
)"),
			TEXT("Keyword as parameter name should fail"));

		// Function pointer parameter type
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UFuncPN_FuncPtrParam"),
			TEXT(R"(
class AUFuncPNFuncPtrActor : AActor
{
	UFUNCTION()
	void Foo(void() Callback) { }
}
)"),
			TEXT("Function pointer parameter type should fail"));

		// TSubclassOf with non-UObject in param
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UFuncPN_SubclassNonObj"),
			TEXT(R"(
class AUFuncPNSubNonObjActor : AActor
{
	UFUNCTION()
	void Foo(TSubclassOf<int> C) { }
}
)"),
			TEXT("TSubclassOf with non-UObject param type should fail"));

		// Three parameters with same name
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UFuncPN_TripleDupName"),
			TEXT(R"(
class AUFuncPNTripleDupActor : AActor
{
	UFUNCTION()
	void Foo(int A, int A, int A) { }
}
)"),
			TEXT("Three parameters with same name should fail"));
	}
};

#endif // WITH_DEV_AUTOMATION_TESTS
