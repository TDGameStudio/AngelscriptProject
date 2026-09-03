/**
 * The preprocessor records event and delegate descriptors. Entry returns 7 so
 * the module is executable; both declared types start unbound.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateDeclarationParsed
 * @Harness Function
 * @Tag Feature.Delegates.DelegateDeclarationParsed
 * @Namespace DelegatesTest
 * @Provenance Theme: Feature.Delegates. Positive preprocessor records event and delegate descriptors.
 * @Provenance C++: AngelscriptPreprocessorMacroShapeTests.cpp::DelegateDeclarationParsed
 * @Provenance sha256=db085fe61112eeebedc1aaeb107aff512125f19cedc675c63554d149d2957d27; lines 585-594.
 * @Provenance Oracle: Module->Delegates.Num() >= 1; source contains int Entry(); Entry returns 7.
 * @Provenance Extra: Entry is a constant 7 (no empty return path). DefaultSafe.
 */

/**
 * A multicast event that reports a new health value.
 *
 * @Covers Delegates.Declaration
 * @Inputs NewHealth
 * @Return nothing when broadcast
 */
event void FOnHealthChanged(float NewHealth);

/**
 * A unicast that reports damage amount and instigator.
 *
 * @Covers Delegates.Declaration
 * @Inputs Amount and Instigator
 * @Return nothing when executed
 */
delegate void FOnDamageReceived(float Amount, AActor Instigator);

namespace DelegatesTest
{
	/**
	 * The C++ execution oracle: a constant 7.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Inputs none
	 * @Return 7
	 */
	UFUNCTION()
	int Entry()
	{
		return 7;
	}

	/**
	 * Observe that Entry returns 7.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Inputs none
	 * @Return 7
	 */
	UFUNCTION()
	int DelegateDeclarationParsedEntry()
	{
		return Entry();
	}

	/**
	 * Observe that a default-constructed FOnHealthChanged is unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Inputs a local FOnHealthChanged
	 * @Return true when the local is unbound
	 * @Boundary default unbound
	 */
	UFUNCTION()
	bool OnHealthChangedDefaultUnbound()
	{
		FOnHealthChanged Changed;
		return !Changed.IsBound();
	}

	/**
	 * Observe that a default-constructed FOnDamageReceived is unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Inputs a local FOnDamageReceived
	 * @Return true when the local is unbound
	 * @Boundary default unbound
	 */
	UFUNCTION()
	bool OnDamageReceivedDefaultUnbound()
	{
		FOnDamageReceived Received;
		return !Received.IsBound();
	}
}
