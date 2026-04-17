#include "Core/AngelscriptUnversionedPropertySerializationTestTypes.h"

#include "UnversionedPropertySerialization.h"

#include "Hash/Blake3.h"
#include "Misc/AutomationTest.h"
#include "Misc/ConfigCacheIni.h"
#include "Misc/ScopeExit.h"
#include "Serialization/ArchiveProxy.h"
#include "Serialization/Formatters/BinaryArchiveFormatter.h"
#include "Serialization/MemoryReader.h"
#include "Serialization/MemoryWriter.h"
#include "Serialization/StructuredArchive.h"
#include "UObject/UnrealType.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Core_AngelscriptUnversionedPropertySerializationTests_Private
{
	enum class ESerializationPath : uint8
	{
		Versioned,
		Unversioned,
	};

	class FAngelscriptUnversionedPropertyTestArchive final : public FArchiveProxy
	{
	public:
		using FArchiveProxy::FArchiveProxy;

		virtual FArchive& operator<<(FName& Value) override
		{
			uint32 UnstableDisplayIndex = Value.GetDisplayIndex().ToUnstableInt();
			int32 Number = Value.GetNumber();
			InnerArchive << UnstableDisplayIndex << Number;

			if (IsLoading())
			{
				Value = FName::CreateFromDisplayId(FNameEntryId::FromUnstableInt(UnstableDisplayIndex), Number);
			}

			return *this;
		}
	};

	const TCHAR* ToString(const ESerializationPath Path)
	{
		return Path == ESerializationPath::Unversioned ? TEXT("unversioned") : TEXT("versioned");
	}

	UScriptStruct* GetFixtureStruct()
	{
		return FAngelscriptUnversionedPropertySerializationFixture::StaticStruct();
	}

	bool IsUnversionedPropertySerializationEnabled()
	{
		bool bEnabled = false;
		return GConfig->GetBool(TEXT("Core.System"), TEXT("CanUseUnversionedPropertySerialization"), bEnabled, GEngineIni) && bEnabled;
	}

	FAngelscriptUnversionedPropertySerializationFixture MakeNonDefaultFixture()
	{
		FAngelscriptUnversionedPropertySerializationFixture Fixture;
		Fixture.Count = 97;
		Fixture.bEnabled = true;
		Fixture.Label = TEXT("RoundTripFixture");
		Fixture.Values = { 7, 0, 42, -9 };
		return Fixture;
	}

	bool ExpectFixtureEquals(
		FAutomationTestBase& Test,
		const TCHAR* Context,
		const FAngelscriptUnversionedPropertySerializationFixture& Actual,
		const FAngelscriptUnversionedPropertySerializationFixture& Expected)
	{
		bool bOk = true;
		bOk &= Test.TestEqual(
			*FString::Printf(TEXT("%s should preserve Count"), Context),
			Actual.Count,
			Expected.Count);
		bOk &= Test.TestEqual(
			*FString::Printf(TEXT("%s should preserve bEnabled"), Context),
			Actual.bEnabled,
			Expected.bEnabled);
		bOk &= Test.TestEqual(
			*FString::Printf(TEXT("%s should preserve Label"), Context),
			Actual.Label,
			Expected.Label);
		bOk &= Test.TestEqual(
			*FString::Printf(TEXT("%s should preserve Values.Num"), Context),
			Actual.Values.Num(),
			Expected.Values.Num());

		const int32 SharedValueCount = FMath::Min(Actual.Values.Num(), Expected.Values.Num());
		for (int32 Index = 0; Index < SharedValueCount; ++Index)
		{
			bOk &= Test.TestEqual(
				*FString::Printf(TEXT("%s should preserve Values[%d]"), Context, Index),
				Actual.Values[Index],
				Expected.Values[Index]);
		}

		return bOk;
	}

	void SaveFixture(
		const ESerializationPath Path,
		const FAngelscriptUnversionedPropertySerializationFixture& Source,
		const FAngelscriptUnversionedPropertySerializationFixture& Defaults,
		TArray<uint8>& OutBytes)
	{
		FAngelscriptUnversionedPropertySerializationFixture MutableSource = Source;
		FAngelscriptUnversionedPropertySerializationFixture MutableDefaults = Defaults;
		UScriptStruct* Struct = GetFixtureStruct();

		OutBytes.Reset();

		FMemoryWriter Writer(OutBytes);
		Writer.SetUseUnversionedPropertySerialization(Path == ESerializationPath::Unversioned);

		FAngelscriptUnversionedPropertyTestArchive Linker(Writer);
		FBinaryArchiveFormatter Formatter(Linker);
		FStructuredArchive StructuredArchive(Formatter);
		FStructuredArchive::FSlot Slot = StructuredArchive.Open();

		if (Path == ESerializationPath::Unversioned)
		{
			SerializeUnversionedProperties(
				Struct,
				Slot,
				reinterpret_cast<uint8*>(&MutableSource),
				Struct,
				reinterpret_cast<uint8*>(&MutableDefaults));
		}
		else
		{
			Struct->SerializeTaggedProperties(
				Slot,
				reinterpret_cast<uint8*>(&MutableSource),
				Struct,
				reinterpret_cast<uint8*>(&MutableDefaults));
		}
	}

	bool LoadFixture(
		FAutomationTestBase& Test,
		const TCHAR* Context,
		const ESerializationPath Path,
		const TArray<uint8>& Bytes,
		const FAngelscriptUnversionedPropertySerializationFixture& Defaults,
		FAngelscriptUnversionedPropertySerializationFixture& OutLoaded)
	{
		FAngelscriptUnversionedPropertySerializationFixture MutableDefaults = Defaults;
		UScriptStruct* Struct = GetFixtureStruct();

		FMemoryReader Reader(Bytes);
		Reader.SetUseUnversionedPropertySerialization(Path == ESerializationPath::Unversioned);

		FAngelscriptUnversionedPropertyTestArchive Linker(Reader);
		FBinaryArchiveFormatter Formatter(Linker);
		FStructuredArchive StructuredArchive(Formatter);
		FStructuredArchive::FSlot Slot = StructuredArchive.Open();

		TGuardValue<bool> SavingPackageGuard(GIsSavingPackage, false);
		OutLoaded = FAngelscriptUnversionedPropertySerializationFixture();

		if (Path == ESerializationPath::Unversioned)
		{
			SerializeUnversionedProperties(
				Struct,
				Slot,
				reinterpret_cast<uint8*>(&OutLoaded),
				Struct,
				reinterpret_cast<uint8*>(&MutableDefaults));
		}
		else
		{
			Struct->UStruct::SerializeTaggedProperties(
				Slot,
				reinterpret_cast<uint8*>(&OutLoaded),
				Struct,
				reinterpret_cast<uint8*>(&MutableDefaults));
		}

		return Test.TestEqual(
			*FString::Printf(TEXT("%s should consume the entire %s payload"), Context, ToString(Path)),
			Reader.Tell(),
			static_cast<int64>(Bytes.Num()));
	}

	bool ExpectRoundTrip(
		FAutomationTestBase& Test,
		const TCHAR* Context,
		const ESerializationPath Path,
		const FAngelscriptUnversionedPropertySerializationFixture& Source,
		const FAngelscriptUnversionedPropertySerializationFixture& Defaults)
	{
		TArray<uint8> Payload;
		SaveFixture(Path, Source, Defaults, Payload);

		bool bOk = Test.TestTrue(
			*FString::Printf(TEXT("%s should produce a non-empty %s payload"), Context, ToString(Path)),
			Payload.Num() > 0);

		FAngelscriptUnversionedPropertySerializationFixture Loaded;
		bOk &= LoadFixture(Test, Context, Path, Payload, Defaults, Loaded);
		bOk &= ExpectFixtureEquals(Test, Context, Loaded, Source);
		return bOk;
	}
}

