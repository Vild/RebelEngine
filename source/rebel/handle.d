module rebel.handle;

/**
	Returns $(D s) rounded up to the nearest power of 2.
	From: http://dpldocs.info/experimental-docs/source/std.experimental.allocator.common.d.html#L216
	License: Boost
*/

@safe @nogc nothrow pure private size_t roundUpToPowerOf2(size_t s) {
	import std.meta : AliasSeq;

	assert(s <= (size_t.max >> 1) + 1);
	--s;
	static if (size_t.sizeof == 4)
		alias Shifts = AliasSeq!(1, 2, 4, 8, 16);
	else
		alias Shifts = AliasSeq!(1, 2, 4, 8, 16, 32);
	foreach (i; Shifts)
		s |= s >> i;
	return s + 1;
}

struct Handle(Type_, size_t MaxCount_) {
	import std.bitmanip : bitfields;
	import std.math : log2, ceil;

	private alias Type = Type_;
	private enum size_t MaxCount = MaxCount_;

	private enum BitSize = cast(size_t)MaxCount.log2.ceil + 2 + 1 + 1;
	private enum BitSizeRound = BitSize.roundUpToPowerOf2;

	// dfmt off
	mixin(bitfields!(
		size_t, "id", cast(size_t)MaxCount.log2.ceil,
		ubyte, "magic", 2,
		bool, "inUse", 1,
		bool, "refGotten", 1,
		ulong, "", BitSizeRound - BitSize
	));
	// dfmt on

	@property bool isValid() const {
		return id < MaxCount;
	}

	// I could dream
	/*invariant {
		assert(isValid());
	}*/
}

struct HandleRefData(HandleType, Type) if (is(HandleType : Handle!(Type, MaxCount), Type, size_t MaxCount)) {
	@disable this();

	~this() {
		_handle.refGotten = false;
	}

	@property ref Type get() {
		return *_data;
	}

	alias get this;

private:
	this(HandleType* handle, Type* data) {
		handle.refGotten = true;
		_handle = handle;
		_data = data;
	}

	HandleType* _handle;
	Type* _data;
}

struct HandleStorage(HandleType, Type = HandleType.Type) if (is(HandleType : Handle!(Type, MaxCount), Type, size_t MaxCount)) {
	private enum size_t MaxCount = HandleType.MaxCount;

	HandleType[MaxCount] handles = () {
		HandleType[MaxCount] output;
		foreach (i, ref hdl; output)
			hdl.id = i;
		return output;
	}();
	Type[MaxCount] data;

	HandleRefData!(HandleType, Type) get(HandleType h) {
		assert(h.isValid, "Handle is invalid");
		assert(handles[h.id].magic == h.magic, "Old handle - Magic is wrong");
		assert(handles[h.id].inUse, "Old handle - Not in use");
		assert(!handles[h.id].refGotten, "Someone is already holding a ref of this handle");

		return HandleRefData!(HandleType, Type)(&handles[h.id], cast(Type*)&data[h.id]);
	}

	HandleType create(Args...)(Args args) {
		import std.algorithm : find;
		import std.range : front, empty;

		auto handlePtr = find!"a.inUse == b"(handles[], false);
		assert(!handlePtr.empty, "Out of handles!");
		auto handle = &handlePtr.front;
		handle.inUse = true;
		handle.magic = cast(ubyte)(handle.magic + 1);

		data[handle.id] = Type(args);

		return *handle;
	}

	void remove(HandleType h) {
		assert(h.isValid, "Handle is invalid");
		assert(handles[h.id].magic == h.magic, "Old handle - Magic is wrong");
		assert(handles[h.id].inUse, "Old handle - Not in use");
		assert(!handles[h.id].refGotten, "Someone is holding a ref of this handle");

		data[h.id].destroy;
		handles[h.id].inUse = false;
	}
}