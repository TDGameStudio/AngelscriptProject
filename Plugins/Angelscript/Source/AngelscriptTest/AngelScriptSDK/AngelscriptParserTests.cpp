#include "Shared/AngelscriptTestMacros.h"
#include "CQTest.h"

#include "StartAngelscriptHeaders.h"
#include "source/as_builder.h"
#include "source/as_module.h"
#include "source/as_parser.h"
#include "source/as_scriptcode.h"
#include "source/as_scriptengine.h"
#include "source/as_scriptnode.h"
#include "EndAngelscriptHeaders.h"

#if WITH_DEV_AUTOMATION_TESTS

	namespace
	{
		struct FParserAccessor : asCParser
		{
			explicit FParserAccessor(asCBuilder* Builder)
				: asCParser(Builder)
			{
			}

			void ResetParser()
			{
				Reset();
			}

			int ParseScriptSnippetWithoutImplicitReset(asCScriptCode* InScript)
			{
				script = InScript;
				scriptNode = asCParser::ParseScript(false);
				return errorWhileParsing ? -1 : 0;
			}

			asCScriptNode* ParseExpressionSnippet(asCScriptCode* InScript)
			{
				Reset();
				script = InScript;
				return ParseExpression();
			}

			asCScriptNode* ParseStatementSnippet(asCScriptCode* InScript)
			{
				Reset();
				script = InScript;
				return ParseStatement();
			}
		};

		bool ContainsNodeType(const asCScriptNode* Node, eScriptNode ExpectedType)
		{
			for (const asCScriptNode* Current = Node; Current != nullptr; Current = Current->next)
			{
				if (Current->nodeType == ExpectedType)
				{
					return true;
				}

				if (Current->firstChild != nullptr && ContainsNodeType(Current->firstChild, ExpectedType))
				{
					return true;
				}
			}

			return false;
		}

	asCModule* CreateParserModule(asCScriptEngine* ScriptEngine, const char* ModuleName)
	{
		return static_cast<asCModule*>(ScriptEngine->GetModule(ModuleName, asGM_ALWAYS_CREATE));
	}
}

