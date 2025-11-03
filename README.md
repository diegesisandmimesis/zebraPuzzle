# zebraPuzzle

A TADS3/adv3 module for solving Zebra Puzzles.

## Description

## Table of Contents

[Getting Started](#getting-started)
* [Dependencies](#dependencies)
* [Installing](#install)
* [Compiling and Running Demos](#running)

[Classes](#classes)
* [ZebraPuzzle](#zebra-puzzle)
* [ZebraPuzzleConfig](#zebra-puzzle-config)
* [ZebraPuzzleSolution](#zebra-puzzle-solution)

[Examples](#examples)

<a name="getting-started"/></a>
## Getting Started

<a name="dependencies"/></a>
### Dependencies

* TADS 3.1.3
* adv3 3.1.3

  These are the most recent versions of the TADS3 VM and adv3 library.

  Any TADS3 toolkit with these versions should work, although all of the
  [diegesisandmimesis](https://github.com/diegesisandmimesis) modules are
  primarily tested with [frobTADS](https://github.com/realnc/frobtads).

* git

  This module is distributed via github, so you'll need some way of
  cloning a git repo to obtain it.

  The process should be similar on any platform using any tools, but the
  command line examples given below were tested on an Ubuntu linux
  machine.  Other OSes and git tools will have a slightly different usage.

<a name="install"/></a>
### Installing

All of the [diegesisandmimesis](https://github.com/diegesisandmimesis) modules
are designed to be installed and used from a common base install directory.

In this example we'll use ``/home/username/tads`` as the base directory.

* Create the module base directory if it doesn't already exists:

  `mkdir -p /home/username/tads`

* Make it the current directory:

  ``cd /home/username/tads``

* Clone this repo:

  ``git clone https://github.com/diegesisandmimesis/fastPath.git``

After the ``git`` command, the module source will be in
``/home/username/tads/fastPath``.

<a name="running"/></a>
### Compiling and Running Demos

Once the repo has been cloned you should be able to ``cd`` into the
``./demo/`` subdirectory and compile the demonstration/test code that
comes with the module.

All the demos are structured in the expectation that they will be compiled
and run from the ``./demo/`` directory.  Again assuming that the module
is installed in ``/home/username/tads/fastPath/``, enter the directory with:
```
# cd /home/username/tads/fastPath/demo
```
Then make one of the demos, for example:
```
# make -a -f makefile.t3m
```
This should produce a bunch of output from the compiler but no errors.  When
it is done you can run the demo from the same directory with:
```
# frob games/game.t3
```
In general the name of the makefile and the name of the compiled story file
will be the same except for the extensions (``.t3m`` for makefiles and
``.t3`` for story files).

<a name="classes"/></a>
## Classes

<a name="zebra-puzzle"/></a>
### ZebraPuzzle

#### Methods

* ``setZebraConfig(obj)``

  Sets the configuration for this puzzle.  Argument must be an instance
  of ``ZebraPuzzleConfig``.

* ``solve()``

  Attempts to solve the puzzle, returning an instance of ``ZebraPuzzleSolution``
  on success, ``nil`` on failure.

<a name="zebra-puzzle-config"/></a>
### ZebraPuzzleConfig

#### Properties

* ``constraints = nil``

  A list of constraints, each one itself a list in one of two forms:

  ```
       [ 'foo', 'bar' ]
  ```
  ...or...
  ```
       [ 'baz', 'quux', { a, b: a == b + 1 } ]
  ```
  The first form is the constraint that the value of "foo" be the same as
  the value of "bar".

  The second form is the constraint that function given as the third
  element must return boolean ``true`` when passed the value of "baz"
  and "quux".  In this example it is the constraint that "baz" equals
  "quux" plus one.

* ``domain = nil``

  The computed domain.  Generated automatically, should not be set by hand.

* ``variables = nil``

  A ``LookupTable`` whose keys are vertex groups and whose values are
  arrays of the variables which are part of each group.

#### Methods

* ``addVariable(grp, id)``
* ``addVariable(grp, lst)``

  Adds a variable.  First arg is the vertex group, second is either a single
  variable name or an array of variable names.

* ``addConstraint(id0, id1)``
* ``addConstraint(id0, id1, fn)``

  Adds a constraint.  There are two forms.

  The first form has two arguments and will create the constraint that
  the variable named in the first argument must have the same value as
  the variable named in the second argument.

  The second form takes three argumens and creates a constraint on
  the values of the variables named in the first two arguments.  Their
  values will be passed to the function given in the third argument,
  and the constraint is that the function must return boolean ``true``.


<a name="zebra-puzzle-solution"/></a>
### ZebraPuzzleSolution

#### Properties

* ``data = nil``

  An array of ``LookupTable`` instances containing the solution.  Each
  lookup table corresponds to one item, the keys are vertex groups, and
  the value is the variable for that group possessed by the item.

  For example, in the classic zebra puzzle the first element of the
  array would be an table ``[ 'color' -> 'yellow', 'country' -> 'Norway',
  'drink' -> 'water', 'brand' -> 'Kool', 'pet' -> 'fox' ]`` .

#### Methods

* ``log()``

  Outputs the solution as text.


<a name="examples"/></a>
## Examples

The classic Zebbra Puzzle is (quoting from wikipedia):

1. There are five houses.
2. The Englishman lives in the red house.
3. The Spaniard owns the dog.
4. Coffee is drunk in the green house.
5. The Ukrainian drinks tea.
6. The green house is immediately to the right of the ivory house.
7. The Old Gold smoker owns snails.
8. Kools are smoked in the yellow house.
9. Milk is drunk in the middle house.
10. The Norwegian lives in the first house.
11. The man who smokes Chesterfields lives in the house next to the man with the fox.
12. Kools are smoked in the house next to the house where the horse is kept.
13. The Lucky Strike smoker drinks orange juice.
14. The Japanese smokes Parliaments.
15. The Norwegian lives next to the blue house.

This can be solved first by converting it into a ``ZebraPuzzleConfig``:
```
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
		[ 'green', 'ivory', { a, b: a == b + 1 } ],
		[ 'Old Gold', 'snails' ],
		[ 'Kool', 'yellow' ],
		[ 'milk', 3 ],
		[ 'Norway', 1 ],
		[ 'Chesterfield', 'fox', { a, b: abs(a - b) == 1 } ],
		[ 'Kool', 'horse', { a, b: abs(a - b) == 1 } ],
		[ 'Lucky Strike', 'orange juice' ],
		[ 'Japan', 'Parliament' ],
		[ 'Norway', 'blue', { a, b: abs(a - b) == 1 } ]
	]
;
```
The ``variables`` declaration groups properties of the same type into
a single list.

The ``constraints`` declaration enumerates the constraints in two
forms.  The constraint:
```
    [ `England`, 'red' ]
```
represents the second statement.  It means "the house the person from England
lives in is the same number as the house which is red".

The constraint:
```
        [ 'green', 'ivory', { a, b: a == b + 1 } ],
```
represents the sixth statement.  It means "the number of the green house is
the number of the ivory house plus one".  The function can be anything
but must take two arguments, the numbers of the two houses.

Having created the config, it can be used to create a ``ZebraPuzzle``
instance:
```
     local g = new ZebraPuzzle(zebraPuzzleConfig);
```
The ``solve()`` method can be called to attempt to solve the puzzle.  It
will return a ``ZebraPuzzleSolution`` instance on success, or ``nil`` on
failure.
```
    // Attempt to solve the puzzle.
    local r = g.solve();

    // Check the return value.
    if(r == nil)
        return(nil);

    // Output the solution.
    r.log();

```
This will output something like
```
Item 1:
   color: yellow
   country: Norway
   drink: water
   brand: Kool
   pet: fox
Item 2:
   color: blue
   country: Ukraine
   drink: tea
   brand: Chesterfield
   pet: horse
Item 3:
   color: red
   country: England
   drink: milk
   brand: Old Gold
   pet: snails
Item 4:
   color: ivory
   country: Spain
   drink: orange juice
   brand: Lucky Strike
   pet: dog
Item 5:
   color: green
   country: Japan
   drink: coffee
   brand: Parliament
   pet: zebra
```

The ``ZebraPuzzleSolution`` instance has a ``.data`` property that you can
use directly as well.

It will consist of an array of ``LookupTable`` instances with each
``LookupTable`` corresponding to a single house.  Something like:
```
    [
        [ 'color' -> 'yellow, 'country' -> 'Norway', 'drink' -> 'water',
            'brand' -> 'Kool', 'pet' -> 'fox ],
        [ 'color' -> 'blue', 'country' -> 'Ukraine', 'drink' -> 'tea',
            'brand' -> 'Chesterfield', 'pet' -> 'horse', ],
        [ 'color' -> 'red', 'country' -> 'England', 'drink' -> 'milk',
            'brand' -> 'Old Gold', 'pet' -> 'snails', ],
        [ 'color' -> 'ivory', 'country' -> 'Spain', 'drink' -> 'orange juice',
            'brand' -> 'Lucky Strike', 'pet' -> 'dog', ],
        [ 'color' -> 'green', 'country' -> 'Japan', 'drink' -> 'coffee',
            'brand' -> 'Parliament', 'pet' -> 'zebra', ]

    ]
```


In addition to how the configuration was declared above, you can create
an empty config and add to it programmatically.  For example:
```
    local cfg = new ZebraPuzzleConfig();

    cfg.addVariable('color', 'red');
    cfg.addVariable('color', 'green');
    cfg.addVariable('color', 'ivory');
    cfg.addVariable('color', 'yellow');
    cfg.addVariable('color', 'blue');
```
...or alternately...
```
    cfg.addVariable('pet',
        [ 'dog', 'snails', 'fox', 'horse', 'zebra' ]);
```
And constraints can be added via a similar syntax:
```
    cfg.addConstraint('England', 'red');
    cfg.addConstraint('green', 'ivory', { a, b: a == b + 1 });
```
