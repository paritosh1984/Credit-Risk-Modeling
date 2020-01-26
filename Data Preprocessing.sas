/* Creating a Library */

libname mylib '/home/paritosh260';

/* Importing the Dataset */
options validvarname=v7;

proc import datafile="/home/paritosh260/MyCreditRiskData/loan_modified.csv" 
		out=loan_mod dbms=csv replace;
		getnames=yes;
		datarow=2;
	guessingrows=150000;
run;

/* Dropping the columns */
data work.loan;
	set work.loan_mod;
	drop VAR1 out_prncp_inv funded_amnt funded_amnt_inv total_pymnt_inv 
		total_rec_int total_rec_late_fee total_rec_prncp inq_last_6mths open_acc 
		last_pymnt_amnt open_il_12m open_rv_12m mths_since_rcnt_il avg_cur_bal 
		mo_sin_old_il_acct mo_sin_old_rev_tl_op mo_sin_rcnt_rev_tl_op mo_sin_rcnt_tl 
		mths_since_recent_bc disbursement_method debt_settlement_flag hardship_flag 
		num_tl_30dpd num_rev_tl_bal_gt_0 num_op_rev_tl num_bc_sats num_actv_bc_tl 
		num_actv_rev_tl;
run;

/* Converting character columns to numeric */
data work.loan;
	set work.loan;
	util_all=input(all_util, 8.);
	open_to_buy_bc=input(bc_open_to_buy, 8.);
	util_bc=input(bc_util, 8.);
	dti_ratio=input(dti, 8.);
	util_il=input(il_util, 8.);
	tl_120dpd_2m_num=input(num_tl_120dpd_2m, 8.);
	pct_bc_gt_75=input(percent_bc_gt_75, 8.);
	util_revol=input(revol_util, 8.);
	months_since_last_delinq=input(mths_since_last_delinq, 8.);
	months_since_last_major_derog=input(mths_since_last_major_derog, 8.);
	months_since_last_record=input(mths_since_last_record, 8.);
	months_since_recent_bc_dlq=input(mths_since_recent_bc_dlq, 8.);
	months_since_recent_inq=input(mths_since_recent_inq, 8.);
	months_since_recent_revol_delinq=input(mths_since_recent_revol_delinq, 8.);
	drop all_util bc_open_to_buy bc_util dti il_util num_tl_120dpd_2m 
		percent_bc_gt_75 revol_util mths_since_last_delinq 
		mths_since_last_major_derog mths_since_last_record mths_since_recent_bc_dlq 
		mths_since_recent_inq mths_since_recent_revol_delinq;
run;

/* Feature Engineering */
data work.loan;
	set work.loan;
	months=months_since_last_delinq +  
months_since_last_major_derog +  months_since_last_record +  
months_since_recent_bc_dlq +  months_since_recent_inq +  months_since_recent_revol_delinq;
	recov=collection_recovery_fee + recoveries;
	drop months_since_last_delinq months_since_last_major_derog 
		months_since_last_record months_since_recent_bc_dlq months_since_recent_inq 
		months_since_recent_revol_delinq collection_recovery_fee recoveries;
run;

/* Standardizing the numeric variables using 'range' method */
proc stdize data=loan out=loan_std method=range;
	var acc_now_delinq acc_open_past_24mths annual_inc chargeoff_within_12_mths 
		collections_12_mths_ex_med delinq_2yrs delinq_amnt inq_fi inq_last_12m 
		installment int_rate loan_amnt months mort_acc num_accts_ever_120_pd 
		num_bc_tl num_il_tl num_rev_accts num_sats num_tl_90g_dpd_24m 
		num_tl_op_past_12m open_acc_6m open_act_il open_il_24m open_rv_24m out_prncp 
		pct_tl_nvr_dlq pub_rec pub_rec_bankruptcies recov revol_bal tax_liens 
		tot_coll_amt tot_cur_bal tot_hi_cred_lim total_acc total_bal_ex_mort 
		total_bal_il total_bc_limit total_cu_tl total_il_high_credit_limit 
		total_pymnt total_rev_hi_lim util_all open_to_buy_bc util_bc dti_ratio 
		util_il tl_120dpd_2m_num pct_bc_gt_75 util_revol max_bal_bc;
run;

/* Checking for missing values */
/* Create a format to group missing and nonmissing */
proc format;
	value $missfmt ' '='Missing' 'NA'='Missing' other='Not Missing';
	value missfmt  .='Missing' other='Not Missing';
run;

proc freq data=loan_std;
	format _CHAR_ $missfmt.;

	/* apply format for the duration of this PROC */
	tables _CHAR_ / missing missprint nocum nopercent;
	format _NUMERIC_ missfmt.;
	tables _NUMERIC_ / missing missprint nocum nopercent;
run;

proc contents data=work.loan_std;
run;

/* Converting the target variable */
data loan_std;
	set work.loan_std;

	if loan_status='Charged Off' or loan_status='Default' then
		loan_outcome=1;
	else if loan_status='Fully Paid' then
		loan_outcome=0;
	else
		loan_outcome=999;
	drop loan_status;
run;

data loan_std;
	set loan_std;
	where loan_outcome=1 or loan_outcome=0;
run;

/* Dropping home_ownership 'ANY','OTHER' and 'NONE' */
data loan_std;
	set work.loan_std;
	where upcase(home_ownership) not like 'NONE' and upcase(home_ownership) not 
		like 'ANY' and upcase(home_ownership) not like 'OTHER' and emp_length not 
		like 'n/a';
run;

/* Checking Multicollinearity using 'proc reg' */
proc reg data=loan_std;
	model loan_outcome=acc_now_delinq acc_open_past_24mths annual_inc 
		chargeoff_within_12_mths collections_12_mths_ex_med delinq_2yrs delinq_amnt 
		dti_ratio inq_fi inq_last_12m installment int_rate loan_amnt max_bal_bc 
		months mort_acc num_accts_ever_120_pd num_bc_tl num_il_tl num_rev_accts 
		num_sats num_tl_90g_dpd_24m num_tl_op_past_12m open_acc_6m open_act_il 
		open_il_24m open_rv_24m open_to_buy_bc out_prncp pct_bc_gt_75 pct_tl_nvr_dlq 
		pub_rec pub_rec_bankruptcies recov revol_bal tax_liens tl_120dpd_2m_num 
		tot_coll_amt tot_cur_bal tot_hi_cred_lim total_acc total_bal_ex_mort 
		total_bal_il total_bc_limit total_cu_tl total_il_high_credit_limit 
		total_pymnt total_rev_hi_lim util_all util_bc util_il util_revol/vif;
	run;

	/* Dropping the variables with Variable Inflation Factor(VIF) more than 10 */
data work.loan_std;
	set work.loan_std;
	drop acc_open_past_24mths installment loan_amnt num_il_tl num_rev_accts 
		open_il_24m open_rv_24m open_to_buy_bc revol_bal tot_cur_bal tot_hi_cred_lim 
		total_acc total_bal_ex_mort total_bal_il total_bc_limit 
		total_il_high_credit_limit total_rev_hi_lim;
run;

/* Frequency distribution for character variables */
proc freq data=work.loan_std;
	tables loan_outcome emp_length grade home_ownership term;
run;