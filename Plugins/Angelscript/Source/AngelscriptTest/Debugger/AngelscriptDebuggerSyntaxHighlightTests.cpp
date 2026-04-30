#include "Syntax/AngelscriptSyntaxTokenizer.h"

#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Debugger_AngelscriptDebuggerSyntaxHighlightTests_Private
{
	bool HasToken(
		const TArray<FAngelscriptSyntaxToken>& Tokens,
		const FString& Source,
		const FString& Text,
		const EAngelscriptSyntaxTokenKind Kind)
	{
		for (const FAngelscriptSyntaxToken& Token : Tokens)
		{
			if (Token.Kind == Kind
				&& Token.Start >= 0
				&& Token.Length == Text.Len()
				&& Source.Mid(Token.Start, Token.Length) == Text)
			{
				return true;
			}
		}

		return false;
	}

	int32 CountToken(
		const TArray<FAngelscriptSyntaxToken>& Tokens,
		const FString& Source,
		const FString& Text,
		const EAngelscriptSyntaxTokenKind Kind)
	{
		int32 Count = 0;
		for (const FAngelscriptSyntaxToken& Token : Tokens)
		{
			if (Token.Kind == Kind
				&& Token.Start >= 0
				&& Token.Length == Text.Len()
				&& Source.Mid(Token.Start, Token.Length) == Text)
			{
				++Count;
			}
		}

		return Count;
	}
}

using namespace AngelscriptTest_Debugger_AngelscriptDebuggerSyntaxHighlightTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerSyntaxHighlightKeywordLineTest,
	"Angelscript.TestModule.Debugger.SyntaxHighlight.KeywordLine",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerSyntaxHighlightMultilineCommentTest,
	"Angelscript.TestModule.Debugger.SyntaxHighlight.MultilineComment",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerSyntaxHighlightPreprocessorAndMetadataTest,
	"Angelscript.TestModule.Debugger.SyntaxHighlight.PreprocessorAndMetadata",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerSyntaxHighlightNumberBoundaryTest,
	"Angelscript.TestModule.Debugger.SyntaxHighlight.NumberBoundary",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebuggerSyntaxHighlightKeywordLineTest::RunTest(const FString& Parameters)
{
	const FString Source = TEXT("UCLASS() class ADebugActor : AActor { int32 Count = 42; FString Name = \"AS\"; }");
	FAngelscriptSyntaxTokenizer::FState State;
	const TArray<FAngelscriptSyntaxToken> Tokens = FAngelscriptSyntaxTokenizer::TokenizeLine(Source, State);

	TestTrue(TEXT("Syntax highlighting should classify UCLASS as metadata"),
		HasToken(Tokens, Source, TEXT("UCLASS"), EAngelscriptSyntaxTokenKind::Metadata));
	TestTrue(TEXT("Syntax highlighting should classify class as a keyword"),
		HasToken(Tokens, Source, TEXT("class"), EAngelscriptSyntaxTokenKind::Keyword));
	TestTrue(TEXT("Syntax highlighting should classify int32 as a type"),
		HasToken(Tokens, Source, TEXT("int32"), EAngelscriptSyntaxTokenKind::Type));
	TestTrue(TEXT("Syntax highlighting should classify numeric literals"),
		HasToken(Tokens, Source, TEXT("42"), EAngelscriptSyntaxTokenKind::Number));
	TestTrue(TEXT("Syntax highlighting should classify string literals"),
		HasToken(Tokens, Source, TEXT("\"AS\""), EAngelscriptSyntaxTokenKind::String));
	return true;
}

bool FAngelscriptDebuggerSyntaxHighlightMultilineCommentTest::RunTest(const FString& Parameters)
{
	FAngelscriptSyntaxTokenizer::FState State;
	const FString FirstLine = TEXT("int32 Count; /* comment starts");
	const FString SecondLine = TEXT("still comment */ Count++;");

	const TArray<FAngelscriptSyntaxToken> FirstTokens = FAngelscriptSyntaxTokenizer::TokenizeLine(FirstLine, State);
	TestTrue(TEXT("Syntax highlighting should enter multiline comment state"),
		State.bInBlockComment);
	TestTrue(TEXT("Syntax highlighting should classify the first multiline comment run"),
		HasToken(FirstTokens, FirstLine, TEXT("/* comment starts"), EAngelscriptSyntaxTokenKind::Comment));

	const TArray<FAngelscriptSyntaxToken> SecondTokens = FAngelscriptSyntaxTokenizer::TokenizeLine(SecondLine, State);
	TestFalse(TEXT("Syntax highlighting should leave multiline comment state after the terminator"),
		State.bInBlockComment);
	TestTrue(TEXT("Syntax highlighting should classify the second multiline comment run"),
		HasToken(SecondTokens, SecondLine, TEXT("still comment */"), EAngelscriptSyntaxTokenKind::Comment));
	TestTrue(TEXT("Syntax highlighting should resume normal tokenization after a multiline comment"),
		HasToken(SecondTokens, SecondLine, TEXT("Count"), EAngelscriptSyntaxTokenKind::Normal));
	return true;
}

