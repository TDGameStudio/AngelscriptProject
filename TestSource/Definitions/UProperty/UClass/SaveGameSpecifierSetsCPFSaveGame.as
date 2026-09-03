/**
 * SaveGame sets CPF_SaveGame. The observers cover the empty default 0 and that
 * mutating a local SavedScore leaves EmptySavedScore at 0.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.SaveGameSpecifierSetsCPFSaveGame
 * @Harness UClass
 * @Tag Definitions.UProperty.SaveGameSpecifierSetsCPFSaveGame
 * @Provenance Theme: Definitions.UProperty. Positive: SaveGame sets CPF_SaveGame.
 * @Provenance C++: AngelscriptCompilerUPropertySpecifierMatrixTests.cpp::SaveGameSpecifierSetsCPFSaveGame
 * @Provenance Oracle: SavedScore has CPF_SaveGame. Extra: default 0; EmptySavedScore stays 0.
 * @Provenance DefaultSafe.
 */

UCLASS()
class USaveGameTestObj : UObject
{
	UPROPERTY(SaveGame)
	int SavedScore;

	UPROPERTY(SaveGame)
	int EmptySavedScore = 0;

	/**
	 * Observe the empty SaveGame default.
	 *
	 * @Kind Observe
	 * @Covers UProperty.SaveGameSpecifierSetsCPFSaveGame
	 * @Inputs none
	 * @Return 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	int SaveGameDefaultZero()
	{
		return 0;
	}

	/**
	 * Observe that writing a local SavedScore leaves EmptySavedScore at 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.SaveGameSpecifierSetsCPFSaveGame
	 * @Inputs local SavedScore written to 12
	 * @Return 0 from EmptySavedScore
	 * @Boundary copy independence
	 */
	UFUNCTION()
	int SaveGameEmptyIndependent()
	{
		int SavedScore = 0;
		int EmptySavedScore = 0;
		SavedScore = 12;
		return EmptySavedScore;
	}
}
