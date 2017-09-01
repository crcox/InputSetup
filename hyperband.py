# you need to write the following hooks for your custom problem
#from problem import get_random_hyperparameter_configuration,run_then_return_val_loss
from numpy import argsort, ceil, log, random
def get_random_hyperparameter_configuration(distribution, args):
    if distribution == 'uniform':
        return random.uniform(low = args[0], high = args[1])

def hyperband(max_iter, eta):
    logeta = lambda x: log(x)/log(eta)
    s_max = int(logeta(max_iter))  # number of unique executions of Successive Halving (minus one)
    B = (s_max+1)*max_iter  # total number of iterations (without reuse) per execution of Succesive Halving (n,r)

    #### Begin Finite Horizon Hyperband outlerloop. Repeat indefinetely.
    BRACKET = []
    for s in reversed(range(s_max+1)):
        n = int(ceil(B/max_iter/(s+1)*eta**s))
        r = int(max_iter*eta**(-s))
        BRACKET.append({'s':s,'n':n,'r':r})

    return BRACKET

if __name__ == "__main__":
    max_iter = 100
    eta = 3
    distribution = 'uniform'
    args = [1,16]
    bracket = hyperband(max_iter, eta)
    lam = [ [get_random_hyperparameter_configuration(distribution, args) for i in range(s['n'])] for s in bracket]
    for s,l in zip(bracket,lam):
        print(s)
        print(l)
        print()

