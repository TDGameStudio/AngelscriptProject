// Theme: Containers.TMap. NegativeDiagnostic: unbound UE TMap aliases.
// C++ CompileAndExpectFailure ASCoverageTMapUnsupportedApiAliases.
// Expected diagnostics: no matching signatures for GenerateKeyArray, GenerateValueArray,
// FindRef, FindChecked, Reserve, Shrink, Append, FilterByPredicate.
// Isolate the failing UCLASS. DiagnosticOnly.

UCLASS()
class ACoverageTMapUnsupportedApiActor : AActor
{
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TMap<int, FString> Values;
		TMap<int, FString> Other;
		TArray<int> Keys;
		TArray<FString> OutValues;
		Values.Add(1, "One");
		Values.GenerateKeyArray(Keys);
		Values.GenerateValueArray(OutValues);
		Values.FindRef(1);
		Values.FindChecked(1);
		Values.Reserve(8);
		Values.Shrink();
		Values.Append(Other);
		Values.FilterByPredicate(1);
	}
}
