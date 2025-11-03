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
		local g, i, r, str;

		g = new ZebraPuzzle(zebraConfig);

		if((r = g.solve()) == nil) {
			_error('solve() failed');
			g._zlogErrors();
			return;
		}

		str = new StringBuffer();
		for(i = 1; i <= r.length; i++) {
			str.append('House #<<toString(i)>>:\n ');
			r[i].forEachAssoc({ k, v:
				str.append('\t<<toString(k)>>: <<toString(v)>>\n ')
			});
			str.append('\n');
		}
		"\n<<toString(str)>>\n ";
	}
;
