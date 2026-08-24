// Theme: Feature.PropertyAccess. Positive FConsoleVariable get/set for all types.
// C++: AngelscriptCoverageCVarTests.cpp::CVarGetSetAllTypes
// $ARG0$..$ARG3$ become runner name parameters. Oracle: ReadWriteInt==42,
// ReadWriteFloat==3.25f, ReadWriteBool==1, ReadWriteString==1.
// Extra: default int 5; SetInt(0) boundary; empty name is setup failure.
// DefaultSafe. Runner owns console names.

int ReadWriteInt(const FString& IntName)
{
	FConsoleVariable Var(IntName, 5, "Coverage int cvar");
	if (Var.GetInt() != 5)
	{
		return 0;
	}
	Var.SetInt(42);
	return Var.GetInt();
}

float ReadWriteFloat(const FString& FloatName)
{
	FConsoleVariable Var(FloatName, 1.5f, "Coverage float cvar");
	if (Math::Abs(Var.GetFloat() - 1.5f) > 0.001f)
	{
		return 0.0f;
	}
	Var.SetFloat(3.25f);
	return Var.GetFloat();
}

int ReadWriteBool(const FString& BoolName)
{
	FConsoleVariable Var(BoolName, true, "Coverage bool cvar");
	if (!Var.GetBool())
	{
		return 0;
	}
	Var.SetBool(false);
	return Var.GetBool() ? 0 : 1;
}

int ReadWriteString(const FString& StringName)
{
	FConsoleVariable Var(StringName, "DefaultValue", "Coverage string cvar");
	if (Var.GetString() != "DefaultValue")
	{
		return 0;
	}
	Var.SetString("UpdatedValue");
	return Var.GetString() == "UpdatedValue" ? 1 : 0;
}

int Observe_ReadWriteInt_Nominal(const FString& IntName)
{
	if (IntName.Len() == 0)
	{
		throw("TS-FEAT-0016 setup: required IntName is empty");
	}
	return ReadWriteInt(IntName);
}

float Observe_ReadWriteFloat_Nominal(const FString& FloatName)
{
	if (FloatName.Len() == 0)
	{
		throw("TS-FEAT-0016 setup: required FloatName is empty");
	}
	return ReadWriteFloat(FloatName);
}

int Observe_ReadWriteBool_Nominal(const FString& BoolName)
{
	if (BoolName.Len() == 0)
	{
		throw("TS-FEAT-0016 setup: required BoolName is empty");
	}
	return ReadWriteBool(BoolName);
}

int Observe_ReadWriteString_Nominal(const FString& StringName)
{
	if (StringName.Len() == 0)
	{
		throw("TS-FEAT-0016 setup: required StringName is empty");
	}
	return ReadWriteString(StringName);
}

int Observe_ReadWriteInt_DefaultFive(const FString& IntName)
{
	if (IntName.Len() == 0)
	{
		throw("TS-FEAT-0016 setup: required IntName is empty");
	}
	FConsoleVariable Var(IntName, 5, "Coverage int cvar");
	return Var.GetInt();
}

int Observe_ReadWriteInt_ZeroBoundary(const FString& IntName)
{
	if (IntName.Len() == 0)
	{
		throw("TS-FEAT-0016 setup: required IntName is empty");
	}
	FConsoleVariable Var(IntName, 0, "Coverage int cvar");
	Var.SetInt(0);
	return Var.GetInt();
}
