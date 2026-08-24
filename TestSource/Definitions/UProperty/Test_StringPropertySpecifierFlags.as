// Theme: Definitions.UProperty. WorldStory: FString/FName/FText specifier and DisplayName/ToolTip metadata.
// C++: EditableString CPF_Edit/BlueprintVisible; ReadOnlyName BlueprintReadOnly; AdvancedText AdvancedDisplay.
// Extra: empty FString/FName/FText defaults. FixtureIsolated.

UCLASS()
class ACoverageFStringSpecifierActor : AActor
{
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Coverage|String")
	FString EditableString;

	UPROPERTY(BlueprintReadOnly)
	FName ReadOnlyName;

	UPROPERTY(AdvancedDisplay)
	FText AdvancedText;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, meta = (DisplayName = "Visible String", ToolTip = "Visible string tooltip"))
	FString VisibleString;

	UPROPERTY(Transient)
	FName TransientName;

	UPROPERTY(SaveGame)
	FText SaveGameText;
}

bool Observe_FStringSpecifier_EmptyDefault()
{
	FString EditableString;
	return EditableString.Len() == 0;
}

bool Observe_FNameSpecifier_NoneDefault()
{
	FName ReadOnlyName;
	return ReadOnlyName == NAME_None;
}
