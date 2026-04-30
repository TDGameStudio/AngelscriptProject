#include "Debugging/AngelscriptDebugClientModel.h"

#include "Misc/Paths.h"

namespace AngelscriptDebugClient
{
	namespace Private
	{
		bool IsSameDebuggerFilename(const FString& Left, const FString& Right)
		{
			return NormalizeDebuggerFilename(Left).Equals(NormalizeDebuggerFilename(Right), ESearchCase::IgnoreCase);
		}

		bool IsSameDebuggerModule(const FString& Left, const FString& Right)
		{
			return Left.Equals(Right, ESearchCase::IgnoreCase);
		}

		FString NormalizeRoot(const FString& Root)
		{
			FString Normalized = NormalizeDebuggerFilename(Root);
			Normalized.RemoveFromEnd(TEXT("/"));
			return Normalized;
		}
	}

	int32 FBreakpointStore::SetBreakpoint(const FString& Filename, const FString& ModuleName, const int32 LineNumber, const FString& Condition)
	{
		const FString NormalizedFilename = NormalizeDebuggerFilename(Filename);
		for (FBreakpointEntry& Breakpoint : Breakpoints)
		{
			if (Private::IsSameDebuggerFilename(Breakpoint.Filename, NormalizedFilename)
				&& Breakpoint.ModuleName.Equals(ModuleName, ESearchCase::IgnoreCase)
				&& Breakpoint.RequestedLineNumber == LineNumber)
			{
				Breakpoint.LineNumber = LineNumber;
				Breakpoint.Condition = Condition;
				Breakpoint.bVerified = true;
				return Breakpoint.Id;
			}
		}

		FBreakpointEntry Entry;
		Entry.Id = NextBreakpointId++;
		Entry.Filename = NormalizedFilename;
		Entry.ModuleName = ModuleName;
		Entry.RequestedLineNumber = LineNumber;
		Entry.LineNumber = LineNumber;
		Entry.Condition = Condition;
		Entry.bVerified = true;
		Breakpoints.Add(MoveTemp(Entry));
		return Breakpoints.Last().Id;
	}

	void FBreakpointStore::ClearBreakpoints(const FString& Filename, const FString& ModuleName)
	{
		const FString NormalizedFilename = NormalizeDebuggerFilename(Filename);
		Breakpoints.RemoveAll([&NormalizedFilename, &ModuleName](const FBreakpointEntry& Entry)
		{
			const bool bMatchesFile = Private::IsSameDebuggerFilename(Entry.Filename, NormalizedFilename);
			const bool bMatchesModule = ModuleName.IsEmpty() || Entry.ModuleName.Equals(ModuleName, ESearchCase::IgnoreCase);
			return bMatchesFile && bMatchesModule;
		});
	}

	bool FBreakpointStore::RemoveBreakpointById(const int32 Id, FBreakpointEntry* OutRemovedBreakpoint)
	{
		for (int32 Index = 0; Index < Breakpoints.Num(); ++Index)
		{
			if (Breakpoints[Index].Id == Id)
			{
				if (OutRemovedBreakpoint != nullptr)
				{
					*OutRemovedBreakpoint = Breakpoints[Index];
				}
				Breakpoints.RemoveAt(Index);
				return true;
			}
		}
		return false;
	}

	bool FBreakpointStore::UpdateBreakpointCondition(const int32 Id, const FString& Condition, FBreakpointEntry* OutUpdatedBreakpoint)
	{
		for (FBreakpointEntry& Breakpoint : Breakpoints)
		{
			if (Breakpoint.Id == Id)
			{
				Breakpoint.Condition = Condition;
				if (OutUpdatedBreakpoint != nullptr)
				{
					*OutUpdatedBreakpoint = Breakpoint;
				}
				return true;
			}
		}
		return false;
	}

