#charset "us-ascii"
//
// zebraPuzzleDebug.t
//
//	Debugging methods.  Only used when compiled with -d.
//
//
#include <adv3.h>
#include <en_us.h>

#include "zebraPuzzle.h"

#ifdef __DEBUG

modify ZebraPuzzle
	_zErrorBuffer = perInstance(new Vector())
	_zerror(txt) { _zErrorBuffer.append(txt); }
	_zlog(txt) { aioSay('\n<<toString(txt)>>\n '); }

	_zlogErrors() { _zErrorBuffer.forEach({ x: _zlog(x) }); }

	// Print a simple (ugly) banner for the state output.
	_zlogStateHeading() {
		local l, str, r;

		r = new Vector();
		l = getVertices().sort(nil, { a, b:
			toString(a.vertexGroup)
				.compareTo(toString(b.vertexGroup)) });
		l.forEach({ x: r.appendUnique(x.vertexGroup) });
		str = new StringBuffer();
		r.forEach({ x: str.append('<<toString(x)>> ') });
		_log(toString(str));
	}

	// Output the current state schematically.  Output will be
	// grouped numbers, like:
	//	13434 21231 31334 32113 41433
	// The numbers are the domain sizes for the variables, grouped
	// by vertex group.
	logState(head?) {
		local g, l, str;

		if(head == true)
			_zlogStateHeading();

		str = new StringBuffer();
		l = getVertices().sort(nil, { a, b:
			toString(a.vertexGroup)
				.compareTo(toString(b.vertexGroup)) });

		g = nil;

		l.forEach(function(x) {
			if((g != nil) && (g != x.vertexGroup))
				str.append(' ');
			str.append(toString(x.domain.length));
			g = x.vertexGroup;
		});
		_zlog('\t<<toString(str)>>');
	}
;

#endif // __DEBUG
