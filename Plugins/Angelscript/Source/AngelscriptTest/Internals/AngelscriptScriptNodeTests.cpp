#include "Angelscript/AngelscriptTestSupport.h"
#include "../Shared/AngelscriptTestMacros.h"
#include "Misc/AutomationTest.h"

#include "StartAngelscriptHeaders.h"
#include "source/as_builder.h"
#include "source/as_module.h"
#include "source/as_parser.h"
#include "source/as_scriptcode.h"
#include "source/as_scriptengine.h"
#include "source/as_scriptnode.h"
#include "EndAngelscriptHeaders.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Internals_AngelscriptScriptNodeTests_Private
{
	asCModule* CreateScriptNodeModule(asCScriptEngine* ScriptEngine, const char* ModuleName)
	{
		return static_cast<asCModule*>(ScriptEngine->GetModule(ModuleName, asGM_ALWAYS_CREATE));
	}

	int32 CountDirectChildren(const asCScriptNode* Node)
	{
		int32 Count = 0;
		for (const asCScriptNode* Child = Node != nullptr ? Node->firstChild : nullptr; Child != nullptr; Child = Child->next)
		{
			++Count;
		}
		return Count;
	}
}

using namespace AngelscriptTest_Internals_AngelscriptScriptNodeTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScriptNodeTypeTest,
	"Angelscript.TestModule.Internals.ScriptNode.Types",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScriptNodeTraversalTest,
	"Angelscript.TestModule.Internals.ScriptNode.Traversal",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScriptNodeCopyTest,
	"Angelscript.TestModule.Internals.ScriptNode.Copy",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScriptNodeTypeTest::RunTest(const FString& Parameters)
{
	TestEqual(TEXT("snScript should remain the root script node enum value"), static_cast<int32>(snScript), 1);
	TestTrue(TEXT("snFunction should remain a positive enum value"), static_cast<int32>(snFunction) > 0);
	TestTrue(TEXT("snClass should remain a positive enum value"), static_cast<int32>(snClass) > 0);
	TestTrue(TEXT("snExpression should remain a positive enum value"), static_cast<int32>(snExpression) > 0);
	return true;
}

bool FAngelscriptScriptNodeTraversalTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	asCScriptEngine* ScriptEngine = static_cast<asCScriptEngine*>(Engine.GetScriptEngine());
	asCModule* Module = CreateScriptNodeModule(ScriptEngine, "ScriptNodeTraversal");
	if (!TestNotNull(TEXT("ScriptNode traversal test should create a backing module"), Module))
	{
		return false;
	}

	asCBuilder Builder(ScriptEngine, Module);
	asCScriptCode Code;
	Code.SetCode("ScriptNodeTraversal", "int GlobalValue = 1; class FNodeType { int Value; }", true);

	asCParser Parser(&Builder);
	if (!TestEqual(TEXT("ScriptNode traversal parser run should succeed"), Parser.ParseScript(&Code), 0))
	{
		return false;
	}

	asCScriptNode* Root = Parser.GetScriptNode();
	if (!TestNotNull(TEXT("ScriptNode traversal should produce a root node"), Root))
	{
		return false;
	}

	TestEqual(TEXT("Root should be a script node"), static_cast<int32>(Root->nodeType), static_cast<int32>(snScript));
	TestEqual(TEXT("Two top-level declarations should produce two direct children"), CountDirectChildren(Root), 2);
	TestNotNull(TEXT("Root should expose the first child"), Root->firstChild);
	TestNotNull(TEXT("Root should expose the last child"), Root->lastChild);
	TestTrue(TEXT("First and last child should differ when multiple declarations exist"), Root->firstChild != Root->lastChild);
	TestEqual(TEXT("Second child should point back to the first child as prev"), Root->lastChild->prev, Root->firstChild);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScriptNodeCopyTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	asCScriptEngine* ScriptEngine = static_cast<asCScriptEngine*>(Engine.GetScriptEngine());
	asCModule* Module = CreateScriptNodeModule(ScriptEngine, "ScriptNodeCopy");
	if (!TestNotNull(TEXT("ScriptNode copy test should create a backing module"), Module))
	{
		return false;
	}

	asCBuilder Builder(ScriptEngine, Module);
	asCScriptCode Code;
	Code.SetCode("ScriptNodeCopy", "int Value = 3;", true);

	asCParser Parser(&Builder);
	if (!TestEqual(TEXT("ScriptNode copy parser run should succeed"), Parser.ParseScript(&Code), 0))
	{
		return false;
	}

	asCScriptNode* Root = Parser.GetScriptNode();
	if (!TestNotNull(TEXT("ScriptNode copy test should produce a root node"), Root))
	{
		return false;
	}

	asCScriptNode* Copy = Root->CreateCopy(Parser.MemStack, ScriptEngine);
	if (!TestNotNull(TEXT("CreateCopy should produce a duplicate node tree"), Copy))
	{
		return false;
	}

	TestEqual(TEXT("Copied root should keep the same node type"), static_cast<int32>(Copy->nodeType), static_cast<int32>(Root->nodeType));
	TestTrue(TEXT("Copied node should be a different instance"), Copy != Root);
	TestTrue(TEXT("Copied first child should be a different instance"), Copy->firstChild != nullptr && Copy->firstChild != Root->firstChild);
	ASTEST_END_SHARE_CLEAN

	return true;
}

#endif
