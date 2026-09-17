/**
 * @version v1
 * @summary Declaration contexts for the string family: deferred locals, initialized locals, const locals, module-level const globals, and auto inference. Each validator returns a distinct non-zero code per failed context so a.
 * @topic Language
 */
/**
 * @version root
 * @summary Declaration contexts for the string family: deferred locals, initialized locals, const locals, module-level const globals, and auto inference. Each validator returns a distinct non-zero code per failed context so a.
 * @topic Baseline
 */
const FString GlobalString = "Global FString";
const FName GlobalName = n"GlobalName";
const FText GlobalText;

namespace LiteralsTest
{
	/**
	 * Validates every FString declaration context.
	 *
	 * @Covers Literals.FString
	 * @Inputs deferred, initialized, const, global and auto string declarations
	 * @Return 0 when all contexts hold; otherwise 10/20/30/40/50 naming the context
	 */
	int ValidateStringDeclarations()
	{
		FString DeferredString;
		if (DeferredString != "")
		{
			return 10;
		}

		FString DefaultString = "Local FString";
		if (DefaultString != "Local FString")
		{
			return 20;
		}

		const FString ConstString = "Const FString";
		if (ConstString != "Const FString")
		{
			return 30;
		}

		if (GlobalString != "Global FString")
		{
			return 40;
		}

		auto AutoString = "Auto FString";
		if (AutoString != "Auto FString")
		{
			return 50;
		}

		return 0;
	}

	/**
	 * Validates every FName declaration context.
	 *
	 * @Covers Literals.FString
	 * @Inputs deferred, initialized, const and global name declarations
	 * @Return 0 when all contexts hold; otherwise 10/20/30/40 naming the context
	 */
	int ValidateNameDeclarations()
	{
		FName DeferredName;
		if (DeferredName != NAME_None)
		{
			return 10;
		}

		FName DefaultName = n"LocalName";
		if (DefaultName != n"LocalName")
		{
			return 20;
		}

		const FName ConstName = n"ConstName";
		if (ConstName != n"ConstName")
		{
			return 30;
		}

		if (GlobalName != n"GlobalName")
		{
			return 40;
		}

		return 0;
	}

	/**
	 * Validates every FText declaration context.
	 *
	 * @Covers Literals.FString
	 * @Inputs deferred, initialized, const and global text declarations
	 * @Return 0 when all contexts hold; otherwise 10/20/30/40 naming the context
	 */
	int ValidateTextDeclarations()
	{
		FText DeferredText;
		if (!DeferredText.IsEmpty())
		{
			return 10;
		}

		FText DefaultText = FText::FromString("Local Text");
		if (DefaultText.ToString() != "Local Text")
		{
			return 20;
		}

		const FText ConstText = FText::FromString("Const Text");
		if (ConstText.ToString() != "Const Text")
		{
			return 30;
		}

		if (!GlobalText.IsEmpty())
		{
			return 40;
		}

		return 0;
	}

	/**
	 * Observe that all three validators report no failing context.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs the three declaration validators
	 * @Return true when all three return 0
	 */
	UFUNCTION()
	bool StringDeclarationContextsProduceExpectedValues()
	{
		if (ValidateStringDeclarations() != 0)
		{
			return false;
		}

		if (ValidateNameDeclarations() != 0)
		{
			return false;
		}

		return ValidateTextDeclarations() == 0;
	}

	/**
	 * Observe that all deferred declarations start at their empty value.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs deferred string, name and text locals
	 * @Return true when all three are empty
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool DeferredDeclarationEmptyBoundary()
	{
		FString DeferredString;
		FName DeferredName;
		FText DeferredText;

		if (DeferredString != "")
		{
			return false;
		}

		if (DeferredName != NAME_None)
		{
			return false;
		}

		return DeferredText.IsEmpty();
	}

	/**
	 * Observe that copying a global does not alias it.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs a copy of the module-level const string, then reassigned
	 * @Return true when the global is unchanged and the copy moved
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool GlobalCopyIndependence()
	{
		FString Copy = GlobalString;
		Copy = "Other";

		if (GlobalString != "Global FString")
		{
			return false;
		}

		return Copy == "Other";
	}
}
/** @end */
