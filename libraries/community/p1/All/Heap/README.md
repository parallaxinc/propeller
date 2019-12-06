# Heap

By: Peter Verkaik

Language: Spin

Created: Jan 2, 2008

Modified: May 2, 2013

This object presents a heap. The heap is a large contiguous byte array. The object provides all the methods for allocating and freeing blocks of memory and does all the housekeeping to preserve the heap integrity. Allocation of blocks is done using a first-fit scheme. Blocks can be allocated and freed in any order.
