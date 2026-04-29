// ============================================================================
// AngelscriptSyntaxTypeDeclarationTests.cpp
//
// Syntax coverage tests for type declarations — CQTest refactor.
// Tests class, struct, enum, interface, namespace, variable, and function
// declarations.
//
// Automation prefix: Angelscript.TestModule.Syntax.TypeDeclaration.*
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

static const FBindingsCoverageProfile GSyntaxTypeDeclProfile{
	TEXT("Syntax"),          // Theme
	TEXT("TypeDecl"),        // Variant
	TEXT("ASSyntaxTD"),      // ModulePrefix
	TEXT("TypeDecl"),        // CasePrefix
	TEXT("SyntaxTypeDecl"),  // LogCategory
};

// ----------------------------------------------------------------------------
// Test class
// ----------------------------------------------------------------------------

TEST_CLASS_WITH_FLAGS(FAngelscriptSyntaxTypeDeclarationTest,
	"Angelscript.TestModule.Syntax.TypeDeclaration",
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
	// Class — Positive
	// ====================================================================

	TEST_METHOD(Class_Positive)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ClassP_Basic"),
			TEXT("class AClassBasicActor : AActor { }"), TEXT("Basic class"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ClassP_Members"),
			TEXT("class AClassMembersActor : AActor { int Health = 100; float Speed = 5.0f; }"), TEXT("Class with members"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ClassP_Methods"),
			TEXT("class AClassMethodsActor : AActor { void Foo() { } int Bar() { return 1; } }"), TEXT("Class with methods"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ClassP_UCLASS"),
			TEXT("UCLASS() class AClassUCLASSActor : AActor { UPROPERTY() int X = 0; }"), TEXT("UCLASS with UPROPERTY"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ClassP_Abstract"),
			TEXT("UCLASS(Abstract) class AMyAbstract : AActor { }"), TEXT("Abstract UCLASS"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ClassP_Constructor"),
			TEXT("class AClassCtorActor : AActor { int X; AClassCtorActor() { X = 10; } }"), TEXT("Constructor"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ClassP_Chain"),
			TEXT("class ABaseChainActor : AActor { } class AChildChainActor : ABaseChainActor { }"), TEXT("Inheritance chain"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ClassP_Final"),
			TEXT("class AFinalClassActor : AActor final { }"), TEXT("Final class"));
	}

	// ====================================================================
	// Class — Negative
	// ====================================================================

	TEST_METHOD(Class_Negative)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ClassN_NoName"),
			TEXT("class : AActor { }"), TEXT("Class without name"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ClassN_NoBrace"),
			TEXT("class AClassNoBraceActor : AActor"), TEXT("Class without braces"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ClassN_Duplicate"),
			TEXT("class ADupActor : AActor { } class ADupActor : AActor { }"), TEXT("Duplicate class name"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ClassN_BadParent"),
			TEXT("class AClassBadParentActor : ANonExistentActor { }"), TEXT("Non-existent parent"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ClassN_BadMember"),
			TEXT("class AClassBadMemberActor : AActor { NonExistentType X; }"), TEXT("Invalid member type"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ClassN_BadPrefix"),
			TEXT("class MyActor : AActor { }"), TEXT("Actor without A prefix"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ClassN_MultiBase"),
			TEXT("class AClassMultiBaseActor : AActor, APawn { }"), TEXT("Multiple base classes"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ClassN_InheritFinal"),
			TEXT("class AFinalInheritActor : AActor final { } class AChildInheritActor : AFinalInheritActor { }"), TEXT("Inherit from final"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ClassN_SelfInherit"),
			TEXT("class ASelfActor : ASelfActor { }"), TEXT("Self-inheritance"));
	}

	// ====================================================================
	// Struct — Positive
	// ====================================================================

	TEST_METHOD(Struct_Positive)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("StructP_Basic"),
			TEXT("struct FStructBasic { int X; float Y; }"), TEXT("Basic struct"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("StructP_USTRUCT"),
			TEXT("USTRUCT() struct FStructUSTRUCT { UPROPERTY() int X = 0; }"), TEXT("USTRUCT"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("StructP_Methods"),
			TEXT("struct FStructMethods { int X = 0; int GetX() const { return X; } }"), TEXT("Struct with methods"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("StructP_Defaults"),
			TEXT("struct FStructDefaults { int X = 42; FString Name = \"Default\"; }"), TEXT("Struct defaults"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("StructP_Constructor"),
			TEXT("struct FStructCtor { int X; FStructCtor() { X = 0; } FStructCtor(int InX) { X = InX; } }"), TEXT("Constructors"));
	}

	// ====================================================================
	// Struct — Negative
	// ====================================================================

	TEST_METHOD(Struct_Negative)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("StructN_NoName"),
			TEXT("struct { int X; }"), TEXT("Struct without name"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("StructN_Duplicate"),
			TEXT("struct FDup { int X; } struct FDup { int Y; }"), TEXT("Duplicate struct"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("StructN_BadMember"),
			TEXT("struct FStructBadMember { NonExistentType X; }"), TEXT("Invalid member type"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("StructN_BadPrefix"),
			TEXT("USTRUCT() struct MyStruct { UPROPERTY() int X; }"), TEXT("USTRUCT without F prefix"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("StructN_Inherit"),
			TEXT("struct FBase { int X; } struct FChild : FBase { int Y; }"), TEXT("Struct inheritance"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("StructN_VoidMember"),
			TEXT("struct FStructVoidMember { void X; }"), TEXT("Void member"));
	}

	// ====================================================================
	// Enum — Positive
	// ====================================================================

	TEST_METHOD(Enum_Positive)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("EnumP_Basic"),
			TEXT("enum EEnumBasic { Value1, Value2, Value3 }"), TEXT("Basic enum"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("EnumP_UENUM"),
			TEXT("UENUM() enum EEnumUENUM { Value1, Value2 }"), TEXT("UENUM"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("EnumP_Explicit"),
			TEXT("enum EEnumExplicit { Value1 = 0, Value2 = 5, Value3 = 10 }"), TEXT("Explicit values"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("EnumP_Usage"),
			TEXT("enum EEnumUsage { Val1, Val2 } void Test() { EEnumUsage E = EEnumUsage::Val1; }"), TEXT("Enum usage"));
	}

	// ====================================================================
	// Enum — Negative
	// ====================================================================

	TEST_METHOD(Enum_Negative)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("EnumN_NoName"),
			TEXT("enum { Value1 }"), TEXT("Enum without name"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("EnumN_DupVal"),
			TEXT("enum EEnumDupVal { Value1, Value1 }"), TEXT("Duplicate enum value"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("EnumN_BadVal"),
			TEXT("enum EEnumBadVal { Value1 = \"hello\" }"), TEXT("Non-integer enum value"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("EnumN_BadPrefix"),
			TEXT("UENUM() enum MyEnum { Value1 }"), TEXT("UENUM without E prefix"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("EnumN_Empty"),
			TEXT("enum EEnumEmpty { }"), TEXT("Empty enum"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("EnumN_Method"),
			TEXT("enum EEnumMethod { Value1; void Foo() { } }"), TEXT("Method in enum"));
	}

	// ====================================================================
	// Interface — Positive and Negative
	// ====================================================================

	TEST_METHOD(Interface_Mixed)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		// Positive
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("IntfP_Basic"),
			TEXT("interface UIntfBasic { void DoSomething(); int GetValue(); }"), TEXT("Basic interface"));

		// Negative
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("IntfN_Member"),
			TEXT("interface UIntfMember { int X; }"), TEXT("Interface with member variable"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("IntfN_Body"),
			TEXT("interface UIntfBody { void DoSomething() { } }"), TEXT("Interface with method body"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("IntfN_NoName"),
			TEXT("interface { void Foo(); }"), TEXT("Interface without name"));
	}

	// ====================================================================
	// Namespace — Positive and Negative
	// ====================================================================

	TEST_METHOD(Namespace_Mixed)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		// Positive
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("NSP_Basic"),
			TEXT("namespace MySpaceBasic { int GlobalVal = 42; }"), TEXT("Basic namespace"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("NSP_Access"),
			TEXT("namespace MySpaceAccess { int GetVal() { return 42; } } void Test() { int X = MySpaceAccess::GetVal(); }"), TEXT("Namespace access"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("NSP_Nested"),
			TEXT("namespace Outer { namespace Inner { int Value = 1; } }"), TEXT("Nested namespaces"));

		// Negative
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("NSN_Anonymous"),
			TEXT("namespace { int X; }"), TEXT("Anonymous namespace"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("NSN_BadAccess"),
			TEXT("namespace MySpaceBadAcc { int X = 1; } void Test() { int Y = MySpaceBadAcc::NonExistent; }"), TEXT("Non-existent member"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("NSN_NotExist"),
			TEXT("void Test() { int X = FakeNamespace::Value; }"), TEXT("Non-existent namespace"));
	}

	// ====================================================================
	// Variable Declarations — Positive and Negative
	// ====================================================================

	TEST_METHOD(Variable_Positive)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		FCoverageModuleScope Mod(*TestRunner, Engine, GSyntaxTypeDeclProfile, TEXT("VarPos"), TEXT(R"(
int Primitives()  { int A = 0; float B = 1.0f; bool C = true; int64 D = 100; return A + int(B) + (C ? 1 : 0) + int(D); }
int ConstVar()    { const int X = 42; return X; }
int AutoVar()     { auto X = 42; return X; }
int RefVar()      { int X = 5; int& Ref = X; Ref = 10; return X; }
)"));
		ASSERT_THAT(IsTrue(Mod.IsValid()));
		auto& M = Mod.GetModule();

		const FExpectedGlobalInt Cases[] = {
			{ TEXT("int Primitives()"), TEXT("primitive types"), 102 },
			{ TEXT("int ConstVar()"),   TEXT("const variable"),   42 },
			{ TEXT("int AutoVar()"),    TEXT("auto inference"),   42 },
			{ TEXT("int RefVar()"),     TEXT("reference var"),    10 },
		};
		ExpectGlobalInts(*TestRunner, Engine, M, GSyntaxTypeDeclProfile, Cases);
	}

	TEST_METHOD(Variable_Negative)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("VarN_BadType"),
			TEXT("void Test() { NonExistentType X; }"), TEXT("Undeclared type"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("VarN_Duplicate"),
			TEXT("void Test() { int X = 1; int X = 2; }"), TEXT("Duplicate variable"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("VarN_AutoNoInit"),
			TEXT("void Test() { auto X; }"), TEXT("Auto without initializer"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("VarN_ConstNoInit"),
			TEXT("void Test() { const int X; }"), TEXT("Const without initializer"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("VarN_BadName"),
			TEXT("void Test() { int 123abc = 0; }"), TEXT("Name starting with number"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("VarN_Keyword"),
			TEXT("void Test() { int class = 0; }"), TEXT("Keyword as variable name"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("VarN_VoidVar"),
			TEXT("void Test() { void X; }"), TEXT("Void variable"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("VarN_UseBefore"),
			TEXT("void Test() { int Y = X; int X = 5; }"), TEXT("Use before declaration"));
	}

	// ====================================================================
	// Function Declarations — Positive and Negative
	// ====================================================================

	TEST_METHOD(Function_Positive)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("FuncP_Void"),
			TEXT("void Foo() { }"), TEXT("Void function"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("FuncP_Return"),
			TEXT("int Add(int A, int B) { return A + B; }"), TEXT("Function with return"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("FuncP_Default"),
			TEXT("int Foo(int X = 5, float Y = 1.0f) { return X; }"), TEXT("Default parameters"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("FuncP_Overload"),
			TEXT("void Foo(int X) { } void Foo(float X) { } void Foo(int X, int Y) { }"), TEXT("Overloading"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("FuncP_Ref"),
			TEXT("void Foo(int& Out) { Out = 42; }"), TEXT("Reference parameter"));

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("FuncP_Const"),
			TEXT("struct FStructFuncConst { int X = 0; int Get() const { return X; } }"), TEXT("Const method"));
	}

	TEST_METHOD(Function_Negative)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("FuncN_NoReturn"),
			TEXT("Foo() { }"), TEXT("No return type"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("FuncN_NoBody"),
			TEXT("void Foo();"), TEXT("No body (non-interface)"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("FuncN_Duplicate"),
			TEXT("void Foo(int X) { } void Foo(int X) { }"), TEXT("Duplicate signature"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("FuncN_BadDefault"),
			TEXT("void Foo(int X = 5, int Y) { }"), TEXT("Non-default after default"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("FuncN_BadReturnType"),
			TEXT("NonExistentType Foo() { }"), TEXT("Non-existent return type"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("FuncN_BadParamType"),
			TEXT("void Foo(NonExistentType X) { }"), TEXT("Non-existent param type"));

		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("FuncN_VoidParam"),
			TEXT("void Foo(void X) { }"), TEXT("Void parameter"));
	}
};

#endif // WITH_DEV_AUTOMATION_TESTS
