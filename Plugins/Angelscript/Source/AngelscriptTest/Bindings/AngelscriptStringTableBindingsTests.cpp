#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"
#include "../Shared/AngelscriptTestEngineHelper.h"

#include "Internationalization/StringTableCore.h"
#include "Internationalization/StringTableRegistry.h"
#include "Misc/AutomationTest.h"
#include "Misc/Guid.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptStringTableRegistryLocTableCompatBindingsTest,
	"Angelscript.TestModule.Bindings.StringTableRegistryLocTableCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Bindings_AngelscriptStringTableBindingsTests_Private
{
	static constexpr ANSICHAR StringTableBindingsModuleName[] = "ASStringTableRegistryLocTableCompat";
	static const FString EntryFunctionDecl(TEXT("int Entry()"));
	static const FString GreetingKeyString(TEXT("Greeting"));
	static const FTextKey GreetingKey(TEXT("Greeting"));
	static const FName CommentMetaDataId(TEXT("Comment"));
	static const FString ExpectedNamespace(TEXT("AS.Test.Namespace"));
	static const FString ExpectedGreeting(TEXT("Hello"));
	static const FString ExpectedComment(TEXT("Doc"));

	FName MakeUniqueStringTableId()
	{
		return FName(*FString::Printf(
			TEXT("Angelscript.Test.StringTable.%s"),
			*FGuid::NewGuid().ToString(EGuidFormats::Digits)));
	}

	void UnregisterStringTableIfPresent(const FName TableId)
	{
		FStringTableRegistry::Get().UnregisterStringTable(TableId);
	}

	FString BuildScriptSource(const FName TableId)
	{
		FString ScriptSource = TEXT(R"(
int Entry()
{
	const FName TableId = n"__TABLE_ID__";
	LOCTABLE_NEW(TableId, "__TABLE_NAMESPACE__");
	LOCTABLE_SETSTRING(TableId, "__GREETING_KEY__", "__GREETING_VALUE__");
	LOCTABLE_SETMETA(TableId, "__GREETING_KEY__", n"__COMMENT_META_ID__", "__COMMENT_VALUE__");

	FText Greeting = LOCTABLE(TableId, "__GREETING_KEY__");
	if (Greeting.IsEmpty())
		return 10;
	if (Greeting.ToString() != "__GREETING_VALUE__")
		return 20;

	return 1;
}
)");

		ScriptSource.ReplaceInline(TEXT("__TABLE_ID__"), *TableId.ToString(), ESearchCase::CaseSensitive);
		ScriptSource.ReplaceInline(TEXT("__TABLE_NAMESPACE__"), *ExpectedNamespace, ESearchCase::CaseSensitive);
		ScriptSource.ReplaceInline(TEXT("__GREETING_KEY__"), *GreetingKeyString, ESearchCase::CaseSensitive);
		ScriptSource.ReplaceInline(TEXT("__GREETING_VALUE__"), *ExpectedGreeting, ESearchCase::CaseSensitive);
		ScriptSource.ReplaceInline(TEXT("__COMMENT_META_ID__"), *CommentMetaDataId.ToString(), ESearchCase::CaseSensitive);
		ScriptSource.ReplaceInline(TEXT("__COMMENT_VALUE__"), *ExpectedComment, ESearchCase::CaseSensitive);
		return ScriptSource;
	}

	asIScriptModule* BuildLocTableModule(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const FName TableId)
	{
		return BuildModule(
			Test,
			Engine,
			StringTableBindingsModuleName,
			BuildScriptSource(TableId));
	}

	bool ExecuteEntryFunction(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		asIScriptModule& Module)
	{
		asIScriptFunction* EntryFunction = GetFunctionByDecl(Test, Module, EntryFunctionDecl);
		if (EntryFunction == nullptr)
		{
			return false;
		}

		int32 ScriptResult = INDEX_NONE;
		if (!ExecuteIntFunction(Test, Engine, *EntryFunction, ScriptResult))
		{
			return false;
		}

		return Test.TestEqual(
			TEXT("String-table LOCTABLE scenario should read back the expected localized text inside script"),
			ScriptResult,
			1);
	}

	bool VerifyRegisteredStringTable(
		FAutomationTestBase& Test,
		const FName TableId)
	{
		FStringTableConstPtr StringTable = FStringTableRegistry::Get().FindStringTable(TableId);
		if (!Test.TestNotNull(
				TEXT("String-table LOCTABLE scenario should register the in-memory string table in FStringTableRegistry"),
				StringTable.Get()))
		{
			return false;
		}

		FString SourceString;
		const bool bHasSourceString = StringTable->GetSourceString(GreetingKey, SourceString);
		const bool bSourceMatched =
			Test.TestTrue(
				TEXT("String-table LOCTABLE scenario should keep the Greeting source string addressable in the registry"),
				bHasSourceString) &&
			Test.TestEqual(
				TEXT("String-table LOCTABLE scenario should preserve the Greeting source string contents"),
				SourceString,
				ExpectedGreeting);

		const FString MetaData = StringTable->GetMetaData(GreetingKey, CommentMetaDataId);
		const bool bMetaDataMatched = Test.TestEqual(
			TEXT("String-table LOCTABLE scenario should preserve the Greeting metadata payload"),
			MetaData,
			ExpectedComment);

		return bSourceMatched && bMetaDataMatched;
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptStringTableBindingsTests_Private;

bool FAngelscriptStringTableRegistryLocTableCompatBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	const FName TableId = MakeUniqueStringTableId();
	bool bModuleDiscarded = false;
	ON_SCOPE_EXIT
	{
		if (!bModuleDiscarded)
		{
			Engine.DiscardModule(UTF8_TO_TCHAR(StringTableBindingsModuleName));
		}

		UnregisterStringTableIfPresent(TableId);
	};

	UnregisterStringTableIfPresent(TableId);

	asIScriptModule* Module = BuildLocTableModule(*this, Engine, TableId);
	if (Module == nullptr)
	{
		return false;
	}

	if (!ExecuteEntryFunction(*this, Engine, *Module))
	{
		return false;
	}

	bPassed &= VerifyRegisteredStringTable(*this, TableId);

	Engine.DiscardModule(UTF8_TO_TCHAR(StringTableBindingsModuleName));
	bModuleDiscarded = true;

	bPassed &= TestNotNull(
		TEXT("String-table LOCTABLE scenario should keep the registered string table alive until explicit registry cleanup"),
		FStringTableRegistry::Get().FindStringTable(TableId).Get());

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
