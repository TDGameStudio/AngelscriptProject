#pragma once

#include "CoreMinimal.h"
#include "Syntax/AngelscriptSyntaxTokenizer.h"
#include "Widgets/SCompoundWidget.h"

class ANGELSCRIPTSYNTAX_API SAngelscriptHighlightedLine : public SCompoundWidget
{
public:
	SLATE_BEGIN_ARGS(SAngelscriptHighlightedLine)
		: _Text()
		, _Tokens()
		, _Font()
	{
	}
		SLATE_ARGUMENT(FString, Text)
		SLATE_ARGUMENT(TArray<FAngelscriptSyntaxToken>, Tokens)
		SLATE_ARGUMENT(FSlateFontInfo, Font)
	SLATE_END_ARGS()

	void Construct(const FArguments& InArgs);
};
