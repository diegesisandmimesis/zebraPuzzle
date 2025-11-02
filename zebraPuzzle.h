//
// zebraPuzzle.h
//

#include "dataTypes.h"
#ifndef DATA_TYPES_H
#error "This module require the dataTypes module."
#error "https://github.com/diegesisandmimesis/dataTypes"
#error "It should be in the same parent directory as this module.  So if"
#error "zebraPuzzle is in /home/user/tads/zebraPuzzle, then"
#error "dataTypes should be in /home/user/tads/dataTypes ."
#endif // DATA_TYPES_H

#define isZebraPuzzle(obj) isType(obj, ZebraPuzzle)
#define isZebraPuzzleConfig(obj) isType(obj, ZebraPuzzleConfig)

#define ZEBRA_PUZZLE_H
