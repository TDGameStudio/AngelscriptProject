/**
 * @version v1
 * @summary HotReload VersionPair Version_01. Provider struct Value=1.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Version_01. Provider struct Value=1.
 * @topic Baseline
 */
USTRUCT()
struct FHotReloadDependencyPayload
{
	UPROPERTY()
	int Value = 1;
}
/** @end */
/**
 * @version version-02
 * @parent root
 * @summary HotReload VersionPair Version_02. Consumer ReadPayload Value only.
 * @topic HotReload
 */
import HotReload.Dependency.HotReloadDependencyProvider;

UCLASS()
class UHotReloadDependencyConsumer : UObject
{
	/** ReadPayload: exercises the read payload behaviour. */
	UFUNCTION()
	int ReadPayload(FHotReloadDependencyPayload Payload)
	{
		return Payload.Value;
	}
}
/** @end */
/**
 * @version version-03
 * @parent root
 * @summary HotReload VersionPair Version_03. Provider struct gains Bonus=2.
 * @topic HotReload
 */
USTRUCT()
struct FHotReloadDependencyPayload
{
	UPROPERTY()
	int Value = 1;

	UPROPERTY()
	int Bonus = 2;
}
/** @end */
/**
 * @version version-04
 * @parent root
 * @summary HotReload VersionPair Version_04. Consumer retargets to provider V2 struct.
 * @topic HotReload
 */
import HotReload.Dependency.HotReloadDependencyProvider;

UCLASS()
class UHotReloadDependencyConsumer : UObject
{
	/** ReadPayload: exercises the read payload behaviour. */
	UFUNCTION()
	int ReadPayload(FHotReloadDependencyPayload Payload)
	{
		return Payload.Value + Payload.Bonus;
	}
}
/** @end */
