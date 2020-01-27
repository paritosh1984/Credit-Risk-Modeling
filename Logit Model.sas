
/* Split data into two datasets : 70%- training 30%- testing */
proc surveyselect data=loan_std out=split seed=1234 samprate=.8 outall;
run;

data training_set testing_set;
	set split;

	if selected=1 then
		output training_set;
	else
		output testing_set;
run;

/* Logistic Regression Model*/
ods graphics on;

proc logistic data=training_set descending;
	class emp_length grade home_ownership term / param=ref;
	Model loan_outcome=acc_now_delinq annual_inc chargeoff_within_12_mths 
		collections_12_mths_ex_med delinq_2yrs delinq_amnt dti_ratio inq_fi 
		inq_last_12m int_rate max_bal_bc months mort_acc num_accts_ever_120_pd 
		num_bc_tl num_sats num_tl_90g_dpd_24m num_tl_op_past_12m open_acc_6m 
		open_act_il out_prncp pct_bc_gt_75 pct_tl_nvr_dlq pub_rec 
		pub_rec_bankruptcies recov tax_liens tl_120dpd_2m_num tot_coll_amt 
		total_cu_tl total_pymnt util_all util_bc util_il util_revol/ 
		selection=stepwise slstay=0.15 slentry=0.15 stb;
	score data=training_set out=Logit_Training fitstat outroc=troc;
	score data=testing_set out=Logit_Test fitstat outroc=vroc;
run;

/* KS Statistics*/
proc npar1way data=Logit_Test edf;
class emp_length;
var p_1 p_0;
run;
