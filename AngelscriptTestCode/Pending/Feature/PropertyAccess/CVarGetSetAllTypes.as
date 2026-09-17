/**
 * @version v1
 * @summary FConsoleVariable get/set for int, float, bool, and string. C++ substitutes unique names for the runner parameters. The named entries ReadWriteInt, ReadWriteFloat, ReadWriteBool, and ReadWriteString are part of the.
 * @topic Feature
 */
/**
 * @version root
 * @summary FConsoleVariable get/set for int, float, bool, and string. C++ substitutes unique names for the runner parameters. The named entries ReadWriteInt, ReadWriteFloat, ReadWriteBool, and ReadWriteString are part of the.
 * @topic Baseline
 */
namespace PropertyAccessTest
{
	/**
	 * Register an int CVar, check its default 5, then write 42.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.CVarGetSetAllTypes
	 * @Inputs the console variable name
	 * @Return 42 when the default was 5 and the write is visible, otherwise 0
	 * @Param IntName the CVar name supplied by the runner
	 */
	UFUNCTION()
	int ReadWriteInt(const FString&in IntName)
	{
		FConsoleVariable Var(IntName, 5, "Coverage int cvar");
		if (Var.GetInt() != 5)
		{
			return 0;
		}
		Var.SetInt(42);
		return Var.GetInt();
	}

	/**
	 * Register a float CVar, check its default 1.5, then write 3.25.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.CVarGetSetAllTypes
	 * @Inputs the console variable name
	 * @Return 3.25 when the default was 1.5 and the write is visible, otherwise 0
	 * @Param FloatName the CVar name supplied by the runner
	 */
	UFUNCTION()
	float ReadWriteFloat(const FString&in FloatName)
	{
		FConsoleVariable Var(FloatName, 1.5f, "Coverage float cvar");
		if (Math::Abs(Var.GetFloat() - 1.5f) > 0.001f)
		{
			return 0.0f;
		}
		Var.SetFloat(3.25f);
		return Var.GetFloat();
	}

	/**
	 * Register a bool CVar, check its default true, then write false.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.CVarGetSetAllTypes
	 * @Inputs the console variable name
	 * @Return 1 when the default was true and the write reads false, otherwise 0
	 * @Param BoolName the CVar name supplied by the runner
	 */
	UFUNCTION()
	int ReadWriteBool(const FString&in BoolName)
	{
		FConsoleVariable Var(BoolName, true, "Coverage bool cvar");
		if (!Var.GetBool())
		{
			return 0;
		}
		Var.SetBool(false);
		return Var.GetBool() ? 0 : 1;
	}

	/**
	 * Register a string CVar, check its default, then write UpdatedValue.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.CVarGetSetAllTypes
	 * @Inputs the console variable name
	 * @Return 1 when the default was DefaultValue and the write is visible, otherwise 0
	 * @Param StringName the CVar name supplied by the runner
	 */
	UFUNCTION()
	int ReadWriteString(const FString&in StringName)
	{
		FConsoleVariable Var(StringName, "DefaultValue", "Coverage string cvar");
		if (Var.GetString() != "DefaultValue")
		{
			return 0;
		}
		Var.SetString("UpdatedValue");
		return Var.GetString() == "UpdatedValue" ? 1 : 0;
	}

	/**
	 * Observe the int read/write path after rejecting an empty name.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.CVarGetSetAllTypes
	 * @Inputs a non-empty console variable name
	 * @Return ReadWriteInt of that name
	 * @Param IntName the CVar name supplied by the runner
	 */
	UFUNCTION()
	int ReadWriteIntNominal(const FString&in IntName)
	{
		if (IntName.Len() == 0)
		{
			throw("TS-FEAT-0016 setup: required IntName is empty");
		}
		return ReadWriteInt(IntName);
	}

	/**
	 * Observe the float read/write path after rejecting an empty name.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.CVarGetSetAllTypes
	 * @Inputs a non-empty console variable name
	 * @Return ReadWriteFloat of that name
	 * @Param FloatName the CVar name supplied by the runner
	 */
	UFUNCTION()
	float ReadWriteFloatNominal(const FString&in FloatName)
	{
		if (FloatName.Len() == 0)
		{
			throw("TS-FEAT-0016 setup: required FloatName is empty");
		}
		return ReadWriteFloat(FloatName);
	}

	/**
	 * Observe the bool read/write path after rejecting an empty name.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.CVarGetSetAllTypes
	 * @Inputs a non-empty console variable name
	 * @Return ReadWriteBool of that name
	 * @Param BoolName the CVar name supplied by the runner
	 */
	UFUNCTION()
	int ReadWriteBoolNominal(const FString&in BoolName)
	{
		if (BoolName.Len() == 0)
		{
			throw("TS-FEAT-0016 setup: required BoolName is empty");
		}
		return ReadWriteBool(BoolName);
	}

	/**
	 * Observe the string read/write path after rejecting an empty name.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.CVarGetSetAllTypes
	 * @Inputs a non-empty console variable name
	 * @Return ReadWriteString of that name
	 * @Param StringName the CVar name supplied by the runner
	 */
	UFUNCTION()
	int ReadWriteStringNominal(const FString&in StringName)
	{
		if (StringName.Len() == 0)
		{
			throw("TS-FEAT-0016 setup: required StringName is empty");
		}
		return ReadWriteString(StringName);
	}

	/**
	 * Observe the int CVar default before any SetInt.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.CVarGetSetAllTypes
	 * @Inputs a non-empty console variable name
	 * @Return 5, the registered default
	 * @Param IntName the CVar name supplied by the runner
	 * @Boundary default int 5
	 */
	UFUNCTION()
	int ReadWriteInt_DefaultFive(const FString&in IntName)
	{
		if (IntName.Len() == 0)
		{
			throw("TS-FEAT-0016 setup: required IntName is empty");
		}
		FConsoleVariable Var(IntName, 5, "Coverage int cvar");
		return Var.GetInt();
	}

	/**
	 * Observe SetInt(0) as a zero boundary.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.CVarGetSetAllTypes
	 * @Inputs a non-empty console variable name
	 * @Return 0 after SetInt(0)
	 * @Param IntName the CVar name supplied by the runner
	 * @Boundary SetInt(0)
	 */
	UFUNCTION()
	int ReadWriteInt_ZeroBoundary(const FString&in IntName)
	{
		if (IntName.Len() == 0)
		{
			throw("TS-FEAT-0016 setup: required IntName is empty");
		}
		FConsoleVariable Var(IntName, 0, "Coverage int cvar");
		Var.SetInt(0);
		return Var.GetInt();
	}
}
/** @end */
