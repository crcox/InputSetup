#!/bin/awk

BEGIN{
  FS=",";
  MIN=9999999;
  MAX=-1;
  SUM=0;
}
{
  split($4, t, ":");
  T=60*t[1]+t[2]+1;
  SUM=SUM+T;
  if (T>MAX) MAX=T;
  if (T<MIN) MIN=T;
}
END{
  print "Time summary (in minutes)"
  print "-------------------------"
  print "min:",MIN;
  print "max:",MAX;
  print "mean:",SUM/NR;
}
