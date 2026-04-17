#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Bindings_AngelscriptTextFormattingBindingsTests_Private
{
	struct FTextFormattingExpectations
	{
		FString OrderedExpected;
		FString NamedExpected;
	};

	FTextFormattingExpectations BuildTextFormattingExpectations()
	{
		const FText OrderedPattern = FText::FromString(TEXT("{0}|{1}|{2}|{3}|{4}|{5}|{6}"));
		FFormatOrderedArguments OrderedArguments;
		OrderedArguments.Add(FFormatArgumentValue(int32(-7)));
		OrderedArguments.Add(FFormatArgumentValue(uint32(42)));
		OrderedArguments.Add(FFormatArgumentValue(int64(9000000000ll)));
		OrderedArguments.Add(FFormatArgumentValue(uint64(15)));
		OrderedArguments.Add(FFormatArgumentValue(float(3.25f)));
		OrderedArguments.Add(FFormatArgumentValue(double(6.5)));
		OrderedArguments.Add(FFormatArgumentValue(FText::FromString(TEXT("Alpha"))));

		const FText NamedPattern = FText::FromString(TEXT("{Int32}|{UInt32}|{Int64}|{UInt64}|{Float32}|{Float64}|{Text}"));
		FFormatNamedArguments NamedArguments;
		NamedArguments.Add(TEXT("Int32"), FFormatArgumentValue(int32(-7)));
		NamedArguments.Add(TEXT("UInt32"), FFormatArgumentValue(uint32(42)));
		NamedArguments.Add(TEXT("Int64"), FFormatArgumentValue(int64(9000000000ll)));
		NamedArguments.Add(TEXT("UInt64"), FFormatArgumentValue(uint64(15)));
		NamedArguments.Add(TEXT("Float32"), FFormatArgumentValue(float(3.25f)));
		NamedArguments.Add(TEXT("Float64"), FFormatArgumentValue(double(6.5)));
		NamedArguments.Add(TEXT("Text"), FFormatArgumentValue(FText::FromString(TEXT("Alpha"))));

		FTextFormattingExpectations Expectations;
		Expectations.OrderedExpected = FText::Format(OrderedPattern, OrderedArguments).ToString().ReplaceCharWithEscapedChar();
		Expectations.NamedExpected = FText::Format(NamedPattern, NamedArguments).ToString().ReplaceCharWithEscapedChar();
		return Expectations;
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptTextFormattingBindingsTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptFormatArgumentValueBindingsTest,
	"Angelscript.TestModule.Bindings.FormatArgumentValueCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptFormatArgumentValueBindingsTest::RunTest(const FString& Parameters)
{
	const FTextFormattingExpectations Expectations = BuildTextFormattingExpectations();

	FString ScriptSource = TEXT(R"(
int Entry()
{
	TArray<FFormatArgumentValue> OrderedArgs;
	OrderedArgs.Add(FFormatArgumentValue(int32(-7)));
	OrderedArgs.Add(FFormatArgumentValue(uint32(42)));
	OrderedArgs.Add(FFormatArgumentValue(int64(9000000000)));
	OrderedArgs.Add(FFormatArgumentValue(uint64(15)));
	OrderedArgs.Add(FFormatArgumentValue(float32(3.25)));
	OrderedArgs.Add(FFormatArgumentValue(float64(6.5)));
	OrderedArgs.Add(FFormatArgumentValue(FText::FromString("Alpha")));

	FText OrderedText = FText::Format(FText::FromString("{0}|{1}|{2}|{3}|{4}|{5}|{6}"), OrderedArgs);
	if (!(OrderedText.ToString() == "__ORDERED_EXPECTED__"))
		return 10;

	TMap<FString, FFormatArgumentValue> NamedArgs;
	NamedArgs.Add("Int32", FFormatArgumentValue(int32(-7)));
	NamedArgs.Add("UInt32", FFormatArgumentValue(uint32(42)));
	NamedArgs.Add("Int64", FFormatArgumentValue(int64(9000000000)));
	NamedArgs.Add("UInt64", FFormatArgumentValue(uint64(15)));
	NamedArgs.Add("Float32", FFormatArgumentValue(float32(3.25)));
	NamedArgs.Add("Float64", FFormatArgumentValue(float64(6.5)));
	NamedArgs.Add("Text", FFormatArgumentValue(FText::FromString("Alpha")));

	FText NamedText = FText::Format(FText::FromString("{Int32}|{UInt32}|{Int64}|{UInt64}|{Float32}|{Float64}|{Text}"), NamedArgs);
	if (!(NamedText.ToString() == "__NAMED_EXPECTED__"))
		return 20;

	return 1;
}
)");

	ScriptSource.ReplaceInline(TEXT("__ORDERED_EXPECTED__"), *Expectations.OrderedExpected, ESearchCase::CaseSensitive);
	ScriptSource.ReplaceInline(TEXT("__NAMED_EXPECTED__"), *Expectations.NamedExpected, ESearchCase::CaseSensitive);

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASTextFormattingBindings",
		ScriptSource);
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}

	TestEqual(TEXT("FFormatArgumentValue constructors should preserve ordered and named FText::Format output parity"), Result, 1);

	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
