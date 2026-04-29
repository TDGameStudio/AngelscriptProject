#pragma once

// ============================================================================
// AngelscriptPreprocessorTestHelpers.h
//
// Shared test utilities for Preprocessor tests. Provides:
//   - FFixtureFile: RAII fixture .as file writer (write on construct, delete on destruct)
//   - FPreprocessResult: captures preprocessing output + diagnostics in one bundle
//   - RunPreprocess(): one-call preprocess runner
//   - Assertion helpers: success/failure, diagnostics, module inspection
//   - FPreprocessSession: low-level access to Preprocessor internals (FFile/FMacro/FChunk)
//
// Usage:
//   TEST_METHOD(SomeName)
//   {
//       FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_MODULE_CLEAN();
//       ASTEST_BEGIN_MODULE_CLEAN
//
//       FFixtureFile File(TEXT("Tests/PP/Feature/Test.as"), TEXT("int Entry() { return 7; }"));
//       auto Result = RunPreprocess(Engine, File);
//       AssertPreprocessSucceeded(*TestRunner, Result);
//       auto* Module = AssertModuleExists(*TestRunner, Result, TEXT("Tests.PP.Feature.Test"));
//       if (Module) AssertModuleCodeContains(*TestRunner, *Module, TEXT("return 7;"));
//
//       ASTEST_END_MODULE_CLEAN
//   }
// ============================================================================

