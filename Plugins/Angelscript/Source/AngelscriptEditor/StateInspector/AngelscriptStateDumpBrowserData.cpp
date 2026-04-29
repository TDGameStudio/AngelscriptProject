#include "StateInspector/AngelscriptStateDumpBrowserData.h"

#include "HAL/FileManager.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"

namespace
{
	void AddCsvRecord(TArray<FString>& CurrentRecord, FString& CurrentField, TArray<TArray<FString>>& OutRecords)
	{
		if (CurrentRecord.IsEmpty() && CurrentField.IsEmpty())
		{
			return;
		}

		CurrentRecord.Add(MoveTemp(CurrentField));
		CurrentField.Reset();
		OutRecords.Add(MoveTemp(CurrentRecord));
		CurrentRecord.Reset();
	}

	bool ParseCsvRecords(const FString& Contents, TArray<TArray<FString>>& OutRecords, FString& OutError)
	{
		OutRecords.Reset();
		FString CurrentField;
		TArray<FString> CurrentRecord;
		bool bInQuotes = false;
		int32 LineNumber = 1;

		for (int32 Index = 0; Index < Contents.Len(); ++Index)
		{
			const TCHAR Character = Contents[Index];
			if (bInQuotes)
			{
				if (Character == TEXT('"'))
				{
					if (Index + 1 < Contents.Len() && Contents[Index + 1] == TEXT('"'))
					{
						CurrentField.AppendChar(TEXT('"'));
						++Index;
					}
					else
					{
						bInQuotes = false;
					}
				}
				else
				{
					CurrentField.AppendChar(Character);
					if (Character == TEXT('\n'))
					{
						++LineNumber;
					}
				}
				continue;
			}

			if (Character == TEXT(','))
			{
				CurrentRecord.Add(MoveTemp(CurrentField));
				CurrentField.Reset();
			}
			else if (Character == TEXT('"'))
			{
				if (!CurrentField.IsEmpty())
				{
					OutError = FString::Printf(TEXT("Line %d: quote appeared after unquoted field content."), LineNumber);
					return false;
				}
				bInQuotes = true;
			}
			else if (Character == TEXT('\r') || Character == TEXT('\n'))
			{
				AddCsvRecord(CurrentRecord, CurrentField, OutRecords);
				if (Character == TEXT('\r') && Index + 1 < Contents.Len() && Contents[Index + 1] == TEXT('\n'))
				{
					++Index;
				}
				++LineNumber;
			}
			else
			{
				CurrentField.AppendChar(Character);
			}
		}

		if (bInQuotes)
		{
			OutError = FString::Printf(TEXT("Line %d: unclosed quoted CSV field."), LineNumber);
			return false;
		}

		AddCsvRecord(CurrentRecord, CurrentField, OutRecords);
		return true;
	}

	FString BuildRowKey(const TArray<FString>& Row)
	{
		if (!Row.IsEmpty() && !Row[0].IsEmpty())
		{
			return Row[0];
		}
		return FString::Join(Row, TEXT("\x1f"));
	}

	FString BuildRowValue(const TArray<FString>& Row)
	{
		return FString::Join(Row, TEXT("\x1e"));
	}

	void AddCsvFilesFromDirectory(const FString& Directory, TSet<FString>& InOutTableNames)
	{
		TArray<FString> CsvFiles;
		IFileManager::Get().FindFiles(CsvFiles, *FPaths::Combine(Directory, TEXT("*.csv")), true, false);
		for (const FString& CsvFile : CsvFiles)
		{
			InOutTableNames.Add(CsvFile);
		}
	}
}

