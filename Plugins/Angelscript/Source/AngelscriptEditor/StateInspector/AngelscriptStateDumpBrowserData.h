#pragma once

#include "CoreMinimal.h"

struct FAngelscriptStateDumpDirectoryInfo
{
	FString DirectoryPath;
	FString DirectoryName;
	FDateTime Timestamp;
	int32 CsvFileCount = 0;
};

struct FAngelscriptCsvTable
{
	TArray<FString> Header;
	TArray<TArray<FString>> Rows;
	FString ErrorMessage;

	bool IsValid() const
	{
		return ErrorMessage.IsEmpty() && !Header.IsEmpty();
	}
};

struct FAngelscriptStateDumpTableDiff
{
	FString TableName;
	int32 AddedRows = 0;
	int32 RemovedRows = 0;
	int32 ChangedRows = 0;
	FString ErrorMessage;
};

namespace AngelscriptEditor::StateInspector
{
	TArray<FAngelscriptStateDumpDirectoryInfo> ListStateDumpDirectories(const FString& RootDirectory);
	FAngelscriptCsvTable LoadCsvTable(const FString& Filename);
	TArray<FAngelscriptStateDumpTableDiff> DiffStateDumpDirectories(const FString& LeftDirectory, const FString& RightDirectory);
	FString GetDefaultStateDumpRootDirectory();
}
