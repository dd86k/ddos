__gshared:
extern (C):

/**
 * Set a memory region with a byte value.
 * Params:
 *   ptr = Memory region to affect
 *   val = Byte value to assign
 *   num = Size of the operation
 * Returns: Pointer (unchanged)
 */
extern(C) void* kmemset(void* ptr, int val, size_t num) {
	if (num > 0) {
		const ubyte v = val & 0xFF;
		ubyte* p = cast(ubyte*)ptr;
		while (num--) *p++ = v;
	}
	return ptr;
}