#include "Syntax/AngelscriptSyntaxTokenizer.h"

namespace
{
	bool IsIdentifierStart(const TCHAR Character)
	{
		return FChar::IsAlpha(Character) || Character == TEXT('_');
	}

	bool IsIdentifierBody(const TCHAR Character)
	{
		return FChar::IsAlnum(Character) || Character == TEXT('_');
	}

	void AddToken(TArray<FAngelscriptSyntaxToken>& Tokens, const int32 Start, const int32 Length, const EAngelscriptSyntaxTokenKind Kind)
	{
		if (Length <= 0)
		{
			return;
		}

		if (Kind != EAngelscriptSyntaxTokenKind::Normal && Tokens.Num() > 0)
		{
			FAngelscriptSyntaxToken& Previous = Tokens.Last();
			if (Previous.Kind == Kind && Previous.Start + Previous.Length == Start)
			{
				Previous.Length += Length;
				return;
			}
		}

		FAngelscriptSyntaxToken Token;
		Token.Start = Start;
		Token.Length = Length;
		Token.Kind = Kind;
		Tokens.Add(Token);
	}

	bool StartsWithAt(const FString& Line, const int32 Index, const TCHAR* Pattern)
	{
		const int32 PatternLength = FCString::Strlen(Pattern);
		return Index >= 0
			&& PatternLength > 0
			&& Index + PatternLength <= Line.Len()
			&& FCString::Strncmp(*Line + Index, Pattern, PatternLength) == 0;
	}

	int32 FindFrom(const FString& Line, const TCHAR* Pattern, const int32 StartIndex)
	{
		const int32 PatternLength = FCString::Strlen(Pattern);
		if (PatternLength <= 0 || StartIndex < 0 || StartIndex >= Line.Len())
		{
			return INDEX_NONE;
		}

		for (int32 Index = StartIndex; Index + PatternLength <= Line.Len(); ++Index)
		{
			if (FCString::Strncmp(*Line + Index, Pattern, PatternLength) == 0)
			{
				return Index;
			}
		}

		return INDEX_NONE;
	}

	bool IsKeyword(const FString& Identifier)
	{
		static const TSet<FString> Keywords = {
			TEXT("access"),
			TEXT("abstract"),
			TEXT("auto"),
			TEXT("break"),
			TEXT("case"),
			TEXT("Cast"),
			TEXT("class"),
			TEXT("const"),
			TEXT("continue"),
			TEXT("default"),
			TEXT("delegate"),
			TEXT("do"),
			TEXT("else"),
			TEXT("enum"),
			TEXT("event"),
			TEXT("external"),
			TEXT("false"),
			TEXT("fallthrough"),
			TEXT("final"),
			TEXT("for"),
			TEXT("foreach"),
			TEXT("from"),
			TEXT("function"),
			TEXT("get"),
			TEXT("if"),
			TEXT("import"),
			TEXT("in"),
			TEXT("inout"),
			TEXT("interface"),
			TEXT("local"),
			TEXT("mixin"),
			TEXT("namespace"),
			TEXT("nullptr"),
			TEXT("out"),
			TEXT("override"),
			TEXT("private"),
			TEXT("property"),
			TEXT("protected"),
			TEXT("readonly"),
			TEXT("return"),
			TEXT("set"),
			TEXT("shared"),
			TEXT("struct"),
			TEXT("super"),
			TEXT("switch"),
			TEXT("this"),
			TEXT("true"),
			TEXT("void"),
			TEXT("while"),
		};

		return Keywords.Contains(Identifier);
	}

	bool IsTypeKeyword(const FString& Identifier)
	{
		static const TSet<FString> Types = {
			TEXT("bool"),
			TEXT("double"),
			TEXT("float"),
			TEXT("float32"),
			TEXT("float64"),
			TEXT("int"),
			TEXT("int8"),
			TEXT("int16"),
			TEXT("int32"),
			TEXT("int64"),
			TEXT("uint"),
			TEXT("uint8"),
			TEXT("uint16"),
			TEXT("uint32"),
			TEXT("uint64"),
			TEXT("FString"),
			TEXT("FName"),
			TEXT("FText"),
			TEXT("FVector"),
			TEXT("FVector2D"),
			TEXT("FVector4"),
			TEXT("FRotator"),
			TEXT("FQuat"),
			TEXT("FTransform"),
			TEXT("FLinearColor"),
			TEXT("FColor"),
		};

		return Types.Contains(Identifier);
	}

