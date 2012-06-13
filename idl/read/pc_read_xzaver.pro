;;
;; $Id$
;;
;;  Read xz-averages from file.
;;
;;  NOTE: Please always edit pc_read_xyaver, pc_read_xzaver and pc_read_yzaver
;;  in symmetry!
;;
pro pc_read_xzaver, object=object, varfile=varfile, datadir=datadir, $
    monotone=monotone, quiet=quiet
COMPILE_OPT IDL2,HIDDEN
COMMON pc_precision, zero, one
;;
;;  Default data directory.
;;
if (not keyword_set(datadir)) then datadir=pc_get_datadir()
default, varfile, 'xzaverages.dat'
default, monotone, 0
default, quiet, 0
;;
;;  Get necessary dimensions.
;;
pc_read_dim, obj=dim, datadir=datadir, quiet=quiet
pc_set_precision, dim=dim, quiet=quiet
ny=dim.ny
;;
;;  Read variables from xzaver.in
;;
spawn, "echo "+datadir+" | sed -e 's/data\/*$//g'", datatopdir
spawn, 'cat '+datatopdir+'/xzaver.in', varnames
if (not quiet) then print, 'Preparing to read xz-averages ', $
    arraytostring(varnames,quote="'",/noleader)
nvar=n_elements(varnames)
;;
;;  Check for existence of data file.
;;
get_lun, file
filename=datadir+'/'+varfile
if (not quiet) then print, 'Reading ', filename
if (not file_test(filename)) then begin
  print, 'ERROR: cannot find file '+ filename
  stop
endif
close, file
openr, file, filename
;;
;;  Define arrays to put data in.
;;
spawn, 'wc -l '+datadir+'/'+varfile, nlines
nlines=long(nlines[0])
nit=nlines/(1+nvar*ny/8)
;
if (not quiet) then print, 'Going to read averages at ', strtrim(nit,2), ' times'
;
;  Generate command name. Note that an empty line in the xzaver.in
;  file will lead to problems. If this happened, you may want to replace
;  the empty line by a non-empty line rather than nothing, so you can
;  read the data with idl.
;
for i=0,nvar-1 do begin
  cmd=varnames[i]+'=fltarr(ny,nit)*one'
  if (execute(cmd,0) ne 1) then message, 'Error defining data arrays'
endfor
var=fltarr(ny*nvar)*one
times =fltarr(nit)*one
;;
;;  Read xz-averages and put in arrays.
;;
for it=0,nit-1 do begin
;; Read time
  readf, file, t
  times[it]=t
;; Read data
  readf, file, var
  for i=0,nvar-1 do begin
    cmd=varnames[i]+'[*,it]=var[i*ny:(i+1)*ny-1]'
    if (execute(cmd,0) ne 1) then message, 'Error putting data in array'
  endfor
endfor
;;
;;  Close file.
;;
close, file
free_lun, file
;;
;;  Make time monotonous and crop all variables accordingly.
;;
if (monotone) then begin
  ii=monotone_array(times)
endif else begin
  ii=lindgen(n_elements(times))
endelse
;;
;;  Read y array from file.
;;
pc_read_grid, obj=grid, /trim, datadir=datadir, /quiet
;;
;;  Put data in structure.
;;
makeobject="object = create_struct(name=objectname,['t','y'," + $
    arraytostring(varnames,quote="'",/noleader) + "]," + $
    "times[ii],grid.y,"+arraytostring(varnames+'[*,ii]',/noleader) + ")"
;
if (execute(makeobject) ne 1) then begin
  message, 'Error evaluating variables: ' + makeobject, /info
  undefine,object
endif
;
end