using namespace AngelscriptTest_Core_AngelscriptUnversionedPropertySerializationTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptUnversionedPropertySerializationRoundTripTest,
	"Angelscript.TestModule.Engine.UnversionedPropertySerialization.RoundTripsAndRebuildsSchemaCache",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptUnversionedPropertySerializationRoundTripTest::RunTest(const FString& Parameters)
{
	if (!TestTrue(
			TEXT("Automation environment should enable unversioned property serialization"),
			IsUnversionedPropertySerializationEnabled()))
	{
		return false;
	}

	UScriptStruct* Struct = GetFixtureStruct();
	DestroyAngelscriptUnversionedSchema(Struct);
	ON_SCOPE_EXIT
	{
		DestroyAngelscriptUnversionedSchema(Struct);
	};

	const FAngelscriptUnversionedPropertySerializationFixture Defaults;
	const FAngelscriptUnversionedPropertySerializationFixture NonDefault = MakeNonDefaultFixture();

	bool bOk = true;
	bOk &= ExpectRoundTrip(*this, TEXT("Versioned default fixture"), ESerializationPath::Versioned, Defaults, Defaults);
	bOk &= ExpectRoundTrip(*this, TEXT("Versioned non-default fixture"), ESerializationPath::Versioned, NonDefault, Defaults);
	bOk &= ExpectRoundTrip(*this, TEXT("Unversioned default fixture"), ESerializationPath::Unversioned, Defaults, Defaults);
	bOk &= ExpectRoundTrip(*this, TEXT("Unversioned non-default fixture"), ESerializationPath::Unversioned, NonDefault, Defaults);

#if WITH_EDITORONLY_DATA
	const FBlake3Hash SchemaHashBeforeDestroy = GetSchemaHash(Struct, false);
#endif

	DestroyAngelscriptUnversionedSchema(Struct);

#if WITH_EDITORONLY_DATA
	const FBlake3Hash SchemaHashAfterDestroy = GetSchemaHash(Struct, false);
	bOk &= TestTrue(
		TEXT("Schema hash should stay stable across cache destruction"),
		SchemaHashBeforeDestroy == SchemaHashAfterDestroy);
#endif

	bOk &= ExpectRoundTrip(*this, TEXT("Unversioned default fixture after schema rebuild"), ESerializationPath::Unversioned, Defaults, Defaults);
	bOk &= ExpectRoundTrip(*this, TEXT("Unversioned non-default fixture after schema rebuild"), ESerializationPath::Unversioned, NonDefault, Defaults);
	return bOk;
}

#endif