#include "Shared/AngelscriptTestMacros.h"
#include "Shared/AngelscriptTestUtilities.h"
#include "Shared/AngelscriptTestEngineHelper.h"
#include "Preprocessor/AngelscriptPreprocessor.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace PreprocessorTestHelpers
{
	using namespace AngelscriptTestSupport;

	// =========================================================================
	// 1. Fixture File Management (RAII)
	// =========================================================================

	/** Unified root directory for all preprocessor test fixtures.
	 *  Replaces 26 per-file GetFixtureRoot / Get*FixtureRoot functions. */
	inline FString GetFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("PreprocessorTestFixtures"));
	}

	/** RAII fixture file: writes a .as file on construction, deletes on destruction.
	 *  Replaces 25 per-file WriteFixture / Write*Fixture functions. */
	struct FFixtureFile
	{
		FString RelativePath;
		FString AbsolutePath;

		FFixtureFile(const FString& InRelativePath, const FString& Content)
			: RelativePath(InRelativePath)
			, AbsolutePath(FPaths::Combine(GetFixtureRoot(), InRelativePath))
			, bOwnsFile(true)
		{
			IFileManager::Get().MakeDirectory(*FPaths::GetPath(AbsolutePath), true);
			FFileHelper::SaveStringToFile(Content, *AbsolutePath);
		}

		~FFixtureFile()
		{
			if (bOwnsFile && !AbsolutePath.IsEmpty())
			{
				IFileManager::Get().Delete(*AbsolutePath, false, true, true);
			}
		}

		// Non-copyable
		FFixtureFile(const FFixtureFile&) = delete;
		FFixtureFile& operator=(const FFixtureFile&) = delete;

		// Movable
		FFixtureFile(FFixtureFile&& Other) noexcept
			: RelativePath(MoveTemp(Other.RelativePath))
			, AbsolutePath(MoveTemp(Other.AbsolutePath))
			, bOwnsFile(Other.bOwnsFile)
		{
			Other.bOwnsFile = false;
		}

		FFixtureFile& operator=(FFixtureFile&& Other) noexcept
		{
			if (this != &Other)
			{
				if (bOwnsFile && !AbsolutePath.IsEmpty())
				{
					IFileManager::Get().Delete(*AbsolutePath, false, true, true);
				}
				RelativePath = MoveTemp(Other.RelativePath);
				AbsolutePath = MoveTemp(Other.AbsolutePath);
				bOwnsFile = Other.bOwnsFile;
				Other.bOwnsFile = false;
			}
			return *this;
		}

		/** Factory for zero-byte fixture files (true 0 bytes on disk). */
		static FFixtureFile CreateZeroByte(const FString& InRelativePath)
		{
			FFixtureFile Result;
			Result.RelativePath = InRelativePath;
			Result.AbsolutePath = FPaths::Combine(GetFixtureRoot(), InRelativePath);
			Result.bOwnsFile = true;

			IFileManager::Get().MakeDirectory(*FPaths::GetPath(Result.AbsolutePath), true);
			FArchive* Writer = IFileManager::Get().CreateFileWriter(*Result.AbsolutePath);
			if (Writer != nullptr)
			{
				Writer->Close();
				delete Writer;
			}
			return Result;
		}

	private:
		FFixtureFile() = default;
		bool bOwnsFile = false;
	};

	/** Batch-write multiple fixture files. */
	inline TArray<FFixtureFile> WriteFixtures(
		TArrayView<const TPair<FString, FString>> PathsAndContents)
	{
		TArray<FFixtureFile> Files;
		Files.Reserve(PathsAndContents.Num());
		for (const TPair<FString, FString>& Pair : PathsAndContents)
		{
			Files.Emplace(Pair.Key, Pair.Value);
		}
		return Files;
	}

	// =========================================================================
	// 2. Preprocessing Result Capture
	// =========================================================================

	/** Encapsulates the complete output of a preprocessing run:
	 *  success flag, module descriptors, and all diagnostics collected from the engine. */
	struct FPreprocessResult
	{
		bool bSuccess = false;
		TArray<TSharedRef<FAngelscriptModuleDesc>> Modules;

		/** All diagnostic entries collected from the engine after preprocessing.
		 *  Includes both errors and warnings. */
		TArray<FAngelscriptEngine::FDiagnostic> AllDiagnostics;

		/** Count of error diagnostics only. */
		int32 ErrorCount = 0;

		/** Find a module by its fully-qualified dot-separated name. Returns nullptr if not found.
		 *  Returns non-const pointer because callers commonly invoke non-const FAngelscriptModuleDesc::GetClass.
		 *  Replaces 13 per-file FindModuleByName functions. */
		FAngelscriptModuleDesc* FindModule(const FString& ModuleName) const
		{
			for (const TSharedRef<FAngelscriptModuleDesc>& Module : Modules)
			{
				if (Module->ModuleName == ModuleName)
				{
					return &Module.Get();
				}
			}
			return nullptr;
		}

		/** Join all code sections of a module into one string. */
		FString JoinedCode(const FAngelscriptModuleDesc& Module) const
		{
			FString Joined;
			for (const FAngelscriptModuleDesc::FCodeSection& Section : Module.Code)
			{
				if (!Joined.IsEmpty())
				{
					Joined += TEXT("\n");
				}
				Joined += Section.Code;
			}
			return Joined;
		}

		/** Get the ordered list of module names for topology checks. */
		FString ModuleOrder() const
		{
			return FString::JoinBy(
				Modules,
				TEXT(" -> "),
				[](const TSharedRef<FAngelscriptModuleDesc>& M) { return M->ModuleName; });
		}
	};

	/** Append engine diagnostics for the given absolute filenames into the result.
	 *  Shared internal helper used by both RunPreprocess and RunPreprocessSession. */
	inline void AppendEngineDiagnostics(
		FAngelscriptEngine& Engine,
		const TArray<FString>& AbsoluteFilenames,
		FPreprocessResult& InOutResult)
	{
		for (const FString& AbsoluteFilename : AbsoluteFilenames)
		{
			const FAngelscriptEngine::FDiagnostics* DiagSet = Engine.Diagnostics.Find(AbsoluteFilename);
			if (DiagSet == nullptr)
			{
				continue;
			}
			for (const FAngelscriptEngine::FDiagnostic& Diag : DiagSet->Diagnostics)
			{
				InOutResult.AllDiagnostics.Add(Diag);
				if (Diag.bIsError)
				{
					++InOutResult.ErrorCount;
				}
			}
		}
	}

	/** Run preprocessing on multiple fixture files with optional flag overrides.
	 *  Handles engine diagnostic reset, AddFile, Preprocess, and diagnostic collection. */
	inline FPreprocessResult RunPreprocess(
		FAngelscriptEngine& Engine,
		TArrayView<const FFixtureFile* const> Files,
		const TMap<FString, bool>& FlagOverrides = {},
		bool bDisableAutomaticImports = true)
	{
		Engine.ResetDiagnostics();

		// Guard automatic imports for the full duration of preprocessing
		TOptional<TGuardValue<bool>> AutomaticImportGuard;
		if (bDisableAutomaticImports)
		{
			AutomaticImportGuard.Emplace(Engine.bUseAutomaticImportMethod, false);
		}

		FAngelscriptPreprocessor Preprocessor;

		// Apply flag overrides
		for (const TPair<FString, bool>& Flag : FlagOverrides)
		{
			Preprocessor.PreprocessorFlags.Add(Flag.Key, Flag.Value);
		}

		// Add all files
		TArray<FString> AbsoluteFilenames;
		AbsoluteFilenames.Reserve(Files.Num());
		for (const FFixtureFile* File : Files)
		{
			Preprocessor.AddFile(File->RelativePath, File->AbsolutePath);
			AbsoluteFilenames.Add(File->AbsolutePath);
		}

		FPreprocessResult Result;
		Result.bSuccess = Preprocessor.Preprocess();
		Result.Modules = Preprocessor.GetModulesToCompile();
		AppendEngineDiagnostics(Engine, AbsoluteFilenames, Result);
		return Result;
	}

	/** Single-file convenience overload. */
	inline FPreprocessResult RunPreprocess(
		FAngelscriptEngine& Engine,
		const FFixtureFile& File,
		const TMap<FString, bool>& FlagOverrides = {},
		bool bDisableAutomaticImports = true)
	{
		const FFixtureFile* FilePtr = &File;
		return RunPreprocess(Engine, MakeArrayView(&FilePtr, 1), FlagOverrides, bDisableAutomaticImports);
	}

	/** Multi-file convenience overload using TArray<FFixtureFile>. */
	inline FPreprocessResult RunPreprocess(
		FAngelscriptEngine& Engine,
		const TArray<FFixtureFile>& Files,
		const TMap<FString, bool>& FlagOverrides = {},
		bool bDisableAutomaticImports = true)
	{
		TArray<const FFixtureFile*> Ptrs;
		Ptrs.Reserve(Files.Num());
		for (const FFixtureFile& F : Files)
		{
			Ptrs.Add(&F);
		}
		return RunPreprocess(Engine, MakeArrayView(Ptrs), FlagOverrides, bDisableAutomaticImports);
	}

	// =========================================================================
	// 3. Assertion Helpers
	// =========================================================================

	// --- Success / Failure ---

	inline bool AssertPreprocessSucceeded(
		FAutomationTestBase& Test,
		const FPreprocessResult& Result)
	{
		return Test.TestTrue(TEXT("Preprocessing should succeed"), Result.bSuccess);
	}

	inline bool AssertPreprocessFailed(
		FAutomationTestBase& Test,
		const FPreprocessResult& Result)
	{
		return Test.TestFalse(TEXT("Preprocessing should fail"), Result.bSuccess);
	}

	// --- Diagnostics ---

	/** Assert the exact number of error diagnostics. */
	inline bool AssertErrorCount(
		FAutomationTestBase& Test,
		const FPreprocessResult& Result,
		int32 Expected)
	{
		return Test.TestEqual(
			TEXT("Error diagnostic count should match expected"),
			Result.ErrorCount,
			Expected);
	}

	/** Assert at least one diagnostic message contains the given substring. */
	inline bool AssertDiagnosticContains(
		FAutomationTestBase& Test,
		const FPreprocessResult& Result,
		const FString& Substring)
	{
		const bool bFound = Result.AllDiagnostics.ContainsByPredicate(
			[&Substring](const FAngelscriptEngine::FDiagnostic& Diag)
			{
				return Diag.Message.Contains(Substring);
			});
		return Test.TestTrue(
			*FString::Printf(TEXT("Diagnostics should contain message matching '%s'"), *Substring),
			bFound);
	}

	/** Assert NO diagnostic message contains the given substring. */
	inline bool AssertDiagnosticNotContains(
		FAutomationTestBase& Test,
		const FPreprocessResult& Result,
		const FString& Substring)
	{
		const bool bFound = Result.AllDiagnostics.ContainsByPredicate(
			[&Substring](const FAngelscriptEngine::FDiagnostic& Diag)
			{
				return Diag.Message.Contains(Substring);
			});
		return Test.TestFalse(
			*FString::Printf(TEXT("Diagnostics should NOT contain message matching '%s'"), *Substring),
			bFound);
	}

	/** Assert a diagnostic exists with the given message substring at the expected row/column. */
	inline bool AssertDiagnosticAt(
		FAutomationTestBase& Test,
		const FPreprocessResult& Result,
		const FString& MessageSubstring,
		int32 ExpectedRow,
		int32 ExpectedColumn = 1)
	{
		const FAngelscriptEngine::FDiagnostic* Found = nullptr;
		for (const FAngelscriptEngine::FDiagnostic& Diag : Result.AllDiagnostics)
		{
			if (Diag.Message.Contains(MessageSubstring))
			{
				Found = &Diag;
				break;
			}
		}

		if (!Test.TestNotNull(
				*FString::Printf(TEXT("Should find diagnostic containing '%s'"), *MessageSubstring),
				Found))
		{
			return false;
		}

		bool bPassed = true;
		bPassed &= Test.TestEqual(
			*FString::Printf(TEXT("Diagnostic '%s' should be at row %d"), *MessageSubstring, ExpectedRow),
			Found->Row, ExpectedRow);
		bPassed &= Test.TestEqual(
			*FString::Printf(TEXT("Diagnostic '%s' should be at column %d"), *MessageSubstring, ExpectedColumn),
			Found->Column, ExpectedColumn);
		return bPassed;
	}

	/** Assert diagnostics are completely empty (no errors, no warnings). */
	inline bool AssertNoDiagnostics(
		FAutomationTestBase& Test,
		const FPreprocessResult& Result)
	{
		return Test.TestEqual(
			TEXT("Should emit no diagnostics"),
			Result.AllDiagnostics.Num(), 0);
	}

	// --- Module assertions ---

	/** Assert a module with the given name exists. Returns pointer (nullptr on failure).
	 *  Returns non-const pointer because callers commonly invoke non-const FAngelscriptModuleDesc::GetClass. */
	inline FAngelscriptModuleDesc* AssertModuleExists(
		FAutomationTestBase& Test,
		const FPreprocessResult& Result,
		const FString& ModuleName)
	{
		FAngelscriptModuleDesc* Module = Result.FindModule(ModuleName);
		Test.TestNotNull(
			*FString::Printf(TEXT("Module '%s' should exist"), *ModuleName),
			Module);
		return Module;
	}

	/** Assert module count matches expected. */
	inline bool AssertModuleCount(
		FAutomationTestBase& Test,
		const FPreprocessResult& Result,
		int32 Expected)
	{
		return Test.TestEqual(
			TEXT("Module count should match expected"),
			Result.Modules.Num(), Expected);
	}

	/** Assert a module's concatenated code contains the given substring. */
	inline bool AssertModuleCodeContains(
		FAutomationTestBase& Test,
		const FPreprocessResult& Result,
		const FAngelscriptModuleDesc& Module,
		const FString& Substring)
	{
		const FString Code = Result.JoinedCode(Module);
		return Test.TestTrue(
			*FString::Printf(TEXT("Module '%s' code should contain '%s'"), *Module.ModuleName, *Substring),
			Code.Contains(Substring));
	}

	/** Assert a module's concatenated code does NOT contain the given substring. */
	inline bool AssertModuleCodeNotContains(
		FAutomationTestBase& Test,
		const FPreprocessResult& Result,
		const FAngelscriptModuleDesc& Module,
		const FString& Substring)
	{
		const FString Code = Result.JoinedCode(Module);
		return Test.TestFalse(
			*FString::Printf(TEXT("Module '%s' code should NOT contain '%s'"), *Module.ModuleName, *Substring),
			Code.Contains(Substring));
	}

	/** Assert a module imports another module by name. */
	inline bool AssertModuleImports(
		FAutomationTestBase& Test,
		const FAngelscriptModuleDesc& Module,
		const FString& ImportedModuleName)
	{
		return Test.TestTrue(
			*FString::Printf(TEXT("Module '%s' should import '%s'"), *Module.ModuleName, *ImportedModuleName),
			Module.ImportedModules.Contains(ImportedModuleName));
	}

	/** Assert import count on a module. */
	inline bool AssertImportCount(
		FAutomationTestBase& Test,
		const FAngelscriptModuleDesc& Module,
		int32 Expected)
	{
		return Test.TestEqual(
			*FString::Printf(TEXT("Module '%s' import count"), *Module.ModuleName),
			Module.ImportedModules.Num(), Expected);
	}

	/** Assert a module declares a class descriptor with the given name.
	 *  Module is passed by non-const ref because FAngelscriptModuleDesc::GetClass is non-const. */
	inline bool AssertModuleDeclaresClass(
		FAutomationTestBase& Test,
		FAngelscriptModuleDesc& Module,
		const FString& ClassName)
	{
		return Test.TestTrue(
			*FString::Printf(TEXT("Module '%s' should declare class '%s'"), *Module.ModuleName, *ClassName),
			Module.GetClass(ClassName).IsValid());
	}

	/** Assert a module does NOT declare a class descriptor with the given name.
	 *  Module is passed by non-const ref because FAngelscriptModuleDesc::GetClass is non-const. */
	inline bool AssertModuleNotDeclaresClass(
		FAutomationTestBase& Test,
		FAngelscriptModuleDesc& Module,
		const FString& ClassName)
	{
		return Test.TestFalse(
			*FString::Printf(TEXT("Module '%s' should NOT declare class '%s'"), *Module.ModuleName, *ClassName),
			Module.GetClass(ClassName).IsValid());
	}

	// --- Compilable code check ---

	/** Check whether any module in the result contains non-empty code sections.
	 *  Replaces 6 per-file ContainsCompilableCode functions. */
	inline bool ContainsCompilableCode(const FPreprocessResult& Result)
	{
		for (const TSharedRef<FAngelscriptModuleDesc>& Module : Result.Modules)
		{
			for (const FAngelscriptModuleDesc::FCodeSection& Section : Module->Code)
			{
				if (!Section.Code.IsEmpty())
				{
					return true;
				}
			}
		}
		return false;
	}

	inline bool AssertNoCompilableCode(
		FAutomationTestBase& Test,
		const FPreprocessResult& Result)
	{
		return Test.TestFalse(
			TEXT("Preprocessing should not leave behind compilable code"),
			ContainsCompilableCode(Result));
	}

	inline bool AssertContainsCompilableCode(
		FAutomationTestBase& Test,
		const FPreprocessResult& Result)
	{
		return Test.TestTrue(
			TEXT("Preprocessing should produce compilable code"),
			ContainsCompilableCode(Result));
	}

	// =========================================================================
	// 4. Low-level Session (for tests inspecting FFile/FMacro/FChunk)
	// =========================================================================

	/** Keeps the preprocessor alive after RunPreprocess for internal structure inspection.
	 *  Only needed by a handful of tests that verify macro shapes, chunk types, etc. */
	struct FPreprocessSession
	{
		FAngelscriptPreprocessor Preprocessor;
		FPreprocessResult Result;

		const TArray<FAngelscriptPreprocessor::FFile>& GetFiles() const
		{
			return Preprocessor.Files;
		}

		/** Gather all macros from all files/chunks. */
		TArray<const FAngelscriptPreprocessor::FMacro*> GatherMacros() const
		{
			TArray<const FAngelscriptPreprocessor::FMacro*> Macros;
			for (const FAngelscriptPreprocessor::FFile& File : Preprocessor.Files)
			{
				for (const FAngelscriptPreprocessor::FChunk& Chunk : File.ChunkedCode)
				{
					for (const FAngelscriptPreprocessor::FMacro& Macro : Chunk.Macros)
					{
						Macros.Add(&Macro);
					}
				}
			}
			return Macros;
		}

		/** Find a macro by type and name. */
		const FAngelscriptPreprocessor::FMacro* FindMacro(
			FAngelscriptPreprocessor::EMacroType Type,
			const FString& Name) const
		{
			for (const FAngelscriptPreprocessor::FFile& File : Preprocessor.Files)
			{
				for (const FAngelscriptPreprocessor::FChunk& Chunk : File.ChunkedCode)
				{
					for (const FAngelscriptPreprocessor::FMacro& Macro : Chunk.Macros)
					{
						if (Macro.Type == Type && Macro.Name == Name)
						{
							return &Macro;
						}
					}
				}
			}
			return nullptr;
		}

		/** Find a macro by type and subject index. */
		const FAngelscriptPreprocessor::FMacro* FindMacroBySubjectIndex(
			FAngelscriptPreprocessor::EMacroType Type,
			int32 SubjectIndex) const
		{
			for (const FAngelscriptPreprocessor::FFile& File : Preprocessor.Files)
			{
				for (const FAngelscriptPreprocessor::FChunk& Chunk : File.ChunkedCode)
				{
					for (const FAngelscriptPreprocessor::FMacro& Macro : Chunk.Macros)
					{
						if (Macro.Type == Type && Macro.SubjectIndex == SubjectIndex)
						{
							return &Macro;
						}
					}
				}
			}
			return nullptr;
		}

		/** Find the first chunk of a given type. */
		const FAngelscriptPreprocessor::FChunk* FindFirstChunkOfType(
			FAngelscriptPreprocessor::EChunkType ChunkType) const
		{
			for (const FAngelscriptPreprocessor::FFile& File : Preprocessor.Files)
			{
				for (const FAngelscriptPreprocessor::FChunk& Chunk : File.ChunkedCode)
				{
					if (Chunk.Type == ChunkType)
					{
						return &Chunk;
					}
				}
			}
			return nullptr;
		}
	};

	/** Run preprocessing and keep the preprocessor alive for internal inspection. */
	inline FPreprocessSession RunPreprocessSession(
		FAngelscriptEngine& Engine,
		TArrayView<const FFixtureFile* const> Files,
		const TMap<FString, bool>& FlagOverrides = {},
		bool bDisableAutomaticImports = true)
	{
		Engine.ResetDiagnostics();

		FPreprocessSession Session;

		for (const TPair<FString, bool>& Flag : FlagOverrides)
		{
			Session.Preprocessor.PreprocessorFlags.Add(Flag.Key, Flag.Value);
		}

		// Guard automatic imports for the full duration of preprocessing
		TOptional<TGuardValue<bool>> AutomaticImportGuard;
		if (bDisableAutomaticImports)
		{
			AutomaticImportGuard.Emplace(Engine.bUseAutomaticImportMethod, false);
		}

		TArray<FString> AbsoluteFilenames;
		AbsoluteFilenames.Reserve(Files.Num());
		for (const FFixtureFile* File : Files)
		{
			Session.Preprocessor.AddFile(File->RelativePath, File->AbsolutePath);
			AbsoluteFilenames.Add(File->AbsolutePath);
		}

		Session.Result.bSuccess = Session.Preprocessor.Preprocess();
		Session.Result.Modules = Session.Preprocessor.GetModulesToCompile();
		AppendEngineDiagnostics(Engine, AbsoluteFilenames, Session.Result);
		return Session;
	}

	/** Single-file convenience overload. */
	inline FPreprocessSession RunPreprocessSession(
		FAngelscriptEngine& Engine,
		const FFixtureFile& File,
		const TMap<FString, bool>& FlagOverrides = {},
		bool bDisableAutomaticImports = true)
	{
		const FFixtureFile* FilePtr = &File;
		return RunPreprocessSession(Engine, MakeArrayView(&FilePtr, 1), FlagOverrides, bDisableAutomaticImports);
	}

} // namespace PreprocessorTestHelpers

#endif // WITH_DEV_AUTOMATION_TESTS
