import shutil
import math
import operator
import sys
if sys.version_info >= (3, 0):
    from functools import reduce
def ind2sub( sizes, index ):
    """
    Map a scalar index of a flat 1D array to the equivalent
    d-dimensional index
    Example:
    | 1  4  7 |      | 1,1  1,2  1,3 |
    | 2  5  8 |  --> | 2,1  2,2  2,3 |
    | 3  6  9 |      | 3,1  3,2  3,3 |
    """
    denom = reduce(operator.mul, sizes, 1)
    num_dims = len(sizes)
    multi_index = [0 for i in range(num_dims)]
    for i in range( num_dims - 1, -1, -1 ):
        denom /= sizes[i]
        multi_index[i] = int(index / denom)
        index = index % denom
    return multi_index

def ndigits(i):
    """ Return the number of digits in an integer. """
    if i > 0:
        d = int(math.log10(i))+1
    elif i == 0:
        d = 1
    else:
        d = int(math.log10(-n))+1
    return d

def lstrip_pattern(string, pattern):
    n=len(pattern)
    return string[n:] if string.startswith(pattern) else string

def flatten(list_of_lists):
    flat = []
    for sublist in list_of_lists:
        if isinstance(sublist,list):
            x = flatten(sublist)
            flat.extend(x)
        else:
            flat.append(sublist)
    return flat
