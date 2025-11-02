#charset "us-ascii"
//
// zebraPuzzle.t
//
#include <adv3.h>
#include <en_us.h>

#include "zebraPuzzle.h"

class ZebraPuzzleConfig: object
	variables = nil
	constraints = nil

	domain = nil

	validate() {
		if((variables == nil) || (constraints == nil))
			return(nil);
		if(initDomain() != true)
			return(nil);
		return(true);
	}

	initDomain() {
		local n;

		if((n = computeDomainSize()) == nil)
			return(nil);

		domain = Vector.generate({ x: x }, n);

		return(true);
	}

	computeDomainSize() {
		local i, l, n;

		if(!isLookupTable(variables))
			return(nil);

		l = variables.keysToList();
		if(l.length < 1)
			return(nil);

		n = variables[l[1]].length;
		for(i = 1; i <= l.length; i++) {
			if(variables[l[i]].length != n)
				return(nil);
		}

		return(n);
	}

	forEachVariable(fn) {
		if(variables == nil) return;
		variables.forEachAssoc({ k, v: fn(k, v) });
	}

	forEachConstraint(fn) {
		if(constraints == nil) return;
		constraints.forEach({ x: (fn)(x) });
	}
;
