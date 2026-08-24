// Theme: Feature.Delegates. Positive enum class + delegate + event + abstract UCLASS.
// C++: AngelscriptCompilerEndToEndTests.cpp::DelegateEnumClassCompile
// Oracle: FCompilerTransferDelegate is single-cast; FCompilerTransferEvent is multicast;
// UCompilerTransferObject is abstract; Score and GetScore exist.
// Extra: Alpha==0, Beta==4, Gamma after Beta. DefaultSafe.

UENUM(BlueprintType)
enum class ECompilerTransferState : uint16
{
	Alpha,
	Beta = 4,
	Gamma
}

delegate void FCompilerTransferDelegate(int Value);
event void FCompilerTransferEvent(UClass TypeValue, FString Label);

UCLASS(Abstract, BlueprintType)
class UCompilerTransferObject : UObject
{
	UPROPERTY()
	int Score;

	UFUNCTION()
	int GetScore()
	{
		return Score;
	}
}

int Observe_TransferState_AlphaDefault()
{
	return int(ECompilerTransferState::Alpha);
}

int Observe_TransferState_BetaBoundary()
{
	return int(ECompilerTransferState::Beta);
}

int Observe_TransferState_GammaAfterBeta()
{
	return int(ECompilerTransferState::Gamma);
}

bool Observe_TransferObject_EmptyDefaultIsNull()
{
	UCompilerTransferObject Obj;
	return Obj == nullptr;
}