TEST_CLASS_WITH_FLAGS(FAngelscriptParserTests,
	"Angelscript.TestModule.AngelScriptSDK.Parser",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(Declarations)
	{
		asCScriptEngine* BareEngine = ASTEST_CREATE_ENGINE_BARE();
		ASTEST_BEGIN_BARE
		asCModule* Module = CreateParserModule(BareEngine, "ParserDeclarations");
		if (!TestNotNull(TEXT("Parser declaration test should create a backing module"), Module))
		{
			return;
		}

		asCBuilder Builder(BareEngine, Module);
		asCScriptCode Code;
		Code.SetCode("ParserDeclarations", "int GlobalValue = 7; class FSample { int Value; }", true);

		asCParser Parser(&Builder);
		const int ParseResult = Parser.ParseScript(&Code);
		if (!TestEqual(TEXT("Parser should successfully parse declarations"), ParseResult, 0))
		{
			return;
		}

		asCScriptNode* Root = Parser.GetScriptNode();
		if (!TestNotNull(TEXT("Parser should produce a root script node"), Root))
		{
			return;
		}

		TestEqual(TEXT("Root node should be a script node"), static_cast<int32>(Root->nodeType), static_cast<int32>(snScript));
		TestTrue(TEXT("Parser should emit a declaration node for the global variable"), ContainsNodeType(Root, snDeclaration));
		TestTrue(TEXT("Parser should emit a class node for the class declaration"), ContainsNodeType(Root, snClass));
		ASTEST_END_BARE
	}

	TEST_METHOD(ExpressionAst)
	{
		asCScriptEngine* BareEngine = ASTEST_CREATE_ENGINE_BARE();
		ASTEST_BEGIN_BARE
		asCModule* Module = CreateParserModule(BareEngine, "ParserExpressions");
		if (!TestNotNull(TEXT("Parser expression test should create a backing module"), Module))
		{
			return;
		}

		asCBuilder Builder(BareEngine, Module);
		asCScriptCode Code;
		Code.SetCode("ParserExpressions", "1 + 2 * 3", true);

		FParserAccessor Parser(&Builder);
		asCScriptNode* Root = Parser.ParseExpressionSnippet(&Code);
		if (!TestNotNull(TEXT("Parser should produce an AST for expression input"), Root))
		{
			return;
		}

		TestEqual(TEXT("Expression root should be an expression node"), static_cast<int32>(Root->nodeType), static_cast<int32>(snExpression));
		TestTrue(TEXT("Parser should emit an expression operator node"), ContainsNodeType(Root, snExprOperator));
		ASTEST_END_BARE
	}

	TEST_METHOD(ControlFlow)
	{
		asCScriptEngine* BareEngine = ASTEST_CREATE_ENGINE_BARE();
		ASTEST_BEGIN_BARE
		asCModule* Module = CreateParserModule(BareEngine, "ParserControlFlow");
		if (!TestNotNull(TEXT("Parser control-flow test should create a backing module"), Module))
		{
			return;
		}

		asCBuilder Builder(BareEngine, Module);
		asCScriptCode Code;
		Code.SetCode("ParserControlFlow", "if (true) { for (int i = 0; i < 3; i++) { while(false) { } } }", true);

		FParserAccessor Parser(&Builder);
		asCScriptNode* Root = Parser.ParseStatementSnippet(&Code);
		if (!TestNotNull(TEXT("Parser should produce an AST for control flow input"), Root))
		{
			return;
		}

		TestEqual(TEXT("Control-flow root should be an if node"), static_cast<int32>(Root->nodeType), static_cast<int32>(snIf));
		TestTrue(TEXT("Parser should emit an if node"), ContainsNodeType(Root, snIf));
		TestTrue(TEXT("Parser should emit a for node"), ContainsNodeType(Root, snFor));
		TestTrue(TEXT("Parser should emit a while node"), ContainsNodeType(Root, snWhile));
		ASTEST_END_BARE
	}

	TEST_METHOD(SyntaxErrors)
	{
		asCScriptEngine* BareEngine = ASTEST_CREATE_ENGINE_BARE();
		ASTEST_BEGIN_BARE
		asCModule* Module = CreateParserModule(BareEngine, "ParserSyntaxErrors");
		if (!TestNotNull(TEXT("Parser syntax-error test should create a backing module"), Module))
		{
			return;
		}

		asCBuilder Builder(BareEngine, Module);
		Builder.silent = true;
		asCScriptCode Code;
		Code.SetCode("ParserSyntaxErrors", "void Broken( { return; }", true);

		asCParser Parser(&Builder);
		const int ParseResult = Parser.ParseScript(&Code);
		TestTrue(TEXT("Parser should reject malformed syntax"), ParseResult < 0);
		ASTEST_END_BARE
	}

	TEST_METHOD(ReuseAfterSyntaxError)
	{
		asCScriptEngine* BareEngine = ASTEST_CREATE_ENGINE_BARE();
		ASTEST_BEGIN_BARE
		asCModule* Module = CreateParserModule(BareEngine, "ParserReuseAfterSyntaxError");
		if (!TestNotNull(TEXT("Parser reuse-after-error test should create a backing module"), Module))
		{
			return;
		}

		asCBuilder Builder(BareEngine, Module);
		Builder.silent = true;

		asCScriptCode InvalidCode;
		InvalidCode.SetCode("ParserReuseAfterSyntaxError_Invalid", "void Broken( { return; }", true);

		asCScriptCode ValidCode;
		ValidCode.SetCode("ParserReuseAfterSyntaxError_Valid", "int GlobalValue = 7; class FRecoveredSample { int Value; }", true);

		FParserAccessor Parser(&Builder);
		const int InvalidParseResult = Parser.ParseScriptSnippetWithoutImplicitReset(&InvalidCode);
		TestTrue(
			TEXT("Parser.ReuseAfterSyntaxError should fail the malformed script on the first parse"),
			InvalidParseResult < 0);

		Parser.ResetParser();

		const int ValidParseResult = Parser.ParseScriptSnippetWithoutImplicitReset(&ValidCode);
		TestEqual(
			TEXT("Parser.ReuseAfterSyntaxError should succeed when the same parser is reused on valid script after Reset"),
			ValidParseResult,
			0);

		asCScriptNode* Root = Parser.GetScriptNode();
		if (!TestNotNull(TEXT("Parser.ReuseAfterSyntaxError should produce a root node for the recovered parse"), Root))
		{
			return;
		}

		TestEqual(
			TEXT("Parser.ReuseAfterSyntaxError should recover a script root node after Reset"),
			static_cast<int32>(Root->nodeType),
			static_cast<int32>(snScript));
		TestTrue(
			TEXT("Parser.ReuseAfterSyntaxError should recover a declaration node after Reset"),
			ContainsNodeType(Root, snDeclaration));
		TestTrue(
			TEXT("Parser.ReuseAfterSyntaxError should recover a class node after Reset"),
			ContainsNodeType(Root, snClass));

		ASTEST_END_BARE
	}
};

#endif
