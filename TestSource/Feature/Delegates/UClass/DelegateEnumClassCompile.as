/**
 * An enum class plus a unicast, a multicast, and an abstract UCLASS. Alpha is
 * 0, Beta is 4, and Gamma follows Beta. FCompilerTransferDelegate is
 * single-cast; FCompilerTransferEvent is multicast; Score and GetScore exist.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateEnumClassCompile
 * @Harness UClass
 * @Tag Feature.Delegates.DelegateEnumClassCompile
 * @Provenance Theme: Feature.Delegates. Positive enum class + delegate + event + abstract UCLASS.
 * @Provenance C++: AngelscriptCompilerEndToEndTests.cpp::DelegateEnumClassCompile
 * @Provenance Oracle: FCompilerTransferDelegate is single-cast; FCompilerTransferEvent is multicast;
 * @Provenance UCompilerTransferObject is abstract; Score and GetScore exist.
 * @Provenance Extra: Alpha==0, Beta==4, Gamma after Beta. DefaultSafe.
 */

UENUM(BlueprintType)
enum class ECompilerTransferState : uint16
{
	Alpha,
	Beta = 4,
	Gamma
}

/**
 * A unicast that takes an int.
 *
 * @Covers Delegates.Declaration
 * @Inputs Value
 * @Return nothing when executed
 */
delegate void FCompilerTransferDelegate(int Value);

/**
 * A multicast that takes a UClass and a label.
 *
 * @Covers Delegates.Declaration
 * @Inputs TypeValue and Label
 * @Return nothing when broadcast
 */
event void FCompilerTransferEvent(UClass TypeValue, FString Label);

UCLASS(Abstract, BlueprintType)
class UCompilerTransferObject : UObject
{
	UPROPERTY()
	int Score;

	/**
	 * Returns Score.
	 *
	 * @Covers Delegates.Declaration
	 * @Inputs none
	 * @Return Score
	 */
	UFUNCTION()
	int GetScore()
	{
		return Score;
	}

	/**
	 * Observe that Alpha is 0.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Inputs ECompilerTransferState::Alpha
	 * @Return 0
	 * @Boundary Alpha default
	 */
	UFUNCTION()
	int AlphaDefault()
	{
		return int(ECompilerTransferState::Alpha);
	}

	/**
	 * Observe that Beta is 4.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Inputs ECompilerTransferState::Beta
	 * @Return 4
	 * @Boundary Beta
	 */
	UFUNCTION()
	int BetaBoundary()
	{
		return int(ECompilerTransferState::Beta);
	}

	/**
	 * Observe that Gamma follows Beta.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Inputs ECompilerTransferState::Gamma
	 * @Return int(Gamma)
	 */
	UFUNCTION()
	int GammaAfterBeta()
	{
		return int(ECompilerTransferState::Gamma);
	}

	/**
	 * Observe that a default-constructed handle is null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Inputs a local UCompilerTransferObject
	 * @Return true when the handle is null
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		UCompilerTransferObject Obj;
		return Obj == nullptr;
	}
}
