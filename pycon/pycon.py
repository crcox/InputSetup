from . import utils
def expand_stub(stub):
    EXPAND = stub['ExpandFields']
    del stub['ExpandFields']

    nPerField = []
    for field in EXPAND:
        try:
            nPerField.append(len(stub[field]))
        except TypeError:
            flength = []
            for k in field:
                flength.append(len(stub[k]))

            n = flength[0]
            if not all(fl==n for fl in flength):
                print "condortools:ExpandStub:error: Linked fields are of different lengths."
                raise IndexError

            nPerField.append(n)

    N = reduce(mul, nPerField, 1)

    master = [dict(stub) for i in xrange(N)]
    for i in xrange(N):
        inds = utils.ind2sub(nPerField, i)
        for ii,field in enumerate(EXPAND):
            try:
                master[i][field] = stub[field][inds[ii]]
            except TypeError:
                for k in field:
                    master[i][k] = stub[k][inds[ii]]

    return master
