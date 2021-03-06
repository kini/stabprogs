.. This README file is formatted using the lightweight markup language
   reStructuredText. Vanilla reStructuredText does not support inline
   LaTeX, so converting this file to HTML using docutils is not
   ideal. Try using `Sphinx <http://sphinx.pocoo.org/>`_ instead.
.. default-role:: math



wlrefine
========

This is an implementation of the Weisfeiler-Leman algorithm for
finding the coarsest *cellular* refinement of a given partition of the
Cartesian square of a finite set. This is implemented fundamentally in
a matrix paradigm, where the finite set is realized as `\{0, 2, \dots,
n-1\}`, and the Cartesian square of the finite set is realized as the
set of entries of an `n \times n` matrix.



License
-------

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.



Authors
-------

- Keshav Kini <kini@member.ams.org> is me, the maintainer of this
  collection and author of a revised STABIL implementation, found in
  ``STABIL.c`` and associated files.

- Luitpold Babel <luitpold.babel@unibw.de> and Dmitrii Pasechnik
  <dimpase@gmail.com> are the authors of the original implementation
  (found in ``rus2.c``) of the STABIL algorithm described in [Bab]_,
  from which description it departs somewhat. Luitpold Babel is also
  an author of the algorithm STABCOL and wrote the implementation of
  it found in ``ger1.c``. Both of these files were made available by
  Dmitrii Pasechnik at <http://bit.ly/aVF0BH> under the terms of the
  GNU General Public License v3.



Background
----------

A *cellular* partition of the Cartesian square of a finite set
`\Omega` is one satisfying two conditions:

1. Given any three (not necessarily distinct) classes `i`, `j`, and
   `k` in the partition, the number of `w` in `\Omega` such that
   `(u,w)` is in class `i` and `(w,v)` is in class `j` is constant
   over all pairs `(u,v)` in class `k`.
2. Every class `i` in the partition must have a corresponding class
   `j` such that `(u,v)` is in class `i` if and only if `(v,u)` is in
   class `j`, for all `u` and `v` in `\Omega`.

This definition can be restated in terms of the matrix paradigm
described above. Supposing there are `d` many distinct entries in the
matrix `A` representing the partition, create a series of matrices
`A_i` with `0 < i \leq d`, such that the entries of `A_i` are equal to
`1` where the corresponding entries of `A` were equal to `i`, and `0`
where the entries of `A` were anything other than `i`. (Note that
`\sum_{i=1}^d A_i` is the identity matrix.)

Then the partition represented by `A` is *cellular* if and only if for
every `i` and `j`, the matrix `A_i A_j` can be written as a linear
combination of the various `A_k` for `0 < k \leq d`. The coefficients
may come from any ring containing the integers, but it can be shown
that circumstances of these matrices then force the coefficients to be
nonnegative integers. This means that the matrices `A_i` form the
basis for a matrix algebra, which is one of the motivations for the
concept.

A partition is furthermore called *coherent* if it is cellular and
each of its classes lies fully on or fully off the diagonal of the
Cartesian square in question. Equivalently in matrix terms, no entries
on the diagonal can be equal to any entries off the diagonal of the
matrix representing the partition.



Weisfeiler-Leman Algorithm
--------------------------

The *Weisfeiler-Leman refinement algorithm* accepts as input an
arbitrary partition of the Cartesian square of a finite set
`\Omega`. It then finds the coarsest partition which is a refinement
of the input partition and is also a cellular partition. This exists
and is unique. The main application of the algorithm is in graph
theory, where the Cartesian square of a finite set `V` is viewed as
the list of all edges and vertices of the complete graph on the vertex
set `V`.  A partition of this set is then a coloring of the edges and
vertices of the complete graph on `V`.

A non-complete graph on `V` can be identified with a coloring of the
complete graph using two colors, "existent" and "non-existent" for the
edges, and a third color for the vertices. Then the *automorphism
partition* of the resulting graph can be defined as the finest
refinement of the coloring that is still invariant under all
automorphisms of the original graph (i.e. no vertex or edge will
change color when the vertex permutation described by a particular
automorphism of the graph is applied to the vertex set).

