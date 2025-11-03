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

	getZebraState() { return(new ZebraPuzzleState(self)); }
	setZebraState(obj) { return(obj.restoreState(self)); }

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

		_zlog('after initialization:');
		logState();

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

	solve() {
		if(!initZebraPuzzle()) {
			_zerror('puzzle init failed');
			return(nil);
		}

		if(!_checkUnaryConstraints()) {
			_zerror('unary constraints failed');
			return(nil);
		}

		_zlog('after unary constraints:');
		logState();

		if(!_checkBinaryConstraints()) {
			_zerror('binary constraints failed');
			return(nil);
		}

		_zlog('after binary constraints:');
		logState();

		while(_pruneDomains()) {
			_checkBinaryConstraints();
		}

		_zlog('after pruning:');
		logState();

		if(!_backtrack())
			return(nil);

		_zlog('after backtracking:');
		logState();

		return(getSolution());
	}

	isSolved() {
		local b;

		b = true;
		forEachVertex(function(x) {
			if(x.domain.length != 1) b = nil;
		});

		return(b);
	}

	_backtrack() {
		local err, i, j, l, state, v;

		err = nil;
		while(_pruneDomains() && (err == nil)) {
			if(!_checkBinaryConstraints())
				err = true;
		}
		if(err == true)
			return(nil);

		if(isSolved()) return(true);

		l = getVertices();
		for(j = 1; j <= l.length; j++) {
			v = l[j];
			if(v.domain.length == 1) continue;
			for(i = 1; i <= v.domain.length; i++) {
				state = getZebraState();
				v.domain = new Vector([ v.domain[i] ]);
				if(_backtrack() == true)
					return(true);
				setZebraState(state);
			}
		}

		return(nil);
	}

	_pruneDomains() {
		local cfg, r;

		cfg = getZebraConfig();
		if(!isZebraPuzzleConfig(cfg))
			return(nil);

		r = nil;
		cfg.forEachVariable(function(k, v) {
			if(_pruneVariableDomain(k, v)) r = true;
		});

		return(r);
	}

	_pruneVariableDomain(id, lst) {
		local l, r, t;

		// Get all vertices in the given group.
		l = getVertices().subset({ x: x.vertexGroup == id });

		// Build a hash table.  Keys are elements of the domain,
		// values are vectors containing all vertices with that
		// value in its domain.
		t = new LookupTable();
		l.forEach(function(x) {
			x.domain.forEach(function(y) {
				if(t[y] == nil) t[y] = new Vector();
				t[y].appendUnique(x);
			});
		});

		r = nil;

		// Any value in the table with length 1 is a vertex with
		// an element in its domain that IS NOT in any other domain
		// in the group.  That implies that the element is the
		// assignment for this vertex.
		t.forEachAssoc(function(k, v) {
			if(v.length != 1) return;

			// If the domain is already a single element we
			// have nothing to do.
			if(v[1].domain.length == 1) return;

			// Clear the domain of everything except the unique
			// element.
			v[1].domain = v[1].domain.subset({ x: x == k });

			// Mark that we updated something.
			// We can't really do anything directly--we can't
			// remove the element from the other domains, for
			// example, because we know it' already isn't
			// in them (that's why we're here).  But clearing
			// out this vertex's domain might make someone
			// else pass this check if we run it again.
			r = true;
		});

		return(r);
	}

	getSolution() {
		local cfg, r;

		if(!isSolved()) return(nil);
		if((cfg = getZebraConfig()) == nil) return(nil);

		r = Vector.generate({ x: new LookupTable() },
			cfg.domain.length);

		forEachVertex(function(v) {
			r[v.domain[1]][cfg.variableToGroup(v.vertexID)]
				= v.vertexID;
		});

		return(r);
	}

	_zerror(txt) {}
	_zlog(txt) {}
	_zlogErrors() {}
	logState(v?) {}
;
