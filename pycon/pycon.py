from . import utils
import operator
def expand_stub(stub):
    EXPAND = stub['EXPAND']
    del stub['EXPAND']

    nPerField = []
    for i,field in enumerate(EXPAND):
        try:
            # This will fail with an error if field is not a valid key for any reason.
            nPerField.append(len(stub[field]))

        except KeyError:
            # This will occur if the field is a string but doesn't match an existing key.
            # The only case in which this isn't a fatal error is if the last
            # character of the string is an underscore.
            if field[-1] == '_':
                nPerField.append(len(stub[field[0:-1]]))
            else:
                raise

        except TypeError:
            # This will occur if field is not a string (Code assumes it is a list)
            flength = []
            for k in field:
                try:
                    flength.append(len(stub[k]))
                except KeyError:
                    if k[-1] == '_':
                        # This ASSUMES that stub[k] is a matrix, and we need to
                        # attend to the second dimension. Just check the length
                        # of the first "row".
                        flength.append(len(stub[k[0:-1]][0]))
                    else:
                        raise

            n = flength[0]
            if not all(fl==n for fl in flength):
                print "condortools:ExpandStub:error: Linked fields are of different lengths."
                raise IndexError

            nPerField.append(n)

    N = reduce(operator.mul, nPerField, 1)

    master = [dict(stub) for i in xrange(N)]
    for i in xrange(N):
        inds = utils.ind2sub(nPerField, i)
        for ii,field in enumerate(EXPAND):
            try:
                master[i][field] = stub[field][inds[ii]]
            except TypeError:
                for k in field:
                    # Check if there is a complimentary entry somewhere else in
                    # the command structure. If so, both indexes need to be
                    # considered at once. Note that this supports only pairs of
                    # complementary entries... matching on 3 or more dimensions
                    # of a single parameter is unsupported.
                    for jj,field in enumerate(EXPAND):
                        if k[-1] == '_':
                            if k[-1] in EXPAND[jj]:
                                # In this case, the "current" index (ii) refers
                                # to the second dimension of the paired entry.
                                master[i][k[0:-1]] = stub[k[0:-1]][inds[jj]][inds[ii]]
                        else:
                            if k+'_' in EXPAND[jj]:
                                # In this case, the "current" index (ii) refers
                                # to the first dimension of the paired entry.
                                master[i][k] = stub[k][inds[ii]][inds[jj]]
                            else:
                                # In this case, there is no complementary entry
                                # so it is a simple 1D index (with ii).
                                master[i][k] = stub[k][inds[ii]]

    return master
# How it works:
# First, we check to see how many jobs we are going to create. This is done by
# the following logic:
# 1. Loop over the items listed under the EXPAND field.
#   - If the current item is a string, it is treated as a field name that will
#   reference a list of parameters included elsewhere in the stub structure.
#   - If the current item is a list, then iterate through that list. If the
#   list elements are strings, then they are treated as field names that
#   reference a list of parameters stored elsewhere in the stub structure.
#      - If this second loop is necessary, and all the elements within this
#      nested list are strings that resolve to valid field names, then all of
#      the referenced lists of parameters must be of the same length. These
#      lists will be iterated through with a single index. Another way to put
#      it, is that these parameters will be indexed as if they are stored in a
#      list of lists such as [[A1,B1,C1], [A2,B2,C2]].
#
