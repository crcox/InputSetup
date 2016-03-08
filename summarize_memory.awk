#!/bin/awk

BEGIN{
  FS=",";
  MIN=9999999;
  MAX=-1;
  SUM=0;
}
{
  SUM=SUM+$4;
  if ($4>MAX) MAX=$4;
  if ($4<MIN) MIN=$4;
}
END{
  print "Memory summary (in MB)"
  print "----------------------"
  print "min:",MIN;
  print "max:",MAX;
  print "mean:",SUM/NR
}
