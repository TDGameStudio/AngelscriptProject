// Theme: Feature.Delegates. Positive preprocessor records event and delegate descriptors.
// C++: AngelscriptPreprocessorMacroShapeTests.cpp::DelegateDeclarationParsed
// sha256=db085fe61112eeebedc1aaeb107aff512125f19cedc675c63554d149d2957d27; lines 585-594.
// Oracle: Module->Delegates.Num() >= 1; source contains int Entry(); Entry returns 7.
// Extra: Entry is a constant 7 (no empty return path). DefaultSafe.

event void FOnHealthChanged(float NewHealth);

delegate void FOnDamageReceived(float Amount, AActor Instigator);

int Entry()
{
	return 7;
}

int Observe_DelegateDeclarationParsed_Entry()
{
	return Entry();
}

bool Observe_OnHealthChanged_DefaultUnbound()
{
	FOnHealthChanged Changed;
	return !Changed.IsBound();
}

bool Observe_OnDamageReceived_DefaultUnbound()
{
	FOnDamageReceived Received;
	return !Received.IsBound();
}
