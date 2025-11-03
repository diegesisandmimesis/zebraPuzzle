#charset "us-ascii"
//
// zebraPuzzleState.t
//
//	Puzzle solution state.  Used to save and restore solution state
//	during backtracking.
//
//
#include <adv3.h>
#include <en_us.h>

#include "zebraPuzzle.h"

class ZebraPuzzleState: object
	_data = nil		// lookup table of domains keyed by variable

	construct(v?) { saveState(v); }

	// Argument is the puzzle instance whose state is being saved.
	saveState(obj) {
		if(!isZebraPuzzle(obj))
			return(nil);

		if(_data == nil) _data = new LookupTable();

		// Save the current domain of each variable, keyed by vertex.
		obj.forEachVertex({ x: _data[x] = new Vector(x.domain) });

		return(true);
	}

	// Gets the saved domain for the given vertex.
	getDomain(x) {
		return(_data ? _data[x] : nil);
	}

	// Applies this saved state to the given puzzle instance.
	restoreState(obj) {
		if(!isZebraPuzzle(obj) || !isLookupTable(_data))
			return(nil);

		_data.keysToList()
			.forEach({ x: x.domain = new Vector(_data[x]) });

		return(true);
	}
;
