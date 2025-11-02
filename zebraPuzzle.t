#charset "us-ascii"
//
// zebraPuzzle.t
//
#include <adv3.h>
#include <en_us.h>

#include "zebraPuzzle.h"

modify AC3Variable
	vertexGroup = nil
;

class ZebraPuzzle: AC3
	_zebraConfig = nil

	construct(obj?) {
		setZebraConfig(obj);
	}

	getZebraConfig() { return(_zebraConfig); }
	setZebraConfig(obj) {
		if(!isZebraPuzzleConfig(obj))
			return(nil);

		if(obj.validate() != true)
			return(nil);
		_zebraConfig = obj;

		return(true);
	}

	addVariable(id, domain, grp?) {
		local r;

		if((r = inherited(id, domain)) == nil)
			return(nil);

		r.vertexGroup = grp;

		return(r);
	}

	addZebraConstraint([args]) {
		if(args.length == 2)
			return(assignment(args[1], args[2]));
		if(args.length == 3) {
			return(_addBinaryConstraint(args[1], args[2], args[3]));
		}
		return(nil);
	}

	assignment(v0, v1) {
		if(isInteger(v1)) {
			return(_addUnaryConstraint(v0, { x: x == v1 }));
		} else {
			return(_addBinaryConstraint(v0, v1, { x, y: x == y }));
		}
	}

	_checkBinaryConstraints() {
		local ac3Queue, v;

		ac3Queue = new Vector();
		forEachEdge({ x: ac3Queue.append(x) });

		while(ac3Queue.length > 0) {
			v = ac3Queue[1];
			ac3Queue.removeElement(v);


			if(v.checkConstraint()) {
				if(v.vertex0.domain.length < 1)
					return(nil);

				forEachEdge(function(x) {
					if(x == v) return;
					if((x.vertex0 != v.vertex0) &&
						(x.vertex1 != v.vertex0))
						return;
					ac3Queue.append(x);
				});
			}
		}

		return(true);
	}

	initZebraPuzzle() {
		if(!_initZebraVariables()) {
			_zerror('failed to initialize variables');
			return(nil);
		}

		if(!_initZebraConstraints()) {
			_zerror('failed to initialize constraints');
			return(nil);
		}

		return(true);
	}

	_initZebraVariables() {
		local cfg, err;

		cfg = getZebraConfig();
		if(!isZebraPuzzleConfig(cfg))
			return(nil);

		err = nil;
		cfg.forEachVariable({ k, v:
			v.forEach(function(x) {
				if(!addVariable(x, cfg.domain, k)) {
					_zerror('failed to add variable
						<q><<toString(x)>></q>');
					err = true;
				}
			})
		});

		return(!err);
	}

	_initZebraConstraints() {
		local cfg;

		cfg = getZebraConfig();
		if(!isZebraPuzzleConfig(cfg))
			return(nil);

		if(!_initZebraConstraintsBasic(cfg))
			return(nil);

		if(!_initZebraConstraintsImplicit(cfg))
			return(nil);

		return(true);
	}

	_initZebraConstraintsBasic(cfg) {
		local err;

		err = nil;
		cfg.forEachConstraint(function(x) {
			if(!addZebraConstraint(x...)) {
				_zerror('failed to add constraint on
					<<toString(x[1])>>');
				err = true;
			}
		});

		return(!err);
	}

	_initZebraConstraintsImplicit(cfg) {
		local err;

		err = nil;
		cfg.forEachVariable(function(k, v) {
			if(!_initImplicitConstraint(k, v))
				err = true;
		});

		return(!err);
	}

	_initImplicitConstraint(id, lst) {
		local err, i, j;

		err = nil;
		for(i = 1; i <= lst.length; i++) {
			for(j = i + 1; j <= lst.length; j++) {
				if(!_addBinaryConstraint(lst[i], lst[j],
					{ a, b: a != b })) {
					_zerror('failed to add implicit
						constraint between
						<<toString(lst[i])>> and
						<<toString(lst[j])>>');
					err = true;
				}
			}
		}

		return(!err);
	}

	_zerror(txt) {}
	_zlog(txt) {}
	_zlogErrors() {}
	logState(v?) {}
;
