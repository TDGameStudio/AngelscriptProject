#include "AngelscriptDebuggerCommandLine.h"

#include "Misc/Parse.h"

namespace AngelscriptDebugger
{
	namespace
	{
		bool IsDebuggerOnlyCommandLineToken(const FString& Token)
		{
			FString Key = Token;
			int32 EqualsIndex = INDEX_NONE;
			if (Key.FindChar(TEXT('='), EqualsIndex))
			{
				Key.LeftInline(EqualsIndex);
			}

			return Key.Equals(TEXT("-project"), ESearchCase::IgnoreCase)
				|| Key.Equals(TEXT("-scriptroot"), ESearchCase::IgnoreCase)
				|| Key.Equals(TEXT("-host"), ESearchCase::IgnoreCase)
				|| Key.Equals(TEXT("-port"), ESearchCase::IgnoreCase)
				|| Key.Equals(TEXT("-autoconnect"), ESearchCase::IgnoreCase)
				|| Key.Equals(TEXT("-smoketest"), ESearchCase::IgnoreCase);
		}

		bool IsRenderingBackendCommandLineToken(const FString& Token)
		{
			FString Key = Token;
			int32 EqualsIndex = INDEX_NONE;
			if (Key.FindChar(TEXT('='), EqualsIndex))
			{
				Key.LeftInline(EqualsIndex);
			}

			return Key.Equals(TEXT("-d3d11"), ESearchCase::IgnoreCase)
				|| Key.Equals(TEXT("-dx11"), ESearchCase::IgnoreCase)
				|| Key.Equals(TEXT("-d3d12"), ESearchCase::IgnoreCase)
				|| Key.Equals(TEXT("-dx12"), ESearchCase::IgnoreCase)
				|| Key.Equals(TEXT("-vulkan"), ESearchCase::IgnoreCase)
				|| Key.Equals(TEXT("-opengl"), ESearchCase::IgnoreCase)
				|| Key.Equals(TEXT("-nullrhi"), ESearchCase::IgnoreCase);
		}

		FString QuoteCommandLineToken(const FString& Token)
		{
			if (!Token.Contains(TEXT(" ")) && !Token.Contains(TEXT("\t")))
			{
				return Token;
			}

			int32 EqualsIndex = INDEX_NONE;
			if (Token.StartsWith(TEXT("-")) && Token.FindChar(TEXT('='), EqualsIndex))
			{
				return Token.Left(EqualsIndex + 1) + TEXT("\"") + Token.Mid(EqualsIndex + 1) + TEXT("\"");
			}

			return TEXT("\"") + Token + TEXT("\"");
		}
	}

	FLaunchOptions ParseLaunchOptions(const TCHAR* CommandLine)
	{
		FLaunchOptions Options;
		Options.bAutoConnect = FParse::Param(CommandLine, TEXT("autoconnect"));
		Options.bSmokeTest = FParse::Param(CommandLine, TEXT("smoketest"));
		FParse::Value(CommandLine, TEXT("-host="), Options.Host);
		FParse::Value(CommandLine, TEXT("-port="), Options.Port);
		FParse::Value(CommandLine, TEXT("-project="), Options.ProjectPath);
		FParse::Value(CommandLine, TEXT("-scriptroot="), Options.ScriptRoot);
		return Options;
	}

	FString MakeEnginePreInitCommandLine(const TCHAR* CommandLine)
	{
		FString Result;
		bool bHasRenderingBackend = false;
		const TCHAR* Cursor = CommandLine != nullptr ? CommandLine : TEXT("");
		FString Token;
		while (FParse::Token(Cursor, Token, true))
		{
			if (IsDebuggerOnlyCommandLineToken(Token))
			{
				continue;
			}

			bHasRenderingBackend = bHasRenderingBackend || IsRenderingBackendCommandLineToken(Token);
			if (!Result.IsEmpty())
			{
				Result += TEXT(" ");
			}
			Result += QuoteCommandLineToken(Token);
		}
		if (!bHasRenderingBackend)
		{
			if (!Result.IsEmpty())
			{
				Result += TEXT(" ");
			}
			Result += TEXT("-d3d11");
		}
		return Result;
	}
}
