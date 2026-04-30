#include "Syntax/AngelscriptSyntaxStyle.h"

#include "Styling/CoreStyle.h"
#include "Syntax/AngelscriptSyntaxTokenizer.h"

FSlateColor FAngelscriptSyntaxStyle::GetColor(const EAngelscriptSyntaxTokenKind Kind)
{
	switch (Kind)
	{
	case EAngelscriptSyntaxTokenKind::Keyword:
		return FSlateColor(FLinearColor(0.56f, 0.72f, 1.0f, 1.0f));
	case EAngelscriptSyntaxTokenKind::Type:
		return FSlateColor(FLinearColor(0.35f, 0.80f, 0.86f, 1.0f));
	case EAngelscriptSyntaxTokenKind::Number:
		return FSlateColor(FLinearColor(0.88f, 0.70f, 0.42f, 1.0f));
	case EAngelscriptSyntaxTokenKind::String:
		return FSlateColor(FLinearColor(0.72f, 0.86f, 0.48f, 1.0f));
	case EAngelscriptSyntaxTokenKind::Comment:
		return FSlateColor(FLinearColor(0.45f, 0.56f, 0.45f, 1.0f));
	case EAngelscriptSyntaxTokenKind::Preprocessor:
		return FSlateColor(FLinearColor(0.86f, 0.58f, 0.96f, 1.0f));
	case EAngelscriptSyntaxTokenKind::Operator:
		return FSlateColor(FLinearColor(0.72f, 0.72f, 0.72f, 1.0f));
	case EAngelscriptSyntaxTokenKind::Metadata:
		return FSlateColor(FLinearColor(0.95f, 0.74f, 0.36f, 1.0f));
	case EAngelscriptSyntaxTokenKind::Error:
		return FSlateColor(FLinearColor(1.0f, 0.34f, 0.34f, 1.0f));
	case EAngelscriptSyntaxTokenKind::Normal:
	default:
		return FSlateColor(FLinearColor(0.82f, 0.82f, 0.82f, 1.0f));
	}
}

FTextBlockStyle FAngelscriptSyntaxStyle::MakeTextBlockStyle(const EAngelscriptSyntaxTokenKind Kind, const FSlateFontInfo& Font)
{
	FTextBlockStyle Style = FCoreStyle::Get().GetWidgetStyle<FTextBlockStyle>("NormalText");
	Style.SetFont(Font);
	Style.SetColorAndOpacity(GetColor(Kind));
	return Style;
}