	bool IsMetadata(const FString& Identifier)
	{
		static const TSet<FString> Metadata = {
			TEXT("UCLASS"),
			TEXT("USTRUCT"),
			TEXT("UENUM"),
			TEXT("UFUNCTION"),
			TEXT("UPROPERTY"),
			TEXT("BlueprintCallable"),
			TEXT("BlueprintPure"),
			TEXT("BlueprintReadOnly"),
			TEXT("BlueprintReadWrite"),
			TEXT("BlueprintType"),
			TEXT("Blueprintable"),
			TEXT("NotBlueprintable"),
			TEXT("EditAnywhere"),
			TEXT("EditDefaultsOnly"),
			TEXT("EditInstanceOnly"),
			TEXT("VisibleAnywhere"),
			TEXT("VisibleDefaultsOnly"),
			TEXT("VisibleInstanceOnly"),
			TEXT("Category"),
			TEXT("meta"),
			TEXT("DisplayName"),
			TEXT("Transient"),
			TEXT("Replicated"),
			TEXT("ReplicatedUsing"),
			TEXT("NetMulticast"),
			TEXT("Server"),
			TEXT("Client"),
		};

		return Metadata.Contains(Identifier);
	}

	int32 ConsumeString(const FString& Line, const int32 StartIndex)
	{
		const TCHAR Quote = Line[StartIndex];
		bool bEscaped = false;

		for (int32 Index = StartIndex + 1; Index < Line.Len(); ++Index)
		{
			const TCHAR Character = Line[Index];
			if (bEscaped)
			{
				bEscaped = false;
				continue;
			}

			if (Character == TEXT('\\'))
			{
				bEscaped = true;
				continue;
			}

			if (Character == Quote)
			{
				return Index + 1;
			}
		}

		return Line.Len();
	}

	bool IsHexDigit(const TCHAR Character)
	{
		return FChar::IsDigit(Character)
			|| (Character >= TEXT('a') && Character <= TEXT('f'))
			|| (Character >= TEXT('A') && Character <= TEXT('F'));
	}

	bool IsDecimalLiteralSuffix(const TCHAR Character)
	{
		switch (Character)
		{
		case TEXT('f'):
		case TEXT('F'):
		case TEXT('d'):
		case TEXT('D'):
		case TEXT('u'):
		case TEXT('U'):
		case TEXT('l'):
		case TEXT('L'):
			return true;
		default:
			return false;
		}
	}

	int32 ConsumeDigitsAndSeparators(const FString& Line, int32 Index, const TFunctionRef<bool(TCHAR)> IsValidDigit)
	{
		while (Index < Line.Len() && (IsValidDigit(Line[Index]) || Line[Index] == TEXT('_')))
		{
			++Index;
		}
		return Index;
	}

