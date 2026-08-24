// Purpose: Observe UEnum.GenerateEnumPrefix for a reflected enum.
// AS-facing API: FString UEnum.GenerateEnumPrefix() const;
// Inputs: UEnum for EAttachmentRule and a null UEnum handle as the empty
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
