#include "Shared/AngelscriptDebuggerTestClient.h"
#include "Shared/AngelscriptDebuggerTestSession.h"

#include "Core/AngelscriptEngine.h"
#include "Core/AngelscriptSettings.h"
#include "Dom/JsonObject.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "Serialization/JsonReader.h"
#include "Serialization/JsonSerializer.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Debugger_AngelscriptDebuggerDatabaseTests_Private
{
	bool StartDatabaseDebuggerSession(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		FAngelscriptDebuggerTestClient& Client)
	{
		FAngelscriptDebuggerSessionConfig SessionConfig;
		// UE 5.7: headless has no production subsystem. Let Initialize() create
		// an isolated FAngelscriptEngine with its own FAngelscriptDebugServer.
		SessionConfig.DefaultTimeoutSeconds = 45.0f;

		if (!Test.TestTrue(TEXT("Debugger database protocol should initialize the debugger session"), Session.Initialize(SessionConfig)))
		{
			return false;
		}

		if (!Test.TestTrue(TEXT("Debugger database protocol should connect the debugger client"), Client.Connect(TEXT("127.0.0.1"), Session.GetPort())))
		{
			Test.AddError(Client.GetLastError());
			return false;
		}

		bool bSentStartDebugging = false;
		const bool bStartMessageSent = Session.PumpUntil(
			[&Client, &bSentStartDebugging]()
			{
				if (bSentStartDebugging)
				{
					return true;
				}

				bSentStartDebugging = Client.SendStartDebugging(2);
				return bSentStartDebugging;
			},
			Session.GetDefaultTimeoutSeconds());

		if (!Test.TestTrue(TEXT("Debugger database protocol should send StartDebugging"), bStartMessageSent))
		{
			Test.AddError(Client.GetLastError());
			return false;
		}

		TOptional<FAngelscriptDebugMessageEnvelope> VersionEnvelope;
		const bool bReceivedVersion = Session.PumpUntil(
			[&Client, &VersionEnvelope]()
			{
				if (VersionEnvelope.IsSet())
				{
					return true;
				}

				TOptional<FAngelscriptDebugMessageEnvelope> Envelope = Client.ReceiveEnvelope();
				if (Envelope.IsSet() && Envelope->MessageType == EDebugMessageType::DebugServerVersion)
				{
					VersionEnvelope = MoveTemp(Envelope);
					return true;
				}

				return false;
			},
			Session.GetDefaultTimeoutSeconds());

		if (!Test.TestTrue(TEXT("Debugger database protocol should receive the DebugServerVersion handshake"), bReceivedVersion))
		{
			Test.AddError(Client.GetLastError());
			return false;
		}

		return true;
	}

	int32 CountMessagesOfType(const TArray<FAngelscriptDebugMessageEnvelope>& Messages, EDebugMessageType MessageType)
	{
		int32 Count = 0;
		for (const FAngelscriptDebugMessageEnvelope& Envelope : Messages)
		{
			if (Envelope.MessageType == MessageType)
			{
				++Count;
			}
		}
		return Count;
	}

	int32 FindFirstMessageIndex(const TArray<FAngelscriptDebugMessageEnvelope>& Messages, EDebugMessageType MessageType)
	{
		for (int32 Index = 0; Index < Messages.Num(); ++Index)
		{
			if (Messages[Index].MessageType == MessageType)
			{
				return Index;
			}
		}
		return INDEX_NONE;
	}

	bool IsAssetDatabaseMessageType(EDebugMessageType MessageType)
	{
		return MessageType == EDebugMessageType::AssetDatabaseInit
			|| MessageType == EDebugMessageType::AssetDatabase
			|| MessageType == EDebugMessageType::AssetDatabaseFinished;
	}

	int32 FindFirstAssetDatabaseMessageIndex(const TArray<FAngelscriptDebugMessageEnvelope>& Messages)
	{
		for (int32 Index = 0; Index < Messages.Num(); ++Index)
		{
			if (IsAssetDatabaseMessageType(Messages[Index].MessageType))
			{
				return Index;
			}
		}
		return INDEX_NONE;
	}

	bool ParseJsonObject(const FString& JsonString, TSharedPtr<FJsonObject>& OutObject)
	{
		const TSharedRef<TJsonReader<>> Reader = TJsonReaderFactory<>::Create(JsonString);
		return FJsonSerializer::Deserialize(Reader, OutObject) && OutObject.IsValid();
	}
}

