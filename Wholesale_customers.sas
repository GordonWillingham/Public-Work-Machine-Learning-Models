proc import datafile="\\apporto.com\dfs\CLT\Users\gwillin3_clt\Desktop\Data\wholesale_customers.xls"
DBMS=xls out= wscust replace;

proc univariate data=wscust normal plot;
var milk detergents_paper frozen;
run;

data mod_wscust; set wscust;
if milk > 15000 then delete;
if detergent_paper > 10000 then delete;
if frozen > 8000 then delete;
run;

proc fastclus data=mod_wscust maxcluster=8 out=clust converge=0 MAXITER=20;
var frozen milk detergents_paper;
run;
proc freq data=Clust;
 tables region*Cluster;
 run;
