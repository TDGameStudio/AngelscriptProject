#pragma once

#include "CoreMinimal.h"

enum class EAngelscriptSyntaxTokenKind : uint8
{
	Normal,
	Keyword,
	Type,
	Number,
	String,
	Comment,
	Preprocessor,
	Operator,
	Metadata,
	Error,
};

struct ANGELSCRIPTSYNTAX_API FAngelscriptSyntaxToken
{
	int32 Start = 0;
	int32 Length = 0;
	EAngelscriptSyntaxTokenKind Kind = EAngelscriptSyntaxTokenKind::Normal;
};

class ANGELSCRIPTSYNTAX_API FAngelscriptSyntaxTokenizer
{
public:
	struct FState
	{
		bool bInBlockComment = false;
		bool bInHeredocString = false;
	};

	static TArray<FAngelscriptSyntaxToken> TokenizeLine(const FString& Line, FState& State);
	static TArray<TArray<FAngelscriptSyntaxToken>> TokenizeLines(const TArray<FString>& Lines);
	static EAngelscriptSyntaxTokenKind ClassifyIdentifier(const FString& Identifier);
};