namespace AngelscriptEditor::StateInspector
{
	FString GetDefaultStateDumpRootDirectory()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Angelscript"), TEXT("Dump"));
	}

	TArray<FAngelscriptStateDumpDirectoryInfo> ListStateDumpDirectories(const FString& RootDirectory)
	{
		TArray<FString> DirectoryNames;
		IFileManager::Get().FindFiles(DirectoryNames, *FPaths::Combine(RootDirectory, TEXT("*")), false, true);

		TArray<FAngelscriptStateDumpDirectoryInfo> Result;
		for (const FString& DirectoryName : DirectoryNames)
		{
			FAngelscriptStateDumpDirectoryInfo Info;
			Info.DirectoryName = DirectoryName;
			Info.DirectoryPath = FPaths::Combine(RootDirectory, DirectoryName);
			Info.Timestamp = IFileManager::Get().GetTimeStamp(*Info.DirectoryPath);

			TArray<FString> CsvFiles;
			IFileManager::Get().FindFiles(CsvFiles, *FPaths::Combine(Info.DirectoryPath, TEXT("*.csv")), true, false);
			Info.CsvFileCount = CsvFiles.Num();
			Result.Add(MoveTemp(Info));
		}

		Result.Sort([](const FAngelscriptStateDumpDirectoryInfo& Left, const FAngelscriptStateDumpDirectoryInfo& Right)
		{
			return Left.Timestamp > Right.Timestamp;
		});
		return Result;
	}

	FAngelscriptCsvTable LoadCsvTable(const FString& Filename)
	{
		FAngelscriptCsvTable Table;

		FString Contents;
		if (!FFileHelper::LoadFileToString(Contents, *Filename))
		{
			Table.ErrorMessage = FString::Printf(TEXT("Failed to read '%s'."), *Filename);
			return Table;
		}

		TArray<TArray<FString>> Records;
		FString ParseError;
		if (!ParseCsvRecords(Contents, Records, ParseError))
		{
			Table.ErrorMessage = FString::Printf(TEXT("%s: %s"), *Filename, *ParseError);
			return Table;
		}

		if (Records.IsEmpty())
		{
			Table.ErrorMessage = FString::Printf(TEXT("CSV file '%s' is empty."), *Filename);
			return Table;
		}

		Table.Header = MoveTemp(Records[0]);

		for (int32 RecordIndex = 1; RecordIndex < Records.Num(); ++RecordIndex)
		{
			Table.Rows.Add(MoveTemp(Records[RecordIndex]));
		}

		return Table;
	}

	TArray<FAngelscriptStateDumpTableDiff> DiffStateDumpDirectories(const FString& LeftDirectory, const FString& RightDirectory)
	{
		TSet<FString> TableNames;
		AddCsvFilesFromDirectory(LeftDirectory, TableNames);
		AddCsvFilesFromDirectory(RightDirectory, TableNames);

		TArray<FString> SortedTableNames = TableNames.Array();
		SortedTableNames.Sort();

		TArray<FAngelscriptStateDumpTableDiff> Result;
		for (const FString& TableName : SortedTableNames)
		{
			const FString LeftFile = FPaths::Combine(LeftDirectory, TableName);
			const FString RightFile = FPaths::Combine(RightDirectory, TableName);

			FAngelscriptStateDumpTableDiff Diff;
			Diff.TableName = TableName;

			if (!IFileManager::Get().FileExists(*LeftFile))
			{
				Diff.AddedRows = LoadCsvTable(RightFile).Rows.Num();
				Result.Add(MoveTemp(Diff));
				continue;
			}
			if (!IFileManager::Get().FileExists(*RightFile))
			{
				Diff.RemovedRows = LoadCsvTable(LeftFile).Rows.Num();
				Result.Add(MoveTemp(Diff));
				continue;
			}

			const FAngelscriptCsvTable LeftTable = LoadCsvTable(LeftFile);
			const FAngelscriptCsvTable RightTable = LoadCsvTable(RightFile);
			if (!LeftTable.IsValid() || !RightTable.IsValid())
			{
				Diff.ErrorMessage = !LeftTable.IsValid() ? LeftTable.ErrorMessage : RightTable.ErrorMessage;
				Result.Add(MoveTemp(Diff));
				continue;
			}

			TMap<FString, FString> LeftRows;
			for (const TArray<FString>& Row : LeftTable.Rows)
			{
				LeftRows.Add(BuildRowKey(Row), BuildRowValue(Row));
			}

			TMap<FString, FString> RightRows;
			for (const TArray<FString>& Row : RightTable.Rows)
			{
				RightRows.Add(BuildRowKey(Row), BuildRowValue(Row));
			}

			for (const TPair<FString, FString>& RightPair : RightRows)
			{
				const FString* LeftValue = LeftRows.Find(RightPair.Key);
				if (LeftValue == nullptr)
				{
					++Diff.AddedRows;
				}
				else if (*LeftValue != RightPair.Value)
				{
					++Diff.ChangedRows;
				}
			}

			for (const TPair<FString, FString>& LeftPair : LeftRows)
			{
				if (!RightRows.Contains(LeftPair.Key))
				{
					++Diff.RemovedRows;
				}
			}

			Result.Add(MoveTemp(Diff));
		}

		return Result;
	}
}
