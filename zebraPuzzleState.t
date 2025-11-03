#charset "us-ascii"
//
// zebraPuzzleState.t
//
#include <adv3.h>
#include <en_us.h>

#include "zebraPuzzle.h"

class ZebraPuzzleState: object
	_data = nil

	construct(v?) { saveState(v); }

	saveState(obj) {
		if(!isZebraPuzzle(obj))
			return(nil);

		if(_data == nil) _data = new LookupTable();

		obj.forEachVertex({ x: _data[x] = new Vector(x.domain) });

		return(true);
	}

	getDomain(x) {
		return(_data ? _data[x] : nil);
	}

	restoreState(obj) {
		if(!isZebraPuzzle(obj) || !isLookupTable(_data))
			return(nil);

		_data.keysToList().forEach({ x: x.domain = new Vector(_data[x]) });

		return(true);
	}
;
