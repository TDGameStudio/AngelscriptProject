#pragma once
#include "CoreMinimal.h"
#include "Misc/MemStack.h"

extern ANGELSCRIPTRUNTIME_API FMemStackBase GScriptPreallocatedMemStack;

/** A container allocator that allocates from a mem-stack. */
template<uint32 Alignment = DEFAULT_ALIGNMENT>
class TPrecompiledAllocator
{
public:
	using SizeType = int32;

	enum { NeedsElementType = true };
	enum { RequireRangeCheck = true };

	template<typename ElementType>
	class ForElementType
	{
	public:

		/** Default constructor. */
		ForElementType():
			Data(nullptr)
		{}

		/**
		 * Moves the state of another allocator into this one.
		 * Assumes that the allocator is currently empty, i.e. memory may be allocated but any existing elements have already been destructed (if necessary).
		 * @param Other - The allocator to move the state from.  This allocator should be left in a valid empty state.
		 */
		FORCEINLINE void MoveToEmpty(ForElementType& Other)
		{
			checkSlow(this != &Other);

			Data       = Other.Data;
			Other.Data = nullptr;
		}

		// FContainerAllocatorInterface
		FORCEINLINE ElementType* GetAllocation() const
		{
			return Data;
		}
		void ResizeAllocation(int32 PreviousNumElements,int32 NumElements,int32 NumBytesPerElement)
		{
			void* OldData = Data;
			if( NumElements )
			{
				// Allocate memory from the stack.
				Data = (ElementType*)GScriptPreallocatedMemStack.PushBytes(
					NumElements * NumBytesPerElement,
					FMath::Max(Alignment,(uint32)alignof(ElementType))
					);

				// If the container previously held elements, copy them into the new allocation.
				if(OldData && PreviousNumElements)
				{
					const int32 NumCopiedElements = FMath::Min(NumElements,PreviousNumElements);
					FMemory::Memcpy(Data,OldData,NumCopiedElements * NumBytesPerElement);
				}
			}
		}
		FORCEINLINE int32 CalculateSlackReserve(int32 NumElements, int32 NumBytesPerElement) const
		{
			return DefaultCalculateSlackReserve(NumElements, NumBytesPerElement, false, Alignment);
		}
		FORCEINLINE int32 CalculateSlackShrink(int32 NumElements, int32 NumAllocatedElements, int32 NumBytesPerElement) const
		{
			return DefaultCalculateSlackShrink(NumElements, NumAllocatedElements, NumBytesPerElement, false, Alignment);
		}
		FORCEINLINE int32 CalculateSlackGrow(int32 NumElements, int32 NumAllocatedElements, int32 NumBytesPerElement) const
		{
			return DefaultCalculateSlackGrow(NumElements, NumAllocatedElements, NumBytesPerElement, false, Alignment);
		}

		FORCEINLINE int32 GetInitialCapacity() const
		{
			return 0;
		}

		FORCEINLINE int32 GetAllocatedSize(int32 NumAllocatedElements, int32 NumBytesPerElement) const
		{
			return NumAllocatedElements * NumBytesPerElement;
		}

		bool HasAllocation()
		{
			return !!Data;
		}
			
	private:

		/** A pointer to the container's elements. */
		ElementType* Data;
	};
	
	typedef ForElementType<FScriptContainerElement> ForAnyElementType;
};

template <uint32 Alignment>
struct TAllocatorTraits<TPrecompiledAllocator<Alignment>> : TAllocatorTraitsBase<TPrecompiledAllocator<Alignment>>
{
	enum { SupportsMove    = true };
	enum { IsZeroConstruct = true };
};
