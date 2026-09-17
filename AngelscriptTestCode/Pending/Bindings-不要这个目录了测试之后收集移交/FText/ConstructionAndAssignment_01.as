/**
 * @version v1
 * @summary Observe FText comparison-mode and date-style enums, assignment, and formatter interpolation.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FText comparison-mode and date-style enums, assignment, and formatter interpolation.
 * @topic Baseline
 */
// enum EDateTimeStyle { Default, Short, Medium, Long, Full };
// Left = Right; FString Value = f"{Text}";
// Inputs: Empty FText, FromString("Hello") as Right, None vs DeepCompare, and
// Default vs Short date styles.
// Expected observations: Assignment copies display text. f"{Text}" is
// non-empty for Hello. Enumerators are distinct.
// Boundary/ownership: FText assignment copies the localized history, not a
// raw FString alias.

namespace TS_FText_ConstructionAndAssignment_01
{
	// ETextIdenticalModeFlags None/DeepCompare/LexicalCompareInvariants plus
	// copy-assign. Inputs None then assign Deep. None != Deep != Lexical;
	// assigned copy is Deep. Enum value type; no FText ownership.
	bool Observe_Surface001_Nominal()
	{
		ETextIdenticalModeFlags NoneFlags = ETextIdenticalModeFlags::None;
		ETextIdenticalModeFlags Deep = ETextIdenticalModeFlags::DeepCompare;
		ETextIdenticalModeFlags Lexical = ETextIdenticalModeFlags::LexicalCompareInvariants;
		ETextIdenticalModeFlags Copied = NoneFlags;
		Copied = Deep;
		return NoneFlags != Deep && Deep != Lexical && Copied == Deep;
	}

	// EDateTimeStyle Default/Short/Medium/Long/Full. No extra inputs. Default
	// != Short, Medium != Long, Full != Short. Enum value type; no calendar
	// ownership.
	bool Observe_Surface002_Nominal()
	{
		EDateTimeStyle DefaultStyle = EDateTimeStyle::Default;
		EDateTimeStyle ShortStyle = EDateTimeStyle::Short;
		EDateTimeStyle MediumStyle = EDateTimeStyle::Medium;
		EDateTimeStyle LongStyle = EDateTimeStyle::Long;
		EDateTimeStyle FullStyle = EDateTimeStyle::Full;
		return DefaultStyle != ShortStyle && MediumStyle != LongStyle && FullStyle != ShortStyle;
	}

	// FText assignment and f"{Text}". Inputs empty Left and FromString("Hello"),
	// then reassign Right to "Other". Formatted text contains Hello; Left is
	// not empty. Assignment copies history; Right mutation does not clear Left.
	bool Observe_Assignment_Nominal()
	{
		FText Left;
		FText Right = FText::FromString("Hello");
		Left = Right;
		FString Formatted = f"{Left}";
		FText Other = FText::FromString("Other");
		Right = Other;
		return Formatted.Contains("Hello") && !Left.IsEmpty();
	}
}
/** @end */
