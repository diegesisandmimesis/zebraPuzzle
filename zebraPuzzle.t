#charset "us-ascii"
//
// zebraPuzzle.t
//
//	Extension to the AC-3 class in the dataTypes module that
//	handles Zebra Puzzles.
//
//
#include <adv3.h>
#include <en_us.h>

#include "zebraPuzzle.h"

// Update the base class to have a vertexGroup.  This is what identies
// related variables.  If individual variables are things like "red", "green",
// and "blue", then the vertex group might be "color", and so on.
modify AC3Variable
	vertexGroup = nil
;

class ZebraPuzzle: AC3
	_zebraConfig = nil		// puzzle config
	_zebraSolution = nil		// solution, if found

	construct(obj?) {
		setZebraConfig(obj);
	}

	// Getter and setter for the config.  The setter validates the
	// config before setting it.
	getZebraConfig() { return(_zebraConfig); }
	setZebraConfig(obj) {
		if(!isZebraPuzzleConfig(obj))
			return(nil);

		if(obj.validate() != true)
			return(nil);
		_zebraConfig = obj;

		return(true);
	}

	// Getter and setter for the state.
	// Used in backtracking.
	getZebraState() { return(new ZebraPuzzleState(self)); }
	setZebraState(obj) { return(obj.restoreState(self)); }

	// Tweak the stock method to add the vertex group.
	addVariable(id, domain, grp?) {
		local r;

		if((r = inherited(id, domain)) == nil)
			return(nil);

		r.vertexGroup = grp;

		return(r);
	}

	// Zebra puzzle-specific constraints.
	// The three-argument version is a standard constraint, the
	// two-argument form is a convenience method that creates the
	// check function automagically.
	addZebraConstraint([args]) {
		if(args.length == 2)
			return(assignment(args[1], args[2]));
		if(args.length == 3) {
			return(_addBinaryConstraint(args[1], args[2], args[3]));
		}
		return(nil);
	}

	// Zebra puzzle-specific constrant types.
	// Takes two arguments.  If the second is an integer, it assigns
	// the value of the variable ("The middle house is red" or something
	// like that).  If it isn't, then it's treated as the assertion that
	// the two variables have the same value ("Milk is drunk in the red
	// house" or something like that).
	assignment(v0, v1) {
		if(isInteger(v1)) {
			return(_addUnaryConstraint(v0, { x: x == v1 }));
		} else {
			return(_addBinaryConstraint(v0, v1, { x, y: x == y }));
		}
	}

	/*
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
	*/

	// Initialization method(s).
	// Called by solve().
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

	// Use the set configuration to build the variable vertices.
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

	// Initialize the constraints.
	// This includes the constraints explicitly declared in the config
	// as well as the implicit ones from the overall puzzle design.
	_initZebraConstraints() {
		local cfg;

		cfg = getZebraConfig();
		if(!isZebraPuzzleConfig(cfg))
			return(nil);

		// The declared constraints.
		if(!_initZebraConstraintsBasic(cfg))
			return(nil);

		// The implicit constraints.
		if(!_initZebraConstraintsImplicit(cfg))
			return(nil);

		return(true);
	}

	// Set up the declared constaints.
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

	// Create the implicit constraints.
	// By default we assume that the value of each variable in a
	// vertex group is unique.  That is, if we have a group "colors"
	// containing variables "red", "green", and "blue" and we're assigning
	// them to houses/values 1, 2, and 3, the assumption is that
	// the red house is not ALSO the green house.  In other words, if
	// red = 1, green != 1 and blue != 1.
	_initZebraConstraintsImplicit(cfg) {
		local err;

		err = nil;
		cfg.forEachVariable(function(k, v) {
			if(!_initImplicitConstraint(k, v))
				err = true;
		});

		return(!err);
	}

	// Create a single implicit constraint.
	// First arg is a variable ID, second is a list of all the other
	// variables in the same group.
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

	// Replacement solve() method.
	// We handle initialization, applying constraints via AC-3, and then
	// using simple backtracking if we have to.
	solve() {
		_zebraSolution = nil;

		if(!initZebraPuzzle()) {
			_zerror('puzzle init failed');
			return(nil);
		}

		// Apply the unary constraints.  These "just" reduce the
		// domain of individual variables.
		if(!_checkUnaryConstraints()) {
			_zerror('unary constraints failed');
			return(nil);
		}

		_zlog('after unary constraints:');
		logState();

		// Apply the binary constraints.
		if(!_checkBinaryConstraints()) {
			_zerror('binary constraints failed');
			return(nil);
		}

		_zlog('after binary constraints:');
		logState();

		// Keep pruning domains and re-applying the binary constraints
		// as long as pruning reduces the domain of at least one
		// variable.
		while(_pruneDomains()) {
			_checkBinaryConstraints();
		}

		_zlog('after pruning:');
		logState();

		// Now use backtracking until we find a solution or run
		// out of things to try.
		if(!_backtrack())
			return(nil);

		_zlog('after backtracking:');
		logState();

		return(getSolution());
	}

	// Returns boolean true if the current state is a/the solution.
	// That is, if all variables' domains are a single element.
	isSolved() {
		local b;

		b = true;
		forEachVertex(function(x) {
			if(x.domain.length != 1) b = nil;
		});

		return(b);
	}

	// Backtracking method.
	// Called recursively.
	_backtrack() {
		local err, i, j, l, state, v;

		// First, prune and apply our constraints.
		// If this produces an error, return nil, which
		// should cause the caller to backtrack.
		err = nil;
		while(_pruneDomains() && (err == nil)) {
			if(!_checkBinaryConstraints())
				err = true;
		}
		if(err == true)
			return(nil);

		// If we now have a solution, hurray.  We're done.
		if(isSolved())
			return(true);

		// Iterate over all vertices.
		l = getVertices();
		for(j = 1; j <= l.length; j++) {
			v = l[j];

			// Skip vertices whose domain contains a single
			// element:  they're already solved.
			if(v.domain.length == 1)
				continue;

			// Iterate over all remaining values in our domain.
			for(i = 1; i <= v.domain.length; i++) {
				// Remember the current state.
				state = getZebraState();

				// Try reducing our domain to a single
				// value.
				v.domain = new Vector([ v.domain[i] ]);

				// Recurse.  If this eventually finds
				// the solution, we'll get true back.
				// If that happens, we're done.
				if(_backtrack() == true)
					return(true);

				// The recursive checking failed, meaning
				// the assignment we just tried was a dead
				// end.  Revert the state, continue to the
				// next option.
				setZebraState(state);
			}
		}

		// Oh no, out of options.  Fail.
		return(nil);
	}

	// Prune variable domains.
	// We check vertex groups for variables which have an element
	// in their domain that's in the domain of no other variable
	// in the group.  That implies that the unique value is the assignment
	// for that variable--it couldn't be any other variable in the
	// group, and each value must be assigned to one of the variables
	// in each group.
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

	// Prune a single vertex group.
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

	// Returns the solution as an array of hash tables.
	// For example, for the classic zebra problem this will return
	// a five-element array, each element representing one house.
	// Each hash table will look like [ 'color' -> 'yellow',
	// 'drink' -> 'water', 'pet -> 'fox' ] and so on.
	getSolution() {
		if(_zebraSolution != nil)
			return(_zebraSolution);

		if(!isSolved())
			return(nil);

		_zebraSolution = new ZebraPuzzleSolution(getZebraConfig(),
			self);

		return(_zebraSolution);
	}

	// Stubs for debugging.
	_zerror(txt) {}
	_zlog(txt) {}
	_zlogErrors() {}
	logState(v?) {}
;
