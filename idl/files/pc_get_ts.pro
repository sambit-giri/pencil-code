; $$
;
;   Get time series for various parameters from data snapshots
;
;  Author: Anders Johansen (ajohan@astro.ku.dk)
;  $Date: 2003-10-10 12:30:21 $
;  $Revision: 1.1 $
;
;  10-oct-03/anders: coded (coding layout adapted from Tony)
;
;  
pro pc_get_ts,t_arr=t_arr,array=array,snap_start=snap_start,snap_end=snap_end, $
              datadir=datadir,proc=proc,type=type, $
              HELP=HELP,QUIET=QUIET
  COMMON pc_precision, zero, one
; If no meaningful parameters are given show some help!
  IF ( keyword_set(HELP) ) THEN BEGIN
    print, "Usage: "
    print, ""
    print, "pc_get_ts, t_arr=t_arr, array=array, snap_start=snap_start, "
    print, "           snap_end=snap_end, datadir=datadir, proc=proc, "
    print, "           type=type, /HELP, /QUIET"
    print, ""    
    print, "Extracts time series of parameter specified by 'type'."
    print, "The times are stored in 't_arr' and the parameter is stored in 'array'."
    print, "If snap_start and snap_end are specified, the time series is"
    print, "extracted from this range of snapshots. Otherwise all VAR* will"
    print, "be used. Beware that the VAR files must come in numerical order."
    print, ""
    print, "A non-default data directory and a processor number can be"
    print, "specified with 'datadir' (string) and 'proc' (number)."
    print, ""
    print, "/QUIET: Instruction not to print any 'helpful'."
    print, "/HELP: Display this usage information, and exit."
    print, ""
    print, "Types currently implemented:"
    print, "type='uydmean': Mean dust y velocity (AJ)"
    print, ""
    print, "Feel free to add more."
    return
  ENDIF
; Default data directory

default,datadir,'data'
default,proc,0
default,snap_start,0
default,snap_end,0

if (snap_start eq 0 and snap_end eq 0) then begin
  if (not keyword_set(QUIET)) then begin
    print, 'No start and end index specified.'
    print, 'Taking all snapshots from ' + $
           datadir+'/proc'+strcompress(proc,/remove_all)+'.'
  endif
  snap_start=1
  spawn, 'ls data/proc0/VAR* | wc -l', no_snshots
  reads, no_snshots, snap_end
  if (not keyword_set(QUIET)) then begin
    print, 'Found '+strcompress(snap_end,/remove_all) + ' snapshots.'
  endif
endif

array=fltarr(snap_end-snap_start+1)
t_arr=fltarr(snap_end-snap_start+1)

for nsnap=snap_start,snap_end do begin
  if (type eq 'udymean') then begin
    varfile='VAR'+strcompress(nsnap,/remove_all)
    pc_read_var,t=t,uud=uud,varfile=varfile,datadir=datadir,proc=proc, $
                QUIET=QUIET
    t_arr(nsnap-snap_start)=t
    array(nsnap-snap_start)=mean(uud(*,*,*,1))
  endif
endfor


end
