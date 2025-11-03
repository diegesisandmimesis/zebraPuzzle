#charset "us-ascii"
//
// zebraPuzzleConfig.t
//
#include <adv3.h>
#include <en_us.h>

#include "zebraPuzzle.h"

class ZebraPuzzleConfig: object
	variables = nil		// LookupTable of variables
	constraints = nil	// List of constraints

	domain = nil		// Computed domain

	addVariable(grp, id) {
		if(variables == nil)
			variables = new LookupTable();
		if(variables[grp] == nil)
			variables[grp] = new Vector();
		if(isList(variables[grp]))
			variables[grp] = new Vector(variables[grp]);

		if(isCollection(id)) {
			id.forEach({ x: variables[grp].append(x) });
		} else {
			variables[grp].append(id);
		}

		return(true);
	}

	addConstraint([args]) {
		if(constraints == nil)
			constraints = new Vector();
		if(isList(constraints))
			constraints = new Vector(constraints);
		if(args.length == 2)
			constraints.append([ args[1], args[2] ]);
		else if(args.length == 3)
			constraints.append([ args[1], args[2], args[3] ]);
		else
			return(nil);

		return(true);
	}

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

	variableToGroup(id) {
		local i, l;

		if(variables == nil) return(nil);
		l = variables.keysToList();
		for(i = 1; i <= l.length; i++) {
			if(variables[l[i]].indexOf(id) != nil)
				return(l[i]);
		}
		return(nil);
	}
;
