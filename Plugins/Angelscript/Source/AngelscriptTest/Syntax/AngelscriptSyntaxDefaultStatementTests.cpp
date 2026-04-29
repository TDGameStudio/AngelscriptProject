// ============================================================================
// AngelscriptSyntaxDefaultStatementTests.cpp
//
// Syntax coverage tests for default statements: attribute defaults in class
// bodies and function parameter defaults — CQTest refactor.
//
// Automation prefix: Angelscript.TestModule.Syntax.DefaultStatement.*
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

static const FBindingsCoverageProfile GSyntaxDefaultStatementProfile{
	TEXT("Syntax"),           // Theme
	TEXT("DefStmt"),          // Variant
	TEXT("ASSyntaxDS"),       // ModulePrefix
	TEXT("DefStmt"),          // CasePrefix
	TEXT("SyntaxDefStmt"),    // LogCategory
};

// ----------------------------------------------------------------------------
// Test class
// ----------------------------------------------------------------------------

TEST_CLASS_WITH_FLAGS(FAngelscriptSyntaxDefaultStatementTest,
	"Angelscript.TestModule.Syntax.DefaultStatement",
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
	// Attribute Defaults — Positive
	// ====================================================================

	TEST_METHOD(AttributeDefault_Positive)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxDS_AttrBool"),
			TEXT("class AAttrBoolActor : AActor { UPROPERTY() bool bEnabled = true; default bEnabled = false; }"),
			TEXT("Default statement for bool property"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxDS_AttrInt"),
			TEXT("class AAttrIntActor : AActor { UPROPERTY() int Health = 0; default Health = 100; }"),
			TEXT("Default statement for int property"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxDS_AttrReplicated"),
			TEXT("class AAttrRepActor : AActor { UPROPERTY(Replicated) bool bReplicates = false; default bReplicates = true; }"),
			TEXT("Default statement for replicated property"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxDS_AttrInherited"),
			TEXT("class AMyPawn : APawn { default bReplicates = true; }"),
			TEXT("Default statement for inherited property"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxDS_AttrMultiple"),
			TEXT("class AAttrMultiActor : AActor { UPROPERTY() int X = 0; UPROPERTY() int Y = 0; default X = 10; default Y = 20; }"),
			TEXT("Multiple default statements"));
	}

	// ====================================================================
	// Attribute Defaults — Negative
	// ====================================================================

	TEST_METHOD(AttributeDefault_Negative)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxDS_AttrNonExist"),
			TEXT("class AAttrNonExistActor : AActor { default NonExistentProp = 42; }"),
			TEXT("Default on non-existent property should fail"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxDS_AttrTypeMismatch"),
			TEXT("class AAttrTypeMismatchActor : AActor { UPROPERTY() int Health = 0; default Health = \"hello\"; }"),
			TEXT("Default with type mismatch should fail"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxDS_AttrGlobal"),
			TEXT("default SomeVar = 5;"),
			TEXT("Default statement at global scope should fail"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxDS_AttrNoSemicolon"),
			TEXT("class AAttrNoSemiActor : AActor { UPROPERTY() int X = 0; default X = 5 }"),
			TEXT("Default without semicolon should fail"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxDS_AttrNoValue"),
			TEXT("class AAttrNoValActor : AActor { UPROPERTY() int X = 0; default X; }"),
			TEXT("Default without value should fail"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxDS_AttrOnMethod"),
			TEXT("class AAttrOnMethodActor : AActor { UFUNCTION() void Foo() {} default Foo = 0; }"),
			TEXT("Default on method should fail"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxDS_AttrDuplicate"),
			TEXT("class AAttrDupActor : AActor { UPROPERTY() int X = 0; default X = 5; default X = 10; }"),
			TEXT("Duplicate default for same property should fail"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxDS_AttrInStruct"),
			TEXT("struct FAttrStruct { int X = 0; default X = 5; }"),
			TEXT("Default statement in struct should fail"));
	}

	// ====================================================================
	// Function Parameter Defaults — Positive
	// ====================================================================

	TEST_METHOD(ParamDefault_Positive)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxDS_ParamInt"),
			TEXT("void Foo(int X = 5) { }"),
			TEXT("Function parameter default int"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxDS_ParamFloat"),
			TEXT("void Foo(float X = 1.0f) { }"),
			TEXT("Function parameter default float"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxDS_ParamBool"),
			TEXT("void Foo(bool bEnable = true) { }"),
			TEXT("Function parameter default bool"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxDS_ParamString"),
			TEXT("void Foo(FString Name = \"Default\") { }"),
			TEXT("Function parameter default string"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxDS_ParamMulti"),
			TEXT("void Foo(int X = 1, float Y = 2.0f, bool bZ = false) { }"),
			TEXT("Multiple parameter defaults"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxDS_ParamCallDefault"),
			TEXT("void Foo(int X = 5) { } void Test() { Foo(); Foo(10); }"),
			TEXT("Calling with and without default parameter"));
	}

	// ====================================================================
	// Function Parameter Defaults — Negative
	// ====================================================================

	TEST_METHOD(ParamDefault_Negative)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxDS_ParamOrder"),
			TEXT("void Foo(int X = 5, int Y) { }"),
			TEXT("Non-default param after default should fail"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxDS_ParamTypeMismatch"),
			TEXT("void Foo(int X = \"hello\") { }"),
			TEXT("Default param type mismatch should fail"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxDS_ParamExprDefault"),
			TEXT("int GlobalVal = 5; void Foo(int X = GlobalVal + 1) { }"),
			TEXT("Non-constant expression as default should fail"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxDS_ParamNonConst"),
			TEXT("int GlobalVal = 5; void Foo(int X = GlobalVal) { }"),
			TEXT("Non-const variable as default should fail"));
	}
};

#endif // WITH_DEV_AUTOMATION_TESTS
