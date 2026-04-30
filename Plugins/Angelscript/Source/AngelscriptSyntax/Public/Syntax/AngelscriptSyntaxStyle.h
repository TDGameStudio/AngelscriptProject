#pragma once

#include "CoreMinimal.h"
#include "Styling/SlateTypes.h"

enum class EAngelscriptSyntaxTokenKind : uint8;

class ANGELSCRIPTSYNTAX_API FAngelscriptSyntaxStyle
{
public:
	static FSlateColor GetColor(EAngelscriptSyntaxTokenKind Kind);
	static FTextBlockStyle MakeTextBlockStyle(EAngelscriptSyntaxTokenKind Kind, const FSlateFontInfo& Font);
};