bool FAngelscriptDebuggerSyntaxHighlightPreprocessorAndMetadataTest::RunTest(const FString& Parameters)
{
	FAngelscriptSyntaxTokenizer::FState State;
	const FString PreprocessorLine = TEXT("    #include \"Gameplay/Actor.as\"");
	const TArray<FAngelscriptSyntaxToken> PreprocessorTokens = FAngelscriptSyntaxTokenizer::TokenizeLine(PreprocessorLine, State);
	TestTrue(TEXT("Syntax highlighting should classify preprocessor directives"),
		HasToken(PreprocessorTokens, PreprocessorLine, TEXT("#include \"Gameplay/Actor.as\""), EAngelscriptSyntaxTokenKind::Preprocessor));

	const FString MetadataLine = TEXT("UPROPERTY(BlueprintReadOnly, Category=\"Debug\") bool bEnabled = true;");
	const TArray<FAngelscriptSyntaxToken> MetadataTokens = FAngelscriptSyntaxTokenizer::TokenizeLine(MetadataLine, State);
	TestTrue(TEXT("Syntax highlighting should classify UPROPERTY as metadata"),
		HasToken(MetadataTokens, MetadataLine, TEXT("UPROPERTY"), EAngelscriptSyntaxTokenKind::Metadata));
	TestTrue(TEXT("Syntax highlighting should classify BlueprintReadOnly as metadata"),
		HasToken(MetadataTokens, MetadataLine, TEXT("BlueprintReadOnly"), EAngelscriptSyntaxTokenKind::Metadata));
	TestTrue(TEXT("Syntax highlighting should classify true as a keyword"),
		HasToken(MetadataTokens, MetadataLine, TEXT("true"), EAngelscriptSyntaxTokenKind::Keyword));
	return true;
}

bool FAngelscriptDebuggerSyntaxHighlightNumberBoundaryTest::RunTest(const FString& Parameters)
{
	FAngelscriptSyntaxTokenizer::FState State;

	const FString SumLine = TEXT("int32 Sum = 1+2;");
	const TArray<FAngelscriptSyntaxToken> SumTokens = FAngelscriptSyntaxTokenizer::TokenizeLine(SumLine, State);
	TestEqual(TEXT("Syntax highlighting should keep 1 before + as its own number"),
		CountToken(SumTokens, SumLine, TEXT("1"), EAngelscriptSyntaxTokenKind::Number),
		1);
	TestTrue(TEXT("Syntax highlighting should classify + between numbers as an operator"),
		HasToken(SumTokens, SumLine, TEXT("+"), EAngelscriptSyntaxTokenKind::Operator));
	TestEqual(TEXT("Syntax highlighting should keep 2 after + as its own number"),
		CountToken(SumTokens, SumLine, TEXT("2"), EAngelscriptSyntaxTokenKind::Number),
		1);

	const FString SubtractLine = TEXT("float Delta = 1-Value;");
	const TArray<FAngelscriptSyntaxToken> SubtractTokens = FAngelscriptSyntaxTokenizer::TokenizeLine(SubtractLine, State);
	TestEqual(TEXT("Syntax highlighting should keep 1 before - as its own number"),
		CountToken(SubtractTokens, SubtractLine, TEXT("1"), EAngelscriptSyntaxTokenKind::Number),
		1);
	TestTrue(TEXT("Syntax highlighting should classify - before identifiers as an operator"),
		HasToken(SubtractTokens, SubtractLine, TEXT("-"), EAngelscriptSyntaxTokenKind::Operator));
	TestTrue(TEXT("Syntax highlighting should not fold identifiers after - into numeric literals"),
		HasToken(SubtractTokens, SubtractLine, TEXT("Value"), EAngelscriptSyntaxTokenKind::Normal));

	const FString RangeLine = TEXT("auto Item = 0..Array.Num();");
	const TArray<FAngelscriptSyntaxToken> RangeTokens = FAngelscriptSyntaxTokenizer::TokenizeLine(RangeLine, State);
	TestEqual(TEXT("Syntax highlighting should keep 0 before .. as its own number"),
		CountToken(RangeTokens, RangeLine, TEXT("0"), EAngelscriptSyntaxTokenKind::Number),
		1);
	TestTrue(TEXT("Syntax highlighting should classify .. as an operator"),
		HasToken(RangeTokens, RangeLine, TEXT(".."), EAngelscriptSyntaxTokenKind::Operator));
	TestTrue(TEXT("Syntax highlighting should not fold identifiers after .. into numeric literals"),
		HasToken(RangeTokens, RangeLine, TEXT("Array"), EAngelscriptSyntaxTokenKind::Normal));

	const FString ExponentLine = TEXT("float Tiny = 1e-3f;");
	const TArray<FAngelscriptSyntaxToken> ExponentTokens = FAngelscriptSyntaxTokenizer::TokenizeLine(ExponentLine, State);
	TestTrue(TEXT("Syntax highlighting should keep signed exponents inside numeric literals"),
		HasToken(ExponentTokens, ExponentLine, TEXT("1e-3f"), EAngelscriptSyntaxTokenKind::Number));
	return true;
}

#endif
