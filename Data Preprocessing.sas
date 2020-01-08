/* Importing the Dataset */
options validvarname=v7;
proc import datafile="/folders/myfolders/EPG194/data/loan.csv"
		out=loan dbms=csv replace;
		guessingrows=100000;
run;

/* Dropping the columns */
data work.loan;
	set work.loan;
	keep loan_amnt loan_status int_rate grade emp_length home_ownership annual_inc 
		term;
run;

/* Checking for missing values */
/* Create a format to group missing and nonmissing */
proc format;
	value $missfmt ' '='Missing' other='Not Missing';
	value missfmt  .='Missing' other='Not Missing';
run;

proc freq data=loan;
	format _CHAR_ $missfmt.;

	/* apply format for the duration of this PROC */
	tables _CHAR_ / missing missprint nocum nopercent;
	format _NUMERIC_ missfmt.;
	tables _NUMERIC_ / missing missprint nocum nopercent;
run;

data loan;
	set work.loan;
	where upcase(home_ownership) not like 'NONE'
	and upcase(home_ownership) not like 'ANY'
	and upcase(home_ownership) not like 'OTHER'
	and emp_length not like 'n/a';
run;

proc freq data=loan;
	tables emp_length grade home_ownership loan_status term;
run;


