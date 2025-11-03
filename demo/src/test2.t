#charset "us-ascii"
//
// test2.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the zebraPuzzle library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f test2.t3m
//
// ...or the equivalent, depending on what TADS development environment
// you're using.
//
// This "game" is distributed under the MIT License, see LICENSE.txt
// for details.
//
#include <adv3.h>
#include <en_us.h>

#include "zebraPuzzle.h"

zebraConfig: ZebraPuzzleConfig
	variables = [
		'color' ->
			[ 'red', 'green', 'ivory', 'yellow', 'blue' ],
		'country' ->
			[ 'England', 'Spain', 'Ukraine', 'Norway', 'Japan' ],
		'drink' ->
			[ 'coffee', 'tea', 'milk', 'orange juice', 'water' ],
		'brand' ->
			[ 'Old Gold', 'Kool', 'Chesterfield', 'Lucky Strike',
				'Parliament' ],
		'pet' ->
			[ 'dog', 'snails', 'fox', 'horse', 'zebra' ]
	]

	constraints = [
		[ 'England', 'red' ],
		[ 'Spain', 'dog' ],
		[ 'coffee', 'green' ],
		[ 'Ukraine', 'tea' ],
		[ 'green', 'ivory',
			{ a, b: a == b + 1 } ],
		[ 'Old Gold', 'snails' ],
		[ 'Kool', 'yellow' ],
		[ 'milk', 3 ],
		[ 'Norway', 1 ],
		[ 'Chesterfield', 'fox',
			{ a, b: abs(a - b) == 1 } ],
		[ 'Kool', 'horse',
			{ a, b: abs(a - b) == 1 } ],
		[ 'Lucky Strike', 'orange juice' ],
		[ 'Japan', 'Parliament' ],
		[ 'Norway', 'blue',
			{ a, b: abs(a - b) == 1 } ]
	]
;

versionInfo: GameID;
gameMain: GameMainDef
	_error(txt) { _log('ERROR: <<toString(txt)>>'); }
	_log(txt) { "\n<<toString(txt)>>\n "; }
	newGame() {
		local cfg, g, r;

		cfg = new ZebraPuzzleConfig();

		cfg.addVariable('color', 'red');
		cfg.addVariable('color', 'green');
		cfg.addVariable('color', 'ivory');
		cfg.addVariable('color', 'yellow');
		cfg.addVariable('color', 'blue');

		cfg.addVariable('country', 'England');
		cfg.addVariable('country', 'Spain');
		cfg.addVariable('country', 'Ukraine');
		cfg.addVariable('country', 'Norway');
		cfg.addVariable('country', 'Japan');

		cfg.addVariable('drink', [ 'coffee', 'tea', 'milk',
			'orange juice', 'water' ]);

		cfg.addVariable('brand',
			[ 'Old Gold', 'Kool', 'Chesterfield', 'Lucky Strike',
				'Parliament' ]);

		cfg.addVariable('pet',
			[ 'dog', 'snails', 'fox', 'horse', 'zebra' ]);

		cfg.addConstraint('England', 'red');
		cfg.addConstraint('Spain', 'dog');
		cfg.addConstraint('coffee', 'green');
		cfg.addConstraint('Ukraine', 'tea');
		cfg.addConstraint('green', 'ivory', { a, b: a == b + 1 });
		cfg.addConstraint('Old Gold', 'snails');
		cfg.addConstraint('Kool', 'yellow');
		cfg.addConstraint('milk', 3);
		cfg.addConstraint('Norway', 1);
		cfg.addConstraint('Chesterfield', 'fox',
			{ a, b: abs(a - b) == 1 });
		cfg.addConstraint('Kool', 'horse', { a, b: abs(a - b) == 1 });
		cfg.addConstraint('Lucky Strike', 'orange juice');
		cfg.addConstraint('Japan', 'Parliament');
		cfg.addConstraint('Norway', 'blue', { a, b: abs(a - b) == 1 });

		g = new ZebraPuzzle(cfg);

		if((r = g.solve()) == nil) {
			_error('solve() failed');
			g._zlogErrors();
			return;
		}

		r.log();
	}
;
