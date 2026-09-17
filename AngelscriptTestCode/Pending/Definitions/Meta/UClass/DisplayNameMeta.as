/**
 * @version v1
 * @summary DisplayName metadata on mixed property types. C++ reflects the DisplayName keys on FProperty. The observers cover the declared defaults, a zero HP write and an empty name with the inactive flag.
 * @topic Definitions
 */
/**
 * @version root
 * @summary DisplayName metadata on mixed property types. C++ reflects the DisplayName keys on FProperty. The observers cover the declared defaults, a zero HP write and an empty name with the inactive flag.
 * @topic Baseline
 */
UCLASS()
class ACoverageMetaDisplayNameActor : AActor
{
	UPROPERTY(meta = (DisplayName = "Health Points"))
	int HP = 100;

	UPROPERTY(meta = (DisplayName = "Movement Speed (m/s)"))
	float Speed = 5.0f;

	UPROPERTY(meta = (DisplayName = "Player Name"))
	FString PlayerName = "John";

	UPROPERTY(meta = (DisplayName = "Is Active?"))
	bool bActive = true;

	/**
	 * Observe the HP default.
	 *
	 * @Kind Observe
	 * @Covers Meta.DisplayNameMeta
	 * @Inputs none
	 * @Return 100
	 */
	UFUNCTION()
	int HPDefault()
	{
		return HP;
	}

	/**
	 * Observe the Speed default.
	 *
	 * @Kind Observe
	 * @Covers Meta.DisplayNameMeta
	 * @Inputs none
	 * @Return 5.0
	 */
	UFUNCTION()
	float SpeedDefault()
	{
		return Speed;
	}

	/**
	 * Observe the PlayerName default.
	 *
	 * @Kind Observe
	 * @Covers Meta.DisplayNameMeta
	 * @Inputs none
	 * @Return "John"
	 */
	UFUNCTION()
	FString PlayerNameDefault()
	{
		return PlayerName;
	}

	/**
	 * Observe the bActive default.
	 *
	 * @Kind Observe
	 * @Covers Meta.DisplayNameMeta
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool ActiveDefault()
	{
		return bActive;
	}

	/**
	 * Observe that writing zero HP is accepted.
	 *
	 * @Kind Observe
	 * @Covers Meta.DisplayNameMeta
	 * @Inputs none
	 * @Return 0
	 * @Boundary zero HP
	 */
	UFUNCTION()
	int ZeroHPBoundary()
	{
		HP = 0;
		return HP;
	}

	/**
	 * Observe that an empty name and inactive flag write back.
	 *
	 * @Kind Observe
	 * @Covers Meta.DisplayNameMeta
	 * @Inputs none
	 * @Return true when the name is empty and bActive is false
	 * @Boundary empty name and inactive
	 */
	UFUNCTION()
	bool EmptyNameAndInactive()
	{
		PlayerName = "";
		bActive = false;
		if (PlayerName.Len() != 0)
		{
			return false;
		}
		return !bActive;
	}
}
/** @end */
