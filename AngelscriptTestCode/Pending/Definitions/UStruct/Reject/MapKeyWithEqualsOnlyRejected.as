/**
 * @version v1
 * @summary A USTRUCT TMap key that defines opEquals but not Hash is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A USTRUCT TMap key that defines opEquals but not Hash is rejected.
 * @topic Negative
 */
USTRUCT(BlueprintType)
struct FOnlyEqualsStructKey
{
	UPROPERTY()
	int Value = 0;

	/**
	 * Compare two keys by Value. Hash is intentionally absent so the map is rejected.
	 *
	 * @Kind CompileReject
	 * @Covers UStruct.MapKeyWithEqualsOnlyRejected
	 * @Inputs another FOnlyEqualsStructKey
	 * @Return true when Value matches
	 * @Param Other the other key
	 */
	bool opEquals(const FOnlyEqualsStructKey&in Other) const
	{
		return Value == Other.Value;
	}
}

UCLASS()
class ACoverageStructOnlyEqualsMapKeyActor : AActor
{
	UPROPERTY()
	TMap<FOnlyEqualsStructKey, int> Values;
}
/** @end */
