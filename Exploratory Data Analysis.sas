/* Open the LISTING destination and assign the LISTING style to the graph */
ods listing close;
ods graphics / width=5in height=2.81in MAXOBS=2112687;
title 'Distribution for Loan Status';

proc sgplot data=loan;
	vbar loan_status / groupdisplay=cluster stat=mean dataskin=gloss;
	xaxis display=(nolabel noticks);
	yaxis grid;
run;

data loan_filter;
	set work.loan;

	if loan_status='Charged Off' or loan_status='Default' then
		loan_outcome=1;
	else if loan_status='Fully Paid' then
		loan_outcome=0;
	else
		loan_outcome=999;
	drop loan_status;
run;

proc freq data=loan_filter;
	tables loan_outcome;
run;

ods listing close;
ods graphics / width=5in height=2.81in MAXOBS=2112687;
title 'Distribution for Loan Outcome';

proc sgplot data=loan_filter;
	vbar loan_outcome / groupdisplay=cluster stat=mean dataskin=gloss;
	xaxis display=(nolabel noticks);
	yaxis grid;
run;

data loan_filter;
	set loan_filter;
	where loan_outcome=1 or loan_outcome=0;
run;

/* Close the LISTING destination and assign the LISTING style to the graph */
ods listing close;
ods graphics / width=5in height=2.81in;
title 'Boxplot for Grade';

/* Run PROC SGPLOT on data loan_filter, selecting for grade and interest rate*/
proc sgplot data=loan_filter;
	/*  generate a vertical box plot that
	 *  shows interest rate by grade */
	vbox int_rate / category=grade groupdisplay=cluster lineattrs=(pattern=solid) 
		whiskerattrs=(pattern=solid);
	xaxis display=(nolabel);
	yaxis grid;
	keylegend / location=inside position=topleft across=1;
run;

proc freq data=loan_filter order=freq;
	tables grade*loan_outcome / plots=freqplot(twoway=stacked 
		scale=grouppct)nopercent nocol norow;
run;

data training testing;
	set loan_filter nobs=nobs;

	if _n_<=.7*nobs then
		output training;
	else
		output testing;
run;

proc logistic data=loan_filter descending;
	class emp_length grade home_ownership term / param=ref;
	model loan_outcome=annual_inc emp_length grade home_ownership int_rate 
		loan_amnt term;
run;

proc logistic data=training descending;
	class emp_length grade home_ownership term / param=ref;
	model loan_outcome=annual_inc emp_length grade home_ownership int_rate 
		loan_amnt term;
	score data=testing out=mypreds;
run;

/* Confusion Matrix */
proc freq data=mypreds;
tables f_loan_outcome*I_loan_outcome;
run;

 