r"""
Weisfeiler-Leman algorithm

The Weisfeiler-Leman algorithm for finding the coarsest coherent refinement of
a partition of `\Omega \times \Omega` for some finite set Omega. Applicable
to colored digraphs as a recoloration that refines the partition of arcs and
loops by colors. In some cases may return the automorphism partition of the
graph; in all cases returns something of which the automorphism partition of
the graph is a refinement.

AUTHORS:

- Keshav Kini (2010-10-14)

EXAMPLES:

Refine the product with itself of the cyclic graph on five points::

    sage: from sage.graphs.wlrefine import GraphWL
    sage: g = graphs.CycleGraph(5)
    sage: gg = g.cartesian_product(g)
    sage: gg2 = GraphWL(gg)
    sage: gg2
    Looped digraph on 25 vertices
    sage: set(gg2.edge_labels())
    set([1, 2, 3, 4, 5])

Refine a certain test matrix::

    sage: from sage.graphs.wlrefine import WL
    sage: m = Matrix(8, 8, [3, 1, 2, 1, 1, 2, 2, 2, 1, 0, 1, 2, 2, 1, 2, 2, 2,
    ...   1, 3, 1, 2, 2, 1, 2, 1, 2, 1, 0, 2, 2, 2, 1, 1, 2, 2, 2, 0, 1, 2,
    ...   1, 2, 1, 2, 2, 1, 3, 1, 2, 2, 2, 1, 2, 2, 1, 0, 1, 2, 2, 2, 1, 1,
    ...   2, 1, 3])
    sage: m
    [3 1 2 1 1 2 2 2]
    [1 0 1 2 2 1 2 2]
    [2 1 3 1 2 2 1 2]
    [1 2 1 0 2 2 2 1]
    [1 2 2 2 0 1 2 1]
    [2 1 2 2 1 3 1 2]
    [2 2 1 2 2 1 0 1]
    [2 2 2 1 1 2 1 3]
    sage: m2 = WL(m)
    sage: m2
    [1 2 3 2 2 3 5 3]
    [4 0 4 6 6 4 6 7]
    [3 2 1 2 5 3 2 3]
    [4 6 4 0 6 7 6 4]
    [4 6 7 6 0 4 6 4]
    [3 2 3 5 2 1 2 3]
    [7 6 4 6 6 4 0 4]
    [3 5 3 2 2 3 2 1]

"""
# XXX Implicitly continued lines in the sage interpreter start with "....: ",
# not "... "; doctests do not work unless we use "... ", though. Something to
# fix? EDIT: this is handled by sage trac #10458. Please change the line
# continuation prompts appropriately if/when #10458 is resolved.

#   wlrefine.pyx
#   
#   See STABIL.c for an explanation.
#   
#   - Keshav Kini <kini@member.ams.org>, 2010-10-14
#

from libc.stdlib cimport malloc, free
import sage.matrix.constructor
import sage.graphs.graph

cdef extern from "STABIL.c":
    int STABIL(unsigned long* matrix, unsigned long n, unsigned long* d)

