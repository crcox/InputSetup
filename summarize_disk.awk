#!/bin/awk

function human(x) {
  if (x<1000) {return x} else {x/=1024}
  s="kMGTEPYZ";
  while (x>=1000 && length(s)>1)
    {x/=1024; s=substr(s,2)}
  return sprintf("%.2f %sB", x, substr(s,1,1))
}
{$4=$4*1000}
BEGIN{
  FS=",";
  MIN=9999999;
  MAX=-1;
  SUM=0;
}
{
  SUM=SUM+($4);
  if ($4>MAX) MAX=$4;
  if ($4<MIN) MIN=$4;
}
END{
  print "Disk summary (in KB)"
  print "--------------------"
  print "min:",human(MIN);
  print "max:",human(MAX);
  print "mean:",human(SUM/NR)
}
