/**
 * @version v1
 * @summary Observe UEnum.GenerateEnumPrefix for a reflected enum.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe UEnum.GenerateEnumPrefix for a reflected enum.
 * @topic Baseline
 */
// receiver boundary.
// Expected observations: The prefix string is non-empty for EAttachmentRule.
// Repeating the call returns the same text.
// Boundary/ownership: GenerateEnumPrefix returns a new FString. It does not
// mutate enumerator names. Missing UEnum is setup failure.

namespace TS_UEnum_Behavior_01
{
	bool Observe_GenerateEnumPrefix_Nominal()
	{
		UEnum EnumObject = Cast<UEnum>(FindObject("/Script/Engine.EAttachmentRule"));
		if (EnumObject is null)
		{
			throw("TS_UEnum_Behavior_01 setup: required EAttachmentRule UEnum is null");
		}
		FString Prefix = EnumObject.GenerateEnumPrefix();
		FString Repeated = EnumObject.GenerateEnumPrefix();
		return Prefix.Len() > 0 && Repeated == Prefix;
	}
}
/** @end */
