// Purpose: Observe FSoftClassPath validity, null, asset, and subobject flags.
// Each function returns the exact comparison for the C++ runner.
// AS-facing API: bool FSoftClassPath.IsValid() const;
// bool FSoftClassPath.IsNull() const;
// bool FSoftClassPath.IsAsset() const;
// bool FSoftClassPath.IsSubobject() const;
// Inputs: Default-empty class path, a path from AActor::StaticClass(), and a
// string class path with a :Subobject suffix.
// Expected observations: Empty is null and not valid. AActor class path is
// valid and an asset. Subobject suffix reports IsSubobject true.
// Boundary/ownership: These queries inspect the stored path only. The
// diagnostic companion consumes a malformed class path without loading.

namespace TS_SoftObjectPath_Queries_02
{
	bool Observe_IsValid_Nominal()
	{
		FSoftClassPath Empty;
		FSoftClassPath ClassPath(AActor::StaticClass());
		return !Empty.IsValid() && ClassPath.IsValid();
	}

	bool Observe_IsNull_Nominal()
	{
		FSoftClassPath Empty;
		FSoftClassPath ClassPath(AActor::StaticClass());
		return Empty.IsNull() && !ClassPath.IsNull();
	}

	bool Observe_IsAsset_Nominal()
	{
		FSoftClassPath Empty;
		FSoftClassPath ClassPath(AActor::StaticClass());
		FSoftClassPath SubobjectPath("/Script/Engine.Actor:Default__Actor");
		return !Empty.IsAsset() && ClassPath.IsAsset() && !SubobjectPath.IsAsset();
	}

	bool Observe_IsSubobject_Nominal()
	{
		FSoftClassPath Empty;
		FSoftClassPath ClassPath(AActor::StaticClass());
		FSoftClassPath SubobjectPath("/Script/Engine.Actor:Default__Actor");
		return !Empty.IsSubobject() && !ClassPath.IsSubobject() && SubobjectPath.IsSubobject();
	}

	void ExerciseExpectedFailure()
	{
		FSoftClassPath Malformed("::::");
		bool bMalformedValid = Malformed.IsValid();
		bool bMalformedNull = Malformed.IsNull();
	}
}