	int32 ConsumeNumber(const FString& Line, const int32 StartIndex)
	{
		int32 Index = StartIndex;
		bool bHasDot = false;
		bool bHasExponent = false;

		if (Line[Index] == TEXT('.'))
		{
			bHasDot = true;
			++Index;
		}
		else if (Line[Index] == TEXT('0') && Index + 1 < Line.Len())
		{
			const TCHAR Prefix = Line[Index + 1];
			if (Prefix == TEXT('x') || Prefix == TEXT('X'))
			{
				Index += 2;
				Index = ConsumeDigitsAndSeparators(Line, Index, [](const TCHAR Character)
				{
					return IsHexDigit(Character);
				});
				while (Index < Line.Len() && (Line[Index] == TEXT('u') || Line[Index] == TEXT('U') || Line[Index] == TEXT('l') || Line[Index] == TEXT('L')))
				{
					++Index;
				}
				return Index;
			}
			if (Prefix == TEXT('b') || Prefix == TEXT('B'))
			{
				Index += 2;
				Index = ConsumeDigitsAndSeparators(Line, Index, [](const TCHAR Character)
				{
					return Character == TEXT('0') || Character == TEXT('1');
				});
				while (Index < Line.Len() && (Line[Index] == TEXT('u') || Line[Index] == TEXT('U') || Line[Index] == TEXT('l') || Line[Index] == TEXT('L')))
				{
					++Index;
				}
				return Index;
			}
		}

		if (Index == StartIndex)
		{
			++Index;
		}

		while (Index < Line.Len())
		{
			const TCHAR Character = Line[Index];
			if (FChar::IsDigit(Character) || Character == TEXT('_'))
			{
				++Index;
				continue;
			}

			if (Character == TEXT('.'))
			{
				if (bHasDot
					|| bHasExponent
					|| (Index + 1 < Line.Len() && Line[Index + 1] == TEXT('.'))
					|| (Index + 1 < Line.Len() && IsIdentifierStart(Line[Index + 1])))
				{
					break;
				}

				bHasDot = true;
				++Index;
				continue;
			}

			if ((Character == TEXT('e') || Character == TEXT('E')) && !bHasExponent)
			{
				int32 ExponentIndex = Index + 1;
				if (ExponentIndex < Line.Len() && (Line[ExponentIndex] == TEXT('+') || Line[ExponentIndex] == TEXT('-')))
				{
					++ExponentIndex;
				}
				if (ExponentIndex >= Line.Len() || !FChar::IsDigit(Line[ExponentIndex]))
				{
					break;
				}

				bHasExponent = true;
				Index = ExponentIndex + 1;
				continue;
			}

			if (IsDecimalLiteralSuffix(Character))
			{
				int32 SuffixIndex = Index + 1;
				while (SuffixIndex < Line.Len() && IsDecimalLiteralSuffix(Line[SuffixIndex]))
				{
					++SuffixIndex;
				}

				if (SuffixIndex >= Line.Len() || !IsIdentifierBody(Line[SuffixIndex]))
				{
					return SuffixIndex;
				}

				break;
			}

			break;
		}

		return Index;
	}
}

