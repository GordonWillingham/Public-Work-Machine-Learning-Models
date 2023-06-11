/* Importing the dataset for .csv format*/
proc import datafile='\\apporto.com\dfs\UNCC\Users\aasha_uncc\Desktop\College.csv'
DBMS=csv out=enroll replace;

/* Printing out the 'enroll' data */
proc print data=enroll;run;

/* Dummy coding for the variable "Private" */
data enroll_dum;
set enroll;
if (private='Yes') then P_1 = 1; else P_1 = 0;
run;

/* Printing out the 'enroll_dum' dataset that includes the coded dummy */
proc print data=enroll_dum;run;

/* Generating boxplot for 'accept', 'top10perc' and 'enroll' with an univariate */
proc univariate data=enroll_dum normal plot;
var accept top10perc enroll; run;

/* Removing outliers in 'accept', 'top10perc' and 'enroll' */
data mod_enroll;
set enroll_dum;
if accept > 5154 then delete;
if top10perc > 65 then delete;
if enroll > 1892 then delete;
run;

/* Further checking the cleaned box-plots for 'accept', 'top10perc', 'enoll' */
proc univariate data=mod_enroll normal plot;
var accept top10perc enroll; run;

/* Printing out the 'mod_enroll' dataset that excludes the outliers, it has now 657 observations*/
proc print data=mod_enroll; run;

/* Log-transforming 'p_undergrad' and Splitting the dataset into training and test dataset */
data enrolltrain;
set mod_enroll(firstobs=1 obs=544);
lp_undergrad=log(p_undergrad);
run;

/* Printing out the training dataset */
proc print data=enrolltrain;run;

data enrolltest;
set mod_enroll(firstobs=545 obs=657);
lp_undergrad=log(p_undergrad);
run;

/* Printing out the test dataset */
proc print data=enrolltest;run;

/* Fitting MLR to training dataset (Regression with 7 variables) */
proc reg data=enrolltrain;
model enroll= accept top10perc f_undergrad lp_undergrad room_board grad_rate P_1/ tol vif collin;
plot r.*p.;
run;

/* Running regression iteratively after dropping variables one by one */
proc reg data=enrolltrain;
model enroll= accept top10perc f_undergrad lp_undergrad room_board grad_rate/ tol vif collin;
plot r.*p.;
run;

/* Final regression model after dropping 2 variables */
proc reg data=enrolltrain;
model enroll= accept top10perc f_undergrad lp_undergrad room_board/ tol vif collin;
plot r.*p.;
run;

/* Calculating the mean squared error for test dataset */
data mod_enrolltest;
set enrolltest;
y_bar = 143.67550 + (0.17166*accept) + (0.91649*top10perc) + (0.09241*f_undergrad) + (8.06036*lp_undergrad) + (-0.03567*room_board);
predicted_err = ((enroll - y_bar)**2)/113;
run;

proc print data = mod_enrolltest;
sum predicted_err;
run;
