/**
 * @version v1
 * @summary Observe ToSoftObjectPath and ToString on TSoftObjectPtr and TSoftClassPtr, including empty and live identities.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe ToSoftObjectPath and ToString on TSoftObjectPtr and TSoftClassPtr, including empty and live identities.
 * @topic Baseline
 */
// FString TSoftObjectPtr<T>.ToString() const;
// FSoftObjectPath TSoftClassPtr<T>.ToSoftObjectPath() const;
// FString TSoftClassPtr<T>.ToString() const;
// Inputs: Empty pointers, a pointer from a live actor CDO, and a class
// pointer from AActor::StaticClass().
// Expected observations: Empty ToString is empty and ToSoftObjectPath is
// null. Live ToSoftObjectPath equals FSoftObjectPath(LiveCdo) and ToString
// matches that path's string. Class ToSoftObjectPath is non-null.
// Boundary/ownership: Conversion does not load or mutate the referenced
// object. Returned paths are copies.

namespace TS_TSoftObjectPtr_ConversionAndFormatting_01
{
	bool Observe_ToSoftObjectPath_Nominal()
	{
		TSoftObjectPtr<UObject> Empty;
		FSoftObjectPath EmptyPath = Empty.ToSoftObjectPath();

		AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_TSoftObjectPtr_ConversionAndFormatting_01 setup: required AActor CDO is null");
		}
		FSoftObjectPath Expected(LiveCdo);
		TSoftObjectPtr<UObject> ObjectRef = LiveCdo;
		FSoftObjectPath ObjectPath = ObjectRef.ToSoftObjectPath();

		TSoftClassPtr<AActor> EmptyClass;
		FSoftObjectPath EmptyClassPath = EmptyClass.ToSoftObjectPath();
		TSoftClassPtr<AActor> ClassRef = AActor::StaticClass();
		FSoftObjectPath ClassPath = ClassRef.ToSoftObjectPath();

		return EmptyPath.IsNull() &&
			ObjectPath == Expected &&
			ObjectPath.IsValid() &&
			EmptyClassPath.IsNull() &&
			ClassPath.IsValid() &&
			!ClassPath.IsNull();
	}

	bool Observe_ToString_Nominal()
	{
		TSoftObjectPtr<UObject> Empty;
		FString EmptyText = Empty.ToString();
		AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_TSoftObjectPtr_ConversionAndFormatting_01 setup: required AActor CDO is null");
		}
		FSoftObjectPath Expected(LiveCdo);
		TSoftObjectPtr<UObject> ObjectRef = LiveCdo;
		FString ObjectText = ObjectRef.ToString();

		TSoftClassPtr<AActor> EmptyClass;
		FString EmptyClassText = EmptyClass.ToString();
		TSoftClassPtr<AActor> ClassRef = AActor::StaticClass();
		FString ClassText = ClassRef.ToString();

		return EmptyText.IsEmpty() &&
			ObjectText == Expected.ToString() &&
			EmptyClassText.IsEmpty() &&
			ClassText.Len() > 0;
	}
}
/** @end */