TArray<FAngelscriptSyntaxToken> FAngelscriptSyntaxTokenizer::TokenizeLine(const FString& Line, FState& State)
{
	TArray<FAngelscriptSyntaxToken> Tokens;
	int32 Index = 0;

	if (State.bInBlockComment)
	{
		const int32 EndIndex = FindFrom(Line, TEXT("*/"), 0);
		if (EndIndex == INDEX_NONE)
		{
			AddToken(Tokens, 0, Line.Len(), EAngelscriptSyntaxTokenKind::Comment);
			return Tokens;
		}

		AddToken(Tokens, 0, EndIndex + 2, EAngelscriptSyntaxTokenKind::Comment);
		State.bInBlockComment = false;
		Index = EndIndex + 2;
	}

	if (State.bInHeredocString)
	{
		const int32 EndIndex = FindFrom(Line, TEXT("\"\"\""), Index);
		if (EndIndex == INDEX_NONE)
		{
			AddToken(Tokens, Index, Line.Len() - Index, EAngelscriptSyntaxTokenKind::String);
			return Tokens;
		}

		AddToken(Tokens, Index, EndIndex + 3 - Index, EAngelscriptSyntaxTokenKind::String);
		State.bInHeredocString = false;
		Index = EndIndex + 3;
	}

	const int32 FirstNonWhitespace = [&Line]() -> int32
	{
		for (int32 ScanIndex = 0; ScanIndex < Line.Len(); ++ScanIndex)
		{
			if (!FChar::IsWhitespace(Line[ScanIndex]))
			{
				return ScanIndex;
			}
		}

		return INDEX_NONE;
	}();

	if (FirstNonWhitespace != INDEX_NONE && Line[FirstNonWhitespace] == TEXT('#'))
	{
		AddToken(Tokens, 0, FirstNonWhitespace, EAngelscriptSyntaxTokenKind::Normal);
		AddToken(Tokens, FirstNonWhitespace, Line.Len() - FirstNonWhitespace, EAngelscriptSyntaxTokenKind::Preprocessor);
		return Tokens;
	}

	while (Index < Line.Len())
	{
		const TCHAR Character = Line[Index];

		if (FChar::IsWhitespace(Character))
		{
			const int32 Start = Index;
			while (Index < Line.Len() && FChar::IsWhitespace(Line[Index]))
			{
				++Index;
			}
			AddToken(Tokens, Start, Index - Start, EAngelscriptSyntaxTokenKind::Normal);
			continue;
		}

		if (StartsWithAt(Line, Index, TEXT("//")))
		{
			AddToken(Tokens, Index, Line.Len() - Index, EAngelscriptSyntaxTokenKind::Comment);
			return Tokens;
		}

		if (StartsWithAt(Line, Index, TEXT("/*")))
		{
			const int32 EndIndex = FindFrom(Line, TEXT("*/"), Index + 2);
			if (EndIndex == INDEX_NONE)
			{
				AddToken(Tokens, Index, Line.Len() - Index, EAngelscriptSyntaxTokenKind::Comment);
				State.bInBlockComment = true;
				return Tokens;
			}

			AddToken(Tokens, Index, EndIndex + 2 - Index, EAngelscriptSyntaxTokenKind::Comment);
			Index = EndIndex + 2;
			continue;
		}

		if (StartsWithAt(Line, Index, TEXT("\"\"\"")))
		{
			const int32 EndIndex = FindFrom(Line, TEXT("\"\"\""), Index + 3);
			if (EndIndex == INDEX_NONE)
			{
				AddToken(Tokens, Index, Line.Len() - Index, EAngelscriptSyntaxTokenKind::String);
				State.bInHeredocString = true;
				return Tokens;
			}

			AddToken(Tokens, Index, EndIndex + 3 - Index, EAngelscriptSyntaxTokenKind::String);
			Index = EndIndex + 3;
			continue;
		}

		if (Character == TEXT('"') || Character == TEXT('\''))
		{
			const int32 EndIndex = ConsumeString(Line, Index);
			AddToken(Tokens, Index, EndIndex - Index, EAngelscriptSyntaxTokenKind::String);
			Index = EndIndex;
			continue;
		}

		if (FChar::IsDigit(Character) || (Character == TEXT('.') && Index + 1 < Line.Len() && FChar::IsDigit(Line[Index + 1])))
		{
			const int32 Start = Index;
			Index = ConsumeNumber(Line, Index);
			AddToken(Tokens, Start, Index - Start, EAngelscriptSyntaxTokenKind::Number);
			continue;
		}

		if (IsIdentifierStart(Character))
		{
			const int32 Start = Index;
			++Index;
			while (Index < Line.Len() && IsIdentifierBody(Line[Index]))
			{
				++Index;
			}

			const FString Identifier = Line.Mid(Start, Index - Start);
			AddToken(Tokens, Start, Index - Start, ClassifyIdentifier(Identifier));
			continue;
		}

		const int32 Start = Index;
		while (Index < Line.Len()
			&& !FChar::IsWhitespace(Line[Index])
			&& !IsIdentifierStart(Line[Index])
			&& !FChar::IsDigit(Line[Index])
			&& Line[Index] != TEXT('"')
			&& Line[Index] != TEXT('\'')
			&& !StartsWithAt(Line, Index, TEXT("//"))
			&& !StartsWithAt(Line, Index, TEXT("/*")))
		{
			++Index;
		}

		AddToken(Tokens, Start, Index - Start, EAngelscriptSyntaxTokenKind::Operator);
	}

	return Tokens;
}

TArray<TArray<FAngelscriptSyntaxToken>> FAngelscriptSyntaxTokenizer::TokenizeLines(const TArray<FString>& Lines)
{
	TArray<TArray<FAngelscriptSyntaxToken>> Result;
	Result.Reserve(Lines.Num());

	FState State;
	for (const FString& Line : Lines)
	{
		Result.Add(TokenizeLine(Line, State));
	}

	return Result;
}

EAngelscriptSyntaxTokenKind FAngelscriptSyntaxTokenizer::ClassifyIdentifier(const FString& Identifier)
{
	if (IsMetadata(Identifier))
	{
		return EAngelscriptSyntaxTokenKind::Metadata;
	}

	if (IsTypeKeyword(Identifier))
	{
		return EAngelscriptSyntaxTokenKind::Type;
	}

	if (IsKeyword(Identifier))
	{
		return EAngelscriptSyntaxTokenKind::Keyword;
	}

	return EAngelscriptSyntaxTokenKind::Normal;
}