It is known that the Weisfeiler-Leman refinement of a partition
arising from a graph coloring as described above is a both a
refinement of the original coloring and a coarsening of the
automorphism partition. The determination of the automorphism
partition is an important problem in graph theory, and the
Weisfeiler-Leman refinement can be considered a polynomial-time
approximation.

For a more in-depth treatment of how the algorithm works, please refer
to [Bab]_.



Files
-----

The files provided in this package are as follows:

- ``LICENSE``: the GNU General Public License v3, under which this
  code is released.
- ``Makefile``: the makefile.
- ``germ1.c``: Luitpold Babel's implementation of the STABCOL
  algorithm, slightly modified to uniformize how it handles input and
  output. Builds to ``STABCOL``.
- ``rus2.c``: Luitpold Babel's and Dmitrii Pasechnik's implementation
  of the STABIL algorithm, similarly I/O-uniformized. Builds to
  ``STABIL.old``.
- ``STABIL.c``, ``STABIL.h``, ``STABIL-tests.h``, ``main.c``: My
  implementation of the STABIL algorithm based on the above. Various
  changes/improvements are detailed in the code comment at the
  beginning of ``STABIL.c``. Builds to ``STABIL``.
- ``*.in``: input files for STABIL, STABIL.old, and STABCOL.
- ``wlrefine.pyx``: a Cython file implementing a wrapper for my new
  STABIL code, which allows it to be called from the Sage mathematical
  software distribution. It also provides a function which directly
  interprets a Sage graph (or NetworkX graph).
- ``README``: this file.
- ``README.old``: the README that Luitpold Babel and Dmitrii Pasechnik
  published with their code, for reference.



Usage
-----

Command Line
************

To use the command line version of STABIL, run ``make`` in the
directory where you have extracted the files. If you need to use a
compiler other than GCC, please edit ``Makefile`` appropriately. An
executable file ``STABIL`` should be produced. You may supply input to
STABIL either through stdin or by supplying a pathname on the command
line as a single argument. The input should be an `n \times n` square
matrix `A` containing `d` distinct entries, specifically `0, \dots,
d-1`. The matrix should be supplied in the following form::

    d
    n
    ? ? ... ?
    ? ? ... ?
    . . .   .
    . .  .  .
    . .   . .
    ? ? ... ?

See the various ``.in`` files included in this package for
examples. After providing STABIL with your input, you need only wait
for it to produce the Weisfeiler-Leman refinement of your
partition. This will be provided in the same format as the input.

STABIL also has a debug flag that can be set by telling the C
preprocessor to define "DEBUG" before compiling. The provided makefile
has a line which will do this for you - simply uncomment the line
marked "Debugging" and comment the ones marked "Development" and
"Release" in order to set the correct CFLAGS variable. When STABIL is
compiled with the debug flag set, it will dump a lot of data about the
refinement process into stdout. You can of course pipe this to a file
for further perusal if you so desire.

If you would like to use STABIL.old or STABCOL as well, run ``make
all`` in the directory. The operating procedures for the resulting
executables ``STABIL.old`` and ``STABCOL`` are the same as just
described. Alternatively, ``make test`` will first run ``make all``
and then automatically test all three programs using the input file
``1.in``.

Note that while the Weisfeiler-Leman refinement of a given partition
is unique, the output of these three programs may differ, because they
may number the partition's classes in a different order.

Sage
****

To use the Cython version of STABIL from the Sage interpreter, simply
type ``load "wlrefine.pyx"`` from the interpreter prompt, after which
you will be able to run the WL and GraphWL functions. For information
about how to use them, see the comments in ``wlrefine.pyx`` or type
``WL?`` or ``GraphWL?`` at the Sage prompt.

I am also exploring other ways to incorporate this code into Sage, but
that is beyond the scope of this package.



References
----------

.. [Bab] L. Babel, I. V. Chuvaeva, M. Klin, D. V. Pasechnik. Program
   Implementation of the Weisfeiler-Leman Algorithm.  arXiv preprint
   1002.1921v1 <http://arxiv.org/abs/1002.1921>.
