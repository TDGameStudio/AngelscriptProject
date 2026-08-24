// Purpose: Observe package/asset name, validity, pending, null, and Get on
// TSoftObjectPtr plus the matching TSoftClassPtr queries except IsNull/Get.
// AS-facing API: FString TSoftObjectPtr<T>.GetLongPackageName() const;
// FString TSoftObjectPtr<T>.GetAssetName() const;
// bool TSoftObjectPtr<T>.IsValid() const;
// bool TSoftObjectPtr<T>.IsPending() const;
// bool TSoftObjectPtr<T>.IsNull() const;
// T TSoftObjectPtr<T>.Get() const;
// FString TSoftClassPtr<T>.GetLongPackageName() const;
// FString TSoftClassPtr<T>.GetAssetName() const;
// bool TSoftClassPtr<T>.IsValid() const;
// bool TSoftClassPtr<T>.IsPending() const;
// Inputs: Empty pointers, live actor CDO / AActor class, and a missing
// package path as pending. Actor LoadAsync is the diagnostic throw.
// Expected observations: Empty IsNull true, Get null, names empty. Live CDO
// IsValid true, IsPending false, Get matches identity. Missing path IsPending
// true and Get null. Live class ptr IsValid true.
// Boundary/ownership: Get does not load. Actor/component LoadAsync throws.

namespace TS_TSoftObjectPtr_Queries_01
{
	bool Observe_GetLongPackageName_Nominal()
	{
		TSoftObjectPtr<UObject> Empty;
		FString EmptyPackage = Empty.GetLongPackageName();
		AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_TSoftObjectPtr_Queries_01 setup: required AActor CDO is null");
		}
		TSoftObjectPtr<UObject> ObjectRef = LiveCdo;
		FString ObjectPackage = ObjectRef.GetLongPackageName();

		TSoftClassPtr<AActor> EmptyClass;
		FString EmptyClassPackage = EmptyClass.GetLongPackageName();
		TSoftClassPtr<AActor> ClassRef = AActor::StaticClass();
		FString ClassPackage = ClassRef.GetLongPackageName();

		return EmptyPackage.IsEmpty() &&
			ObjectPackage.Len() > 0 &&
			EmptyClassPackage.IsEmpty() &&
			ClassPackage.Len() > 0;
	}

	bool Observe_GetAssetName_Nominal()
	{
		TSoftObjectPtr<UObject> Empty;
		FString EmptyName = Empty.GetAssetName();
		AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_TSoftObjectPtr_Queries_01 setup: required AActor CDO is null");
		}
		TSoftObjectPtr<UObject> ObjectRef = LiveCdo;
		FString ObjectName = ObjectRef.GetAssetName();

		TSoftClassPtr<AActor> EmptyClass;
		FString EmptyClassName = EmptyClass.GetAssetName();
		TSoftClassPtr<AActor> ClassRef = AActor::StaticClass();
		FString ClassName = ClassRef.GetAssetName();

		return EmptyName.IsEmpty() &&
			ObjectName.Len() > 0 &&
			EmptyClassName.IsEmpty() &&
			ClassName.Len() > 0;
	}

	bool Observe_IsValid_Nominal()
	{
		TSoftObjectPtr<UObject> Empty;
		AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_TSoftObjectPtr_Queries_01 setup: required AActor CDO is null");
		}
		TSoftObjectPtr<UObject> ObjectRef = LiveCdo;
		TSoftObjectPtr<UObject> Missing(FSoftObjectPath("/Game/DoesNotExist.DoesNotExist"));
		TSoftClassPtr<AActor> EmptyClass;
		TSoftClassPtr<AActor> ClassRef = AActor::StaticClass();
		TSoftClassPtr<AActor> MissingClass(FSoftObjectPath("/Game/DoesNotExist.DoesNotExist"));
		return !Empty.IsValid() &&
			ObjectRef.IsValid() &&
			!Missing.IsValid() &&
			!EmptyClass.IsValid() &&
			ClassRef.IsValid() &&
			!MissingClass.IsValid();
	}

	bool Observe_IsPending_Nominal()
	{
		TSoftObjectPtr<UObject> Empty;
		AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_TSoftObjectPtr_Queries_01 setup: required AActor CDO is null");
		}
		TSoftObjectPtr<UObject> ObjectRef = LiveCdo;
		TSoftObjectPtr<UObject> Missing(FSoftObjectPath("/Game/DoesNotExist.DoesNotExist"));
		TSoftClassPtr<AActor> EmptyClass;
		TSoftClassPtr<AActor> ClassRef = AActor::StaticClass();
		TSoftClassPtr<AActor> MissingClass(FSoftObjectPath("/Game/DoesNotExist.DoesNotExist"));
		return !Empty.IsPending() &&
			!ObjectRef.IsPending() &&
			Missing.IsPending() &&
			!EmptyClass.IsPending() &&
			!ClassRef.IsPending() &&
			MissingClass.IsPending();
	}

	bool Observe_IsNull_Nominal()
	{
		TSoftObjectPtr<UObject> Empty;
		AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_TSoftObjectPtr_Queries_01 setup: required AActor CDO is null");
		}
		TSoftObjectPtr<UObject> ObjectRef = LiveCdo;
		TSoftObjectPtr<UObject> Missing(FSoftObjectPath("/Game/DoesNotExist.DoesNotExist"));
		return Empty.IsNull() && !ObjectRef.IsNull() && !Missing.IsNull();
	}

	bool Observe_Get_Nominal()
	{
		TSoftObjectPtr<UObject> Empty;
		UObject EmptyGot = Empty.Get();
		AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_TSoftObjectPtr_Queries_01 setup: required AActor CDO is null");
		}
		TSoftObjectPtr<UObject> ObjectRef = LiveCdo;
		UObject Got = ObjectRef.Get();
		TSoftObjectPtr<UObject> Missing(FSoftObjectPath("/Game/DoesNotExist.DoesNotExist"));
		UObject MissingGot = Missing.Get();
		return EmptyGot == nullptr && Got == LiveCdo && MissingGot == nullptr;
	}

	void ExerciseExpectedFailure()
	{
		AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		TSoftObjectPtr<AActor> ActorRef = LiveCdo;
		FOnSoftObjectLoaded OnLoaded;
		ActorRef.LoadAsync(OnLoaded);
	}
}