	bool FBreakpointStore::ApplyServerAck(const FAngelscriptBreakpoint& Ack)
	{
		for (int32 Index = 0; Index < Breakpoints.Num(); ++Index)
		{
			FBreakpointEntry& Breakpoint = Breakpoints[Index];
			if (Breakpoint.Id != Ack.Id)
			{
				continue;
			}

			const FString ResolvedFilename = Ack.Filename.IsEmpty() ? Breakpoint.Filename : NormalizeDebuggerFilename(Ack.Filename);
			const FString ResolvedModuleName = Ack.ModuleName.IsEmpty() ? Breakpoint.ModuleName : Ack.ModuleName;
			const FString ResolvedCondition = Ack.Condition.IsEmpty() ? Breakpoint.Condition : Ack.Condition;

			if (Ack.LineNumber != -1)
			{
				for (int32 OtherIndex = 0; OtherIndex < Breakpoints.Num(); ++OtherIndex)
				{
					const FBreakpointEntry& OtherBreakpoint = Breakpoints[OtherIndex];
					if (OtherIndex != Index
						&& OtherBreakpoint.LineNumber == Ack.LineNumber
						&& Private::IsSameDebuggerFilename(OtherBreakpoint.Filename, ResolvedFilename)
						&& Private::IsSameDebuggerModule(OtherBreakpoint.ModuleName, ResolvedModuleName))
					{
						Breakpoints.RemoveAt(Index);
						return true;
					}
				}
			}

			if (!Ack.Filename.IsEmpty())
			{
				Breakpoint.Filename = ResolvedFilename;
			}
			if (!Ack.ModuleName.IsEmpty())
			{
				Breakpoint.ModuleName = ResolvedModuleName;
			}
			Breakpoint.Condition = ResolvedCondition;

			if (Ack.LineNumber == -1)
			{
				Breakpoint.LineNumber = Breakpoint.RequestedLineNumber;
				Breakpoint.bVerified = false;
			}
			else
			{
				Breakpoint.LineNumber = Ack.LineNumber;
				Breakpoint.bVerified = true;
			}

			return true;
		}

		return false;
	}

	bool FBreakpointStore::HasBreakpointAtLine(const FString& Filename, const int32 LineNumber) const
	{
		FBreakpointEntry Breakpoint;
		return TryGetBreakpointAtLine(Filename, LineNumber, Breakpoint);
	}

	bool FBreakpointStore::TryGetBreakpointAtLine(const FString& Filename, const int32 LineNumber, FBreakpointEntry& OutBreakpoint) const
	{
		for (const FBreakpointEntry& Breakpoint : Breakpoints)
		{
			if (Breakpoint.LineNumber == LineNumber
				&& Private::IsSameDebuggerFilename(Breakpoint.Filename, Filename))
			{
				OutBreakpoint = Breakpoint;
				return true;
			}
		}
		return false;
	}

	TArray<FBreakpointEntry> FBreakpointStore::GetBreakpoints() const
	{
		return Breakpoints;
	}

	FString NormalizeDebuggerFilename(const FString& Filename)
	{
		FString Normalized = Filename;
		FPaths::NormalizeFilename(Normalized);
		return Normalized;
	}

	FString CombineDebuggerPath(const FString& ParentPath, const FString& ChildName)
	{
		if (ParentPath.IsEmpty())
		{
			return ChildName;
		}
		if (ChildName.StartsWith(TEXT("[")))
		{
			return ParentPath + ChildName;
		}
		return ParentPath + TEXT(".") + ChildName;
	}

	FString MakeScopePath(const int32 FrameIndex, const EScopeKind ScopeKind)
	{
		const TCHAR* ScopeName = TEXT("%local%");
		if (ScopeKind == EScopeKind::This)
		{
			ScopeName = TEXT("%this%");
		}
		else if (ScopeKind == EScopeKind::Module)
		{
			ScopeName = TEXT("%module%");
		}
		return FString::Printf(TEXT("%d:%s"), FrameIndex, ScopeName);
	}

	FString MakeModuleNameFromScriptPath(const FString& Filename, const TArray<FString>& ScriptRoots)
	{
		FString NormalizedFilename = NormalizeDebuggerFilename(Filename);
		for (const FString& Root : ScriptRoots)
		{
			FString NormalizedRoot = Private::NormalizeRoot(Root);
			NormalizedRoot += TEXT("/");
			FString RelativeFilename = NormalizedFilename;
			if (FPaths::MakePathRelativeTo(RelativeFilename, *NormalizedRoot))
			{
				FString ModuleName = NormalizeDebuggerFilename(RelativeFilename);
				ModuleName.RemoveFromEnd(TEXT(".as"));
				return ModuleName.Replace(TEXT("/"), TEXT("."));
			}
		}

		FString Fallback = FPaths::GetBaseFilename(NormalizedFilename, false);
		return NormalizeDebuggerFilename(Fallback).Replace(TEXT("/"), TEXT("."));
	}

	FString ResolveSourcePath(const FString& SourcePath, const FString& ModuleName, const TArray<FString>& ScriptRoots)
	{
		FString NormalizedSourcePath = NormalizeDebuggerFilename(SourcePath);
		if (!FPaths::IsRelative(NormalizedSourcePath))
		{
			return NormalizedSourcePath;
		}

		if (!ModuleName.IsEmpty() && ScriptRoots.Num() > 0)
		{
			FString ModuleRelativePath = ModuleName.Replace(TEXT("."), TEXT("/")) + TEXT(".as");
			return NormalizeDebuggerFilename(ScriptRoots[0] / ModuleRelativePath);
		}

		if (ScriptRoots.Num() > 0)
		{
			return NormalizeDebuggerFilename(ScriptRoots[0] / NormalizedSourcePath);
		}

		return NormalizedSourcePath;
	}
}
