from operator import mul
from numpy import unravel_index

def ind2sub( sizes, index ):
    """
    Map a scalar index of a flat 1D array to the equivalent
    d-dimensional index
    Example:
    | 1  4  7 |      | 1,1  1,2  1,3 |
    | 2  5  8 |  --> | 2,1  2,2  2,3 |
    | 3  6  9 |      | 3,1  3,2  3,3 |
    """
    denom = reduce(mul, sizes, 1)
    num_dims = len(sizes)
    multi_index = [0 for i in range(num_dims)]
    for i in xrange( num_dims - 1, -1, -1 ):
        denom /= sizes[i]
        multi_index[i] = index / denom
        index = index % denom
    return multi_index

dims = (2,2,2)
UR=[unravel_index(i,dims) for i in xrange(8)]
CR=[ind2sub(dims, i) for i in xrange(8)]
RR=[ind2sub(dims, i)[::-1] for i in xrange(8)]

print UR
print CR
print RR
