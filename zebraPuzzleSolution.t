#charset "us-ascii"
//
// zebraPuzzleSolution.t
//
//	Data structure for zebra puzzle solutions
//
//
#include <adv3.h>
#include <en_us.h>

#include "zebraPuzzle.h"

class ZebraPuzzleSolution: object
	data = nil		// array of tables contain the solution

	construct(cfg, obj) {
		validate(cfg, obj);
	}

	validate(cfg, obj) {
		if(!isZebraPuzzleConfig(cfg) || !isZebraPuzzle(obj))
			return(nil);
		if(!obj.isSolved())
			return(nil);

		data = Vector.generate({ x: new LookupTable() },
			cfg.domain.length);

		obj.forEachVertex({ v:
			data[v.domain[1]][cfg.variableToGroup(v.vertexID)]
				= v.vertexID
		});

		return(true);
	}

	log() {
		local i;

		if(data == nil) {
			"\nnot solved\n ";
			return;
		}

		for(i = 1; i <= data.length; i++) {
			"\nItem <<toString(i)>>:\n ";
			data[i].forEachAssoc({ k, v:
				"\n\t<<toString(k)>>: <<toString(v)>>\n "
			});
		}
	}
;
