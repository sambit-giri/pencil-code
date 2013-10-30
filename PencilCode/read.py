#=======================================================================
# read.py
#
# Facilities for reading the Pencil Code data.
#
# Chao-Chin Yang, 2013-05-06
# Last Modification: $Id$
#=======================================================================
def avg1d(datadir='./data', plane='xy'):
    """Returns the time series of 1D averages.

    Keyword Arguments:
        datadir
            Name of the data directory
        plane
            plane of average: 'xy', 'xz', or 'yz'
    """
    # Chao-Chin Yang, 2013-10-28

    # Read the dimensions and check the plane of average.
    dim = dimensions(datadir=datadir)
    if plane == 'xy':
        nc = dim.nzgrid
    elif plane == 'xz':
        nc = dim.nygrid
    elif plane == 'yz':
        nc = dim.nxgrid
    else:
        raise ValueError("Keyword plane only accepts 'xy', 'xz', or 'yz'. ")

    # Read the names of the variables.
    var = varname(datadir=datadir+'/..', filename=plane.strip()+'aver.in')
    print("Reading 1D averages", var, "...")

    # Open file and define data stream.
    f = open(datadir.strip() + '/' + plane.strip() + 'averages.dat')
    from collections import deque
    queue = deque([float(a) for a in f.readline().split()])
    eof = False
    def pop(newline=False):
        nonlocal eof
        x = float(queue.popleft())
        if newline:
            queue.clear()
        if len(queue) == 0:
            for a in f.readline().split():
                queue.append(float(a))
            if len(queue) == 0:
                eof = True
        return x
    def stream(n):
        return [pop() for i in range(n)]

    # Read the data.
    import numpy as np
    a = np.core.records.array(len(var) * [np.zeros(nc)], names=var)
    t = [pop(newline=True)]
    for v in var:
        a[v] = np.array(stream(nc))
    avg = a
    while not eof:
        t.append(pop(newline=True))
        for v in var:
            a[v] = np.array(stream(nc))
        avg = np.vstack([avg, a])

    # Close file.
    f.close()

    return np.array(t), avg.view(np.recarray)

#=======================================================================
def dimensions(datadir='./data'):
    """Returns the dimensions of the Pencil Code data from datadir.

    Keyword Arguments:
        datadir
            Name of the data directory
    """
    # Chao-Chin Yang, 2013-10-23

    # Read dim.dat.
    f = open(datadir.strip() + '/dim.dat')
    a = f.read().rsplit()
    f.close()

    # Sanity check
    if a[6] == '?':
        print('Warning: unknown data precision. ')
    if not a[7] == a[8] == a[9]:
        raise Exception('unequal number of ghost zones in different directions. ')

    # Extract the dimensions.
    mxgrid, mygrid, mzgrid, mvar, maux, mglobal = (int(b) for b in a[0:6])
    double_precision = a[6] == 'D'
    nghost = int(a[7])
    nxgrid, nygrid, nzgrid = (int(b) - 2 * nghost for b in a[0:3])
    nprocx, nprocy, nprocz = (int(b) for b in a[10:13])
    procz_last = int(a[13]) == 1

    # Define and return a named tuple.
    from collections import namedtuple
    Dimensions = namedtuple('Dimensions', ['nxgrid', 'nygrid', 'nzgrid', 'nghost', 'mxgrid', 'mygrid', 'mzgrid',
                                           'mvar', 'maux', 'mglobal', 'double_precision',
                                           'nprocx', 'nprocy', 'nprocz', 'procz_last'])
    return Dimensions(nxgrid=nxgrid, nygrid=nygrid, nzgrid=nzgrid, nghost=nghost, mxgrid=mxgrid, mygrid=mygrid, mzgrid=mzgrid,
                      mvar=mvar, maux=maux, mglobal=mglobal, double_precision=double_precision,
                      nprocx=nprocx, nprocy=nprocy, nprocz=nprocz, procz_last=procz_last)

#=======================================================================
def proc_dim(datadir='./data', proc=0):
    """Returns the dimensions of the data from one process.

    Keyword Arguments:
        datadir
            Name of the data directory
        proc
            Process ID
    """
    # Chao-Chin Yang, 2013-10-23

    # Read dim.dat.
    f = open(datadir.strip() + '/proc' + str(proc) + '/dim.dat')
    a = f.read().rsplit()
    f.close()

    # Sanity Check
    if a[6] == '?':
        print('Warning: unknown data precision. ')
    if not a[7] == a[8] == a[9]:
        raise Exception('unequal number of ghost zones in every direction. ')

    # Extract the dimensions.
    mx, my, mz, mvar, maux, mglobal = (int(b) for b in a[0:6])
    double_precision = a[6] == 'D'
    nghost = int(a[7])
    nx, ny, nz = (int(b) - 2 * nghost for b in a[0:3])
    iprocx, iprocy, iprocz = (int(b) for b in a[10:13])

    # Define and return a named tuple.
    from collections import namedtuple
    Dimensions = namedtuple('Dimensions', ['nx', 'ny', 'nz', 'nghost', 'mx', 'my', 'mz', 'mvar', 'maux', 'mglobal',
                                           'double_precision', 'iprocx', 'iprocy', 'iprocz'])
    return Dimensions(nx=nx, ny=ny, nz=nz, nghost=nghost, mx=mx, my=my, mz=mz, mvar=mvar, maux=maux, mglobal=mglobal,
                      double_precision=double_precision, iprocx=iprocx, iprocy=iprocy, iprocz=iprocz)

#=======================================================================
def time_series(datadir='./data'):
    """Returns a NumPy recarray from the time series.

    Keyword Arguments:
        datadir
            Name of the data directory
    """
    # Chao-Chin Yang, 2013-05-13

    # Import necessary modules.
    from numpy import recfromtxt
    from io import BytesIO

    # Save the data path.
    path = datadir.strip()

    # Read legend.dat.
    f = open(path + '/legend.dat')
    names = f.read().replace('-', ' ').split()
    f.close()

    # Read time_series.dat.
    f = open(path + '/time_series.dat')
    ts = recfromtxt(BytesIO(f.read().encode()), names=names)
    f.close()

    return ts

#=======================================================================
def varname(datadir='./data', filename='varname.dat'):
    """Returns the names of variables.

    Keyword Arguments:
        datadir
            Name of the data directory
        filename
            Name of the file containing variable names
    """
    # Chao-Chin Yang, 2013-05-13

    # Read varname.dat.
    f = open(datadir.strip() + '/' + filename.strip())
    var = []
    for line in f:
        try:
            var.append(line.split()[1])
        except:
            var.append(line.split()[0])
    f.close()

    return var

