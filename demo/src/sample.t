#charset "us-ascii"
//
// sample.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the zebraPuzzle library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f makefile.t3m
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
		'brand' ->
			[ 'Old Gold', 'Kool', 'Chesterfield', 'Lucky Strike',
				'Parliament' ],
		'color' ->
			[ 'red', 'green', 'ivory', 'yellow', 'blue' ],
		'country' ->
			[ 'England', 'Spain', 'Ukraine', 'Norway', 'Japan' ],
		'drink' ->
			[ 'coffee', 'tea', 'milk', 'orange juice', 'water' ],
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
		local g, r, str;

		g = new ZebraPuzzle(zebraConfig);

		if(!g.initZebraPuzzle()) {
			_error('init failed');
			g._zlogErrors();
			return;
		}

		_log('===init start===');
		g.logState();
		_log('===init end===');

		g._checkUnaryConstraints();

		_log('===init start===');
		g.logState();
		_log('===init end===');

		if((r = g.solve()) != true) {
			_error('solve() failed');
			g._zlogErrors();
			return;
		}

		r = 1;
		if(r == 1)
			return;
		if((r = g.getSolutions()) != true) {
			_error('getSolutions() failed');
			g._zlogErrors();
			return;
		}

		"\n<<toString(r.length)>> possible solutions\n ";
		if(r.length > 10)
			return;
		str = new StringBuffer();
		r.forEach(function(x) {
			x.forEachAssoc({ k, v: str.append('<<toString(k)>> is
				<<toString(v)>> ') });
			str.append('\n');
		});
		"\n<<toString(str)>>\n ";
	}
;