def WL(mat, fix_colors=True, algorithm="STABIL"):
    r"""
    Perform Weisfeiler-Leman refinement on a matrix.
    
    INPUT:
    
    - ``mat`` -- a square Sage matrix whose set of entries is the set of
      consecutive integers from 0 to some d-1 and whose diagonal entries do
      not occur outside the diagonal

    - ``fix_colors`` -- (default: true) if true, we attempt to fix malformed
      data. This process may also alter otherwise valid data.

    - ``algorithm`` -- (default: "STABIL") choose the algorithm to use.
      Currently supported algorithms are: "STABIL" (default)
    
    OUTPUT:
    
    - The Weisfeiler-Leman refinement of mat
    
    EXAMPLES:
    
    Refine a certain test matrix::
        
        sage: from sage.graphs.wlrefine import WL
        sage: m = Matrix(8, 8, [3, 1, 2, 1, 1, 2, 2, 2, 1, 0, 1, 2, 2, 1, 2,
        ...   2, 2, 1, 3, 1, 2, 2, 1, 2, 1, 2, 1, 0, 2, 2, 2, 1, 1, 2, 2, 2,
        ...   0, 1, 2, 1, 2, 1, 2, 2, 1, 3, 1, 2, 2, 2, 1, 2, 2, 1, 0, 1, 2,
        ...   2, 2, 1, 1, 2, 1, 3])
        sage: m
        [3 1 2 1 1 2 2 2]
        [1 0 1 2 2 1 2 2]
        [2 1 3 1 2 2 1 2]
        [1 2 1 0 2 2 2 1]
        [1 2 2 2 0 1 2 1]
        [2 1 2 2 1 3 1 2]
        [2 2 1 2 2 1 0 1]
        [2 2 2 1 1 2 1 3]
        sage: m2 = WL(m)
        sage: m2
        [1 2 3 2 2 3 5 3]
        [4 0 4 6 6 4 6 7]
        [3 2 1 2 5 3 2 3]
        [4 6 4 0 6 7 6 4]
        [4 6 7 6 0 4 6 4]
        [3 2 3 5 2 1 2 3]
        [7 6 4 6 6 4 0 4]
        [3 5 3 2 2 3 2 1]
    
    NOTES:
    
    Uses a reimplementation of STABIL by Keshav Kini, based on original work by
    Luitpold Babel and Dmitrii Pasechnik as described in [Bab]_.
    
    REFERENCES:
    
    .. [Bab] L. Babel, I. V. Chuvaeva, M. Klin, D. V. Pasechnik. Program
       Implementation of the Weisfeiler-Leman Algorithm. arXiv preprint
       1002.1921v1.
    
    AUTHORS:

    - Keshav Kini (2010-12-10)

    """
    cdef unsigned long* c_matrix
    cdef unsigned long c_d
    if (mat.nrows() != mat.ncols()):
        raise ValueError, "Malformed input data! Please provide a square matrix."
    n = mat.nrows()
    mat = [x for y in mat for x in y]
    
    # fix colors, or not
    if (fix_colors):
        diag_map = dict([(y,x) for (x,y) in enumerate(set([mat[i*n+i] for i in range(n)]))])
        c_d = len(diag_map)
        offdiag_map = dict([(y,x+c_d) for (x,y) in enumerate(set([mat[i*n+j] for i in range(n) for j in range(n) if i != j]))])
        c_d += len(offdiag_map)
        for i in range(n):
            for j in range(n):
                if (i == j):
                    mat[i*n + j] = diag_map[mat[i*n + j]]
                else:
                    mat[i*n + j] = offdiag_map[mat[i*n + j]]
    else:
        c_d = max(mat) + 1

    # prepare C matrix for passing to STABIL()
    c_matrix = <unsigned long*>malloc(n*n*sizeof(unsigned long))
    for i in range(n*n):
        c_matrix[i] = mat[i]

    # run STABIL() and interpret the results
    try:
        result = STABIL(c_matrix, n, &c_d)
        if (result == 1):
            raise ValueError, "Malformed input data! Entries of matrix must consist, as a set, of consecutive integers from 0 to some d-1, and diagonal and non-diagonal entries must be disjoint."
        elif (result == 2):
            raise MemoryError, "Could not allocate enough memory!"
        elif (result == 3):
            raise OverflowError, "Predicted overflow! Please do not use matrices larger than 65535x65535."
        result = sage.matrix.constructor.Matrix(n, n, [c_matrix[x] for x in range(n*n)])
    finally:
        free(c_matrix)
    
    return result

def GraphWL(g, digraph=True, ignore_weights=False):
    r"""
    Perform Weisfeiler-Leman refinement on a graph.
    
    INPUT:
    
    - ``g`` -- a Sage looped graph with edge weights representing colors
    
    - ``digraph`` -- (default: True) if false, return an undirected graph
      with colors merged by Sage's coercion (?), which may be desirable in
      some situations
    
    - ``ignore_weights`` -- (default: False) if true, ignore edge weights
    
    OUTPUT:
    
    - g after performing Weisfeiler-Leman refinement on its coloring
    
    EXAMPLES:
    
    Refine the product with itself of the cyclic graph on five points::
    
        sage: from sage.graphs.wlrefine import GraphWL
        sage: g = graphs.CycleGraph(5)
        sage: gg = g.cartesian_product(g)
        sage: gg2 = GraphWL(gg)
        sage: gg2
        Looped digraph on 25 vertices
        sage: set(gg2.edge_labels())
        set([1, 2, 3, 4, 5])
    
    NOTES:
    
    This is a wrapper for the WL() function.

    AUTHORS:

    - Keshav Kini (2010-12-10)
    
    """
    
    if (not g.weighted() or ignore_weights) and not g.has_loops():
        mat = WL(g.adjacency_matrix() + 2, fix_colors=False)                    # g.adjacency_matrix() is a 0-1 matrix so setting the diagonal to 2 satisfies the color conditions for the algorithm
    else:
        mat = WL(g.weighted_adjacency_matrix())
    
    if digraph:
        return sage.graphs.graph.DiGraph(mat, format='weighted_adjacency_matrix')
    else:
        return sage.graphs.graph.Graph(mat, format='weighted_adjacency_matrix')