using namespace AngelscriptTest_Debugger_AngelscriptDebuggerDatabaseTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerDatabaseRequestDebugDatabaseSequenceTest,
	"Angelscript.TestModule.Debugger.Database.RequestDebugDatabaseSequence",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebuggerDatabaseRequestDebugDatabaseSequenceTest::RunTest(const FString& Parameters)
{
	FAngelscriptDebuggerTestSession Session;
	FAngelscriptDebuggerTestClient Client;
	if (!StartDatabaseDebuggerSession(*this, Session, Client))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		if (Client.IsConnected())
		{
			Client.SendStopDebugging();
			Session.PumpUntil([&Session]() { return !Session.GetDebugServer().bIsDebugging; }, 1.0f);
			Client.SendDisconnect();
			Client.Disconnect();
		}
	};

	TestTrue(TEXT("Debugger database protocol should enter debugging mode after StartDebugging"), Session.GetDebugServer().bIsDebugging);

	Client.DrainPendingMessages();

	if (!TestTrue(TEXT("Debugger database protocol should send RequestDebugDatabase"), Client.SendRequestDebugDatabase()))
	{
		AddError(Client.GetLastError());
		return false;
	}

	TArray<FAngelscriptDebugMessageEnvelope> Transcript;
	const bool bCollectedTranscript = Session.PumpUntil(
		[&Client, &Transcript]()
		{
			return Client.CollectMessagesUntil(EDebugMessageType::AssetDatabaseFinished, 0.0f, Transcript);
		},
		Session.GetDefaultTimeoutSeconds());

	if (!TestTrue(TEXT("Debugger database protocol should collect the database transcript through AssetDatabaseFinished"), bCollectedTranscript))
	{
		AddError(Client.GetLastError());
		return false;
	}

	const int32 SettingsIndex = FindFirstMessageIndex(Transcript, EDebugMessageType::DebugDatabaseSettings);
	TestEqual(TEXT("Debugger database protocol should emit exactly one DebugDatabaseSettings message"), CountMessagesOfType(Transcript, EDebugMessageType::DebugDatabaseSettings), 1);
	TestEqual(TEXT("Debugger database protocol should start the transcript with DebugDatabaseSettings"), SettingsIndex, 0);

	const TOptional<FAngelscriptDebugDatabaseSettings> Settings = SettingsIndex != INDEX_NONE
		? FAngelscriptDebuggerTestClient::DeserializeMessage<FAngelscriptDebugDatabaseSettings>(Transcript[SettingsIndex])
		: TOptional<FAngelscriptDebugDatabaseSettings>();
	if (!TestTrue(TEXT("Debugger database protocol should deserialize DebugDatabaseSettings"), Settings.IsSet()))
	{
		return false;
	}

	const UAngelscriptSettings* RuntimeSettings = GetDefault<UAngelscriptSettings>();
	if (!TestNotNull(TEXT("Debugger database protocol should load runtime settings defaults"), RuntimeSettings))
	{
		return false;
	}

	TestEqual(TEXT("Debugger database protocol should mirror the automatic-import setting"), Settings->bAutomaticImports, FAngelscriptEngine::Get().ShouldUseAutomaticImportMethod());
	TestEqual(TEXT("Debugger database protocol should mirror the script float width setting"), Settings->bFloatIsFloat64, RuntimeSettings->bScriptFloatIsFloat64);
	TestEqual(TEXT("Debugger database protocol should mirror the haze integration setting"), Settings->bUseAngelscriptHaze, !!WITH_ANGELSCRIPT_HAZE);
	TestEqual(TEXT("Debugger database protocol should mirror the static class deprecate setting"), Settings->bDeprecateStaticClass, RuntimeSettings->StaticClassDeprecation == EAngelscriptStaticClassMode::Deprecated);
	TestEqual(TEXT("Debugger database protocol should mirror the static class disallow setting"), Settings->bDisallowStaticClass, RuntimeSettings->StaticClassDeprecation == EAngelscriptStaticClassMode::Disallowed);

	const int32 DatabaseIndex = FindFirstMessageIndex(Transcript, EDebugMessageType::DebugDatabase);
	if (!TestTrue(TEXT("Debugger database protocol should emit at least one DebugDatabase message"), DatabaseIndex != INDEX_NONE))
	{
		return false;
	}

	const TOptional<FAngelscriptDebugDatabase> Database = FAngelscriptDebuggerTestClient::DeserializeMessage<FAngelscriptDebugDatabase>(Transcript[DatabaseIndex]);
	if (!TestTrue(TEXT("Debugger database protocol should deserialize the first DebugDatabase payload"), Database.IsSet()))
	{
		return false;
	}

	TestFalse(TEXT("Debugger database protocol should keep the first DebugDatabase payload non-empty"), Database->Database.IsEmpty());

	TSharedPtr<FJsonObject> DatabaseJsonObject;
	if (!TestTrue(TEXT("Debugger database protocol should parse the first DebugDatabase payload as a JSON object"), ParseJsonObject(Database->Database, DatabaseJsonObject)))
	{
		return false;
	}

	const int32 DebugDatabaseFinishedIndex = FindFirstMessageIndex(Transcript, EDebugMessageType::DebugDatabaseFinished);
	const int32 FirstAssetDatabaseMessageIndex = FindFirstAssetDatabaseMessageIndex(Transcript);
	const int32 AssetDatabaseInitIndex = FindFirstMessageIndex(Transcript, EDebugMessageType::AssetDatabaseInit);
	const int32 AssetDatabaseFinishedIndex = FindFirstMessageIndex(Transcript, EDebugMessageType::AssetDatabaseFinished);

	if (!TestTrue(TEXT("Debugger database protocol should emit DebugDatabaseFinished"), DebugDatabaseFinishedIndex != INDEX_NONE))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger database protocol should emit AssetDatabaseInit"), AssetDatabaseInitIndex != INDEX_NONE))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger database protocol should emit AssetDatabaseFinished"), AssetDatabaseFinishedIndex != INDEX_NONE))
	{
		return false;
	}

	TestTrue(TEXT("Debugger database protocol should finish debug database emission before any asset database message"), FirstAssetDatabaseMessageIndex != INDEX_NONE && DebugDatabaseFinishedIndex < FirstAssetDatabaseMessageIndex);
	TestTrue(TEXT("Debugger database protocol should emit AssetDatabaseInit before AssetDatabaseFinished"), AssetDatabaseInitIndex < AssetDatabaseFinishedIndex);

	for (int32 Index = 0; Index < Transcript.Num(); ++Index)
	{
		if (Transcript[Index].MessageType != EDebugMessageType::AssetDatabase)
		{
			continue;
		}

		const TOptional<FAngelscriptAssetDatabase> AssetDatabase = FAngelscriptDebuggerTestClient::DeserializeMessage<FAngelscriptAssetDatabase>(Transcript[Index]);
		if (!TestTrue(FString::Printf(TEXT("Debugger database protocol should deserialize AssetDatabase payload %d"), Index), AssetDatabase.IsSet()))
		{
			return false;
		}

		TestEqual(
			FString::Printf(TEXT("Debugger database protocol should keep AssetDatabase payload %d in path/class pairs"), Index),
			AssetDatabase->Assets.Num() % 2,
			0);
	}

	return !HasAnyErrors();
}

#endif

