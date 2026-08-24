// Theme: Language.Syntax.Comments. Positive: comment markers inside default string literals stay data.
// C++: AngelscriptCompilerPropertyDefaultTests.cpp::StringDefaultPreservesCommentMarkersInsideLiteral
// sha256=8a3bddd2c55984798636cd0aed6a2abec64735cc0c3b82e2d2c6fae04b92a076; lines 142-167.
// Oracle: VerifyDefaults() == 42; Message is He said "//not a comment"; BlockText is /*literal*/.
// Extra: empty constructed FString is not those literals. DefaultSafe.

UCLASS()
class UCompilerStringDefaultCarrier : UObject
{
	UPROPERTY()
	FString Message;

	UPROPERTY()
	FString BlockText;

	default Message = "He said \"//not a comment\"";
	default BlockText = "/*literal*/";

	UFUNCTION()
	int VerifyDefaults()
	{
		if (!(Message == "He said \"//not a comment\""))
			return 10;

		if (!(BlockText == "/*literal*/"))
			return 20;

		return 42;
	}
}

bool Observe_VerifyDefaults_Nominal()
{
	UCompilerStringDefaultCarrier Carrier =
		Cast<UCompilerStringDefaultCarrier>(
			NewObject(GetTransientPackage(), UCompilerStringDefaultCarrier::StaticClass(), n"CompilerStringDefaultCarrier"));
	if (Carrier == nullptr)
	{
		throw("TS-LANG-0040 setup: NewObject returned null");
	}
	return Carrier.VerifyDefaults() == 42 && Carrier.Message == "He said \"//not a comment\"" && Carrier.BlockText == "/*literal*/";
}

bool Observe_StringDefaults_EmptyBoundary()
{
	FString Empty;
	return Empty.Len() == 0 && Empty != "He said \"//not a comment\"" && Empty != "/*literal*/";
}
