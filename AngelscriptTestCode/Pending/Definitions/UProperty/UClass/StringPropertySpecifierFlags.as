/**
 * @version v1
 * @summary FString/FName/FText specifier and DisplayName/ToolTip metadata. C++ verifies named properties by path, so those UPROPERTY names are kept. The observers cover the empty FString and NAME_None defaults.
 * @topic Definitions
 */
/**
 * @version root
 * @summary FString/FName/FText specifier and DisplayName/ToolTip metadata. C++ verifies named properties by path, so those UPROPERTY names are kept. The observers cover the empty FString and NAME_None defaults.
 * @topic Baseline
 */
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

	/**
	 * Observe the empty FString default.
	 *
	 * @Kind Observe
	 * @Covers UProperty.StringPropertySpecifierFlags
	 * @Inputs a default-constructed FString
	 * @Return true when Len is 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool FStringSpecifierEmptyDefault()
	{
		FString EditableString;
		return EditableString.Len() == 0;
	}

	/**
	 * Observe the NAME_None default for FName.
	 *
	 * @Kind Observe
	 * @Covers UProperty.StringPropertySpecifierFlags
	 * @Inputs a default-constructed FName
	 * @Return true when the name is NAME_None
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool FNameSpecifierNoneDefault()
	{
		FName ReadOnlyName;
		return ReadOnlyName == NAME_None;
	}
}
/** @end */
