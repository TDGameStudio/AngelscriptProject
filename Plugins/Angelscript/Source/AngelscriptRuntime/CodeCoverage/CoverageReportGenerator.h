#pragma once

#include "CoreMinimal.h"
#include "LineCoverage.h"

struct FCoverageCounts
{
	FString ToString() const
	{
		if (NumExecutableLines == 0)
		{
			return "N/A";
		}
		else
		{
			float CoveragePercent = (float) NumLinesHit / NumExecutableLines * 100;
			return FString::Printf(TEXT("%.1f%% (%d/%d)"), CoveragePercent, NumLinesHit, NumExecutableLines);
		}
	}

	int NumLinesHit;
	int NumExecutableLines;
};

struct FCoverageNode
{
	~FCoverageNode()
	{
		for (const TPair<FString, FCoverageNode*>& Child : Children)
		{
			delete Child.Value;
		}
	}

	FCoverageCounts Counts;
	TMap<FString, FCoverageNode*> Children;
};

// Writes a .html file for this file to OutputDir/{RelativeFilename}.html, e.g. OutputDir/My/Path/File.as.html.
// The number of lines in the source file is written out through OutNumLinesInOriginal.
bool WriteFileCoverageReportHtml(const FString& RelativeFilename, const FLineCoverage& Coverage,
	const FString& OutputDir, int& OutNumLinesInOriginal);

// Constructs a directory tree from a bunch of paths, e.g. A/B/C.as, A/B/D.as and
// E/F/G.as leads to the tree
// [root] -> A -> B -> C.as
//                  -> D.as
//        -> E -> F -> G.as
// The new leaf node gets the hit counts from Coverage.
ANGELSCRIPTRUNTIME_API void AddCoverageLeaf(FCoverageNode& Root, const FString& Path, const FLineCoverage& Coverage);

// Traverses the tree in postorder (leaves first) and computes hit counts for directories.
// This is done by adding up the hit counts from all children (and AddCoverageLeaf) already
// set up the hit counts for all leaves.
ANGELSCRIPTRUNTIME_API FCoverageCounts ComputeCoverage(FCoverageNode& Node);

// Writes out index.html files for all directories. You must call ComputeCoverage first so
// the hit counts for dirs are initialized.
bool WriteCoverageSummaryHtml(FCoverageNode& Node, const FString& OutputDir);

// Writes out coverage for the top level dirs + the total.
bool WriteTopLevelCoverageJson(FCoverageNode& Root, const FString& OutputDir);
