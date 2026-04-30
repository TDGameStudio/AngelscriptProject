#include "Syntax/SAngelscriptHighlightedLine.h"

#include "Syntax/AngelscriptSyntaxStyle.h"
#include "Widgets/SBoxPanel.h"
#include "Widgets/Text/STextBlock.h"

void SAngelscriptHighlightedLine::Construct(const FArguments& InArgs)
{
	const FString Text = InArgs._Text;
	const FSlateFontInfo Font = InArgs._Font;
	const TArray<FAngelscriptSyntaxToken>& Tokens = InArgs._Tokens;

	TSharedRef<SHorizontalBox> LineBox = SNew(SHorizontalBox);

	if (Tokens.Num() == 0)
	{
		LineBox->AddSlot()
			.AutoWidth()
			[
				SNew(STextBlock)
				.Text(FText::FromString(Text))
				.Font(Font)
				.ColorAndOpacity(FAngelscriptSyntaxStyle::GetColor(EAngelscriptSyntaxTokenKind::Normal))
			];
	}

	for (const FAngelscriptSyntaxToken& Token : Tokens)
	{
		if (Token.Length <= 0 || Token.Start < 0 || Token.Start >= Text.Len())
		{
			continue;
		}

		const int32 ClampedLength = FMath::Min(Token.Length, Text.Len() - Token.Start);
		LineBox->AddSlot()
			.AutoWidth()
			[
				SNew(STextBlock)
				.Text(FText::FromString(Text.Mid(Token.Start, ClampedLength)))
				.Font(Font)
				.ColorAndOpacity(FAngelscriptSyntaxStyle::GetColor(Token.Kind))
			];
	}

	ChildSlot
	[
		LineBox
	];
}
