/* Open the LISTING destination and assign the LISTING style to the graph */
ods listing close;
ods graphics / width=5in height=2.81in MAXOBS=2260668;
title 'Distribution for Loan Outcome';

proc sgplot data=loan_std;
	vbar loan_outcome / groupdisplay=cluster stat=mean dataskin=gloss;
	xaxis display=(nolabel noticks);
	yaxis grid;
run;

/* Close the LISTING destination and assign the LISTING style to the graph */
ods listing close;
ods graphics / width=5in height=2.81in;
title 'Boxplot for Grade';

/* Run PROC SGPLOT on data loan_filter, selecting for grade and interest rate*/
proc sgplot data=loan_std;
	/*  generate a vertical box plot that
	 *  shows interest rate by grade */
	vbox int_rate / category=grade groupdisplay=cluster lineattrs=(pattern=solid) 
		whiskerattrs=(pattern=solid);
	xaxis display=(nolabel);
	yaxis grid;
	keylegend / location=inside position=topleft across=1;
run;

ods listing close;
ods graphics / width=5in height=2.81in;
title 'Boxplot for Employee Length';

/* Run PROC SGPLOT on data loan_filter, selecting for grade and interest rate*/
proc sgplot data=loan_std;
	/*  generate a vertical box plot that
	 *  shows interest rate by grade */
	vbox int_rate / category=emp_length groupdisplay=cluster 
		lineattrs=(pattern=solid) whiskerattrs=(pattern=solid);
	xaxis display=(nolabel);
	yaxis grid;
	keylegend / location=inside position=topleft across=1;
run;

ods listing close;
ods graphics / width=5in height=2.81in;
title 'Boxplot for Home Ownership';

/* Run PROC SGPLOT on data loan_filter, selecting for grade and interest rate*/
proc sgplot data=loan_std;
	/*  generate a vertical box plot that
	 *  shows interest rate by grade */
	vbox int_rate / category=home_ownership groupdisplay=cluster 
		lineattrs=(pattern=solid) whiskerattrs=(pattern=solid);
	xaxis display=(nolabel);
	yaxis grid;
	keylegend / location=inside position=topleft across=1;
run;

ods listing close;
ods graphics / width=5in height=2.81in;
title 'Boxplot for Term';

/* Run PROC SGPLOT on data loan_filter, selecting for grade and interest rate*/
proc sgplot data=loan_std;
	/*  generate a vertical box plot that
	 *  shows interest rate by grade */
	vbox int_rate / category=term groupdisplay=cluster lineattrs=(pattern=solid) 
		whiskerattrs=(pattern=solid);
	xaxis display=(nolabel);
	yaxis grid;
	keylegend / location=inside position=topleft across=1;
run;
