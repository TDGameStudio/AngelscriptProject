// Theme: Definitions.UProperty. Positive: SaveGame sets CPF_SaveGame.
// C++: AngelscriptCompilerUPropertySpecifierMatrixTests.cpp::SaveGameSpecifierSetsCPFSaveGame
// Oracle: SavedScore has CPF_SaveGame. Extra: default 0; EmptySavedScore stays 0.
// DefaultSafe.

UCLASS()
class USaveGameTestObj : UObject
{
	UPROPERTY(SaveGame)
	int SavedScore;

	UPROPERTY(SaveGame)
	int EmptySavedScore = 0;
}

int Observe_SaveGame_DefaultZero()
{
	return 0;
}

int Observe_SaveGame_EmptyIndependent()
{
	int SavedScore = 0;
	int EmptySavedScore = 0;
	SavedScore = 12;
	return EmptySavedScore;
}
