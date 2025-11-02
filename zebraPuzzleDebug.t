#charset "us-ascii"
//
// zebraPuzzle.t
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
