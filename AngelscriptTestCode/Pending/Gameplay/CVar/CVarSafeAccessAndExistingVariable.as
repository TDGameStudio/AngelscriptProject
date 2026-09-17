/**
 * @version v1
 * @summary Reusing an existing native console variable versus registering a generated fallback. C++ substitutes unique names for the arguments, so the entry names ReadExisting, UpdateExisting and SafeFallback are part of the.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Reusing an existing native console variable versus registering a generated fallback. C++ substitutes unique names for the arguments, so the entry names ReadExisting, UpdateExisting and SafeFallback are part of the.
 * @topic Baseline
 */
namespace CVarTest
{
	/**
	 * Read an existing native console variable through FConsoleVariable.
	 *
	 * @Kind Observe
	 * @Covers CVar.CVarSafeAccessAndExistingVariable
	 * @Inputs the existing variable name
	 * @Return the integer stored on that variable
	 * @Param ExistingName the native CVar name supplied by C++
	 */
	UFUNCTION()
	int ReadExisting(const FString&in ExistingName)
	{
		FConsoleVariable Var(ExistingName, 99, "Should reuse existing native variable");
		return Var.GetInt();
	}

	/**
	 * Write 21 onto an existing native console variable and read it back.
	 *
	 * @Kind Observe
	 * @Covers CVar.CVarSafeAccessAndExistingVariable
	 * @Inputs the existing variable name
	 * @Return 21 when the write is visible
	 * @Param ExistingName the native CVar name supplied by C++
	 */
	UFUNCTION()
	int UpdateExisting(const FString&in ExistingName)
	{
		FConsoleVariable Var(ExistingName, 99, "Should reuse existing native variable");
		Var.SetInt(21);
		return Var.GetInt();
	}

	/**
	 * Register a generated fallback CVar, check its default, then write 456.
	 *
	 * @Kind Observe
	 * @Covers CVar.CVarSafeAccessAndExistingVariable
	 * @Inputs a missing name that should be created
	 * @Return 1 when the default is 123 and the write reads 456, otherwise 0
	 * @Param Missing the generated name, which may be empty
	 */
	UFUNCTION()
	int SafeFallback(const FString&in Missing)
	{
		FConsoleVariable MissingVar(Missing, 123, "Generated fallback");
		if (MissingVar.GetInt() != 123)
		{
			return 0;
		}
		MissingVar.SetInt(456);
		return MissingVar.GetInt() == 456 ? 1 : 0;
	}

	/**
	 * Observe that reuse, update and fallback all match the oracle.
	 *
	 * @Kind Observe
	 * @Covers CVar.CVarSafeAccessAndExistingVariable
	 * @Inputs an existing name and a generated name
	 * @Return true when ReadExisting is 7, UpdateExisting is 21 and SafeFallback is 1
	 * @Param ExistingName the native CVar name
	 * @Param GeneratedName the fallback name
	 */
	UFUNCTION()
	bool SafeAccessNominal(const FString&in ExistingName, const FString&in GeneratedName)
	{
		if (ExistingName.Len() == 0)
		{
			throw("TS-GAME-0003 setup: required ExistingName is empty");
		}
		if (ReadExisting(ExistingName) != 7)
		{
			return false;
		}
		if (UpdateExisting(ExistingName) != 21)
		{
			return false;
		}
		return SafeFallback(GeneratedName) == 1;
	}

	/**
	 * Observe that an empty generated name still registers the fallback.
	 *
	 * @Kind Observe
	 * @Covers CVar.CVarSafeAccessAndExistingVariable
	 * @Inputs an empty generated name
	 * @Return true when SafeFallback of "" is 1
	 * @Boundary empty generated name
	 */
	UFUNCTION()
	bool EmptyGeneratedFallback()
	{
		return SafeFallback("") == 1;
	}
}
/** @end */
