use "G:\OV20_0544\EXPORT\DATASETS\COVID DATA\COVQ_LIFELINES_LONG_MERGED_310522.dta", clear

sysdir set PLUS "I:\Lifelines\Programs\STATA-packages-installed"

*Mark individuals with more than one observation (those represented in the longitudinal model (n=64,630))
xtreg BMIchange c.Age if count>1, fe
predict x if e(sample)==1
gen Sample=1 if x!=.
replace Sample=0 if Sample==.
egen Sample2=max(Sample), by(PSEUDOIDEXT) 


****TABLE 1
tab Employment2 if Sample2==1 & ID==1, m 

tab Critical_cov if Sample2==1 & ID==1, m
tab Laidoff_cov if Sample2==1 & ID==1, m
tab Workhome_cov if Sample2==1 & ID==1, m
tab ZZP_cov if Sample2==1 & ID==1, m
tab Temp_cov if Sample2==1 & ID==1, m

tab Chronic_cov if Sample2==1 & ID==1, m
tab Isolation_cov if Sample2==1 & ID==1, m
tab MD_cov if Sample2==1 & ID==1, m
tab Anx_cov if Sample2==1 & ID==1, m

tab Household2 if Sample2==1 & ID==1, m

sum Age if Sample2==1 & ID==1, detail
tab Age_cat2 if Sample2==1 & ID==1
tab Gender if Sample2==1 & ID==1, m
tab EA if Sample2==1 & ID==1, m


***************************************
** FIGURE 1 
*Mixed model
mixed BMIchange c.Days##c.Days##c.Days##c.Days##c.Days##c.Days if count>1 || PSEUDOIDEXT:Days, vce(cluster PSEUDOIDEXT) cov(unstr) 
est save MixedModel
margins, at (Days=(15(7)500)) post
est save mmix
marginsplot, recast(line) recastci(rarea)  ciopts(lpattern(dash) lcolor(ltblue)) ytitle("Changes in BMI") xtitle("Days since 1st lockdown") graphregion(color(white)) bgcolor(white) name("Gmix", replace)


** FIGURE 2 - Group-based Trajectory models

*Dataset in wide format:
use "G:\OV20_0544\EXPORT\DATASETS\COVID DATA\COVID_WIDE_Trajectory_Analysis_280522.dta", clear

traj, var(BMIchange*) indep(Days*) model(cnorm) order(3 3 3) min(-2.5) max(2.5) risk(BMI_first1)  
trajplot


**TABLE 2
*Home-made estimates (Andrew P. Wheeler)
program table_Traj3 

	preserve
	*Average posterior probability
	gen Mp = 0
	foreach i of varlist _traj_ProbG* {
		replace Mp = `i' if `i' > Mp
	}
	sort _traj_Group
	*Odds of correct classification
	by _traj_Group: gen countG = _N
	by _traj_Group: egen groupAPP = mean(Mp)
	by _traj_Group: gen counter = _n
	gen n2 = groupAPP/(1 - groupAPP)
	gen p2 = countG/_N
	gen d2 = p/(1-p)
	gen occ2 = n/d
	*Estimated proportion for each group
	scalar c = 0
	gen TotProb = 0 
	foreach i of varlis _traj_ProbG* {
		scalar c = c + 1 
		quietly summarize `i' 
		replace TotProb = r(sum)/_N if _traj_Group == c
		}
		gen d_pp=TotProb/(1-TotProb)
		gen occ_pp=n/d_pp
		
*This displays the group number, the count per group, the average posterior probability for each group,
*the odds of correct classification (based on the max post prob group assignment - occ)
	*and, based on the weighted post. prob: occ_pp and the observed probability of groups (p) versus the probability based on the posterior probabilities (TotProb)
	
	list _traj_Group countG groupAPP occ2 occ_pp p2 TotProb if counter==1
	restore
	end 


table_Traj3


*(I saved the output variable with three categories to be used as outcome in the multinomial models...it is already merged in the main dataset) 
rename _traj_Group Traj_BMI3
label def Traj_BMI3 1"BMI decrease" 2"Stable BMI" 3"BMI increase", modify
label val Traj_BMI3 Traj_BMI3

keep PSEUDOIDEXT Traj_BMI3
gen Wave==1 

save "G:\OV20_0544\EXPORT\DATASETS\COVID DATA\Traj_BMI3.dta"


***********************************************

**TABLE 3 & FIGURE 3
use "G:\OV20_0544\EXPORT\DATASETS\COVID DATA\COVQ_LIFELINES_LONG_MERGED_310522.dta", clear
sysdir set PLUS "I:\Lifelines\Programs\STATA-packages-installed"

*Categorical BMI at baseline
gen BMIfirst_cat = BMI_first
recode BMIfirst_cat (min/24.9999=1) (25/29.9999=2) (30/max=3) 
label def BMIfirst_cat 1"Healthy" 2"Overweight" 3"Obesity", modify
label val BMIfirst_cat BMIfirst_cat 

*Lives with children <12 (dummy)
gen Children=1 if (ID==1 & household_adu_q_1_a!=0 & household_adu_q_1_a!=.)  
replace Children=0 if (ID==1 & Children==.)
replace Children=. if (ID==1 & Household2==.)
bysort PSEUDOIDEXT (Children) : replace Children = Children[1] if missing(Children)



bysort PSEUDOIDEXT: replace Traj_BMI3c = Traj_BMI3c[_n-1] if missing(Traj_BMI3c)

label def Traj_BMI3c 1"BMI Decrease" 2"Stable BMI" 3"BMI Increase", modify
label val Traj_BMI3c Traj_BMI3c



mlogit Traj_BMI3c i.Employment2 i.Critical_cov i.Laidoff_cov i.Workhome_cov i.ZZP_cov i.Temp_cov i.Isolation_cov i.MD_cov i.Anx_cov ib2.Household2 i.Gender ib3.Age_cat2 ib3.EA i.Chronic_cov i.BMIfirst_cat if ID==1 & count>1, base(2)rrr 
est store M3cat
margins, dydx(*) predict(outcome(1) xb) post
est store m3cat1
est save m3cat1
est restore M3cat
margins, dydx(*) predict(outcome(3) xb) post
est store m3cat3
est save m3cat3

coefplot (m3cat3, symbol(T)), drop(_cons 5.Employment2 2.EA 1.BMIfirst_cat 2.BMIfirst_cat 3.BMIfirst_cat) xline(1) ylab(1"Criticaljob" 2"Laid-off" 3"Work from home" 4"Freelancer" 5"Temporary job" 6"Loneliness" /// 
7"Depression" 8"Anxiety" 9"Retired" 10"Unemployed" 11"Disabled" 12"Lives alone" 13"Family & children" 14"Female" 15"Age40" 16"Age 41-50" 17"Age 61-70" 18"Age 70+" 19"Lower SES" 20"Chronic disease") ///
graphregion(color(white)) bgcolor(white) eform title("BMI increase") name("BMI3inc", replace)

coefplot (m3cat1, symbol(D)), drop(_cons 5.Employment2 2.EA 1.BMIfirst_cat 2.BMIfirst_cat 3.BMIfirst_cat) xline(1) ylab(1"Criticaljob" 2"Laid-off" 3"Work from home" 4"Freelancer" 5"Temporary job" 6"Loneliness" /// 
7"Depression" 8"Anxiety" 9"Retired" 10"Unemployed" 11"Disabled" 12"Lives alone" 13"Family & children" 14"Female" 15"Age40" 16"Age 41-50" 17"Age 61-70" 18"Age 70+" 19"Lower SES" 20"Chronic disease") ///
graphregion(color(white)) bgcolor(white) eform title("BMI decrease") name("BMI3dec")

graph combine BMI3inc BMI3dec 


**FIGURE 4: CUMULATIVE EFFECTS 
 *Working sphere
gen Disrupt_Work = Critical_cov + Laidoff_cov + Workhome_cov + ZZP_cov + Temp_cov
recode Disrupt_Work 4=3 5=3 6=3
 
gen Disrupt_Health = Isolation_cov  + MD_cov  + Anx_cov

*Figure 4A:
mlogit Traj_BMI3c i.Disrupt_Work i.Disrupt_Health i.Employment2 ib2.Household2 i.Gender ib3.Age_cat2 ib3.EA i.Chronic_cov i.BMIfirst_cat if ID==1 & count>1, base(2)rrr 
est store Mdisrupt

est restore Mdisrupt
margins, dydx(*) predict(outcome(3) xb) post
est save mdisrupt3
est store mdisrupt3

est restore Mdisrupt
margins, dydx(*) predict(outcome(1) xb) post
est save mdisrupt1, replace
est store mdisrupt1

coefplot (mdisrupt3,symbol(T)col(black)) (mdisrupt1, symbol(D)col(gray)), drop(_cons 1.Employment2 2.Employment2 3.Employment2 4.Employment2 5.Employment2 1.EA 2.EA 3.EA 1.BMIfirst_cat 2.BMIfirst_cat 3.BMIfirst_cat  ///
0.Household2 1.Household2 2.Household2 0.Gender 1.Gender 1.Age_cat2 2.Age_cat2 3.Age_cat2 4.Age_cat2 5.Age_cat2 1.Chronic_cov) ///
title("Work & Health domains") ylab(1"Workrelatedevents" 2"2 events" 3"3+ events" 4"Health-related events (1)" 5"2 events" 6"3+ events" ) ///
graphregion(color(white)) bgcolor(white) eform plotlabels("BMI increase" "BMI decrease") name(Workhealthacc, replace)


*Figure 4B:
gen Events_All = Critical_cov + Laidoff_cov + Workhome_cov + ZZP_cov + Temp_cov + Isolation_cov  + MD_cov  + Anx_cov
recode Events_All 7=5 6=5

mlogit Traj_BMI3c i.Events_All i.Employment2 ib2.Household2 i.Gender ib3.Age_cat2 ib3.EA i.Chronic_cov i.BMIfirst_cat if ID==1 & count>1, base(2)rrr 
est store Mevents2

est restore Mevents2
margins, dydx(*) predict(outcome(3) xb) post
est save mevents32, replace
est store mevents32

est restore Mevents2
margins, dydx(*) predict(outcome(1) xb) post
est save mevents12, replace
est store mevents12

coefplot (mevents32, col(black)symbol(T)) (mevents12, symbol(D) col(gray)), drop(_cons 1.Employment2 2.Employment2 3.Employment2 4.Employment2 5.Employment2 1.EA 2.EA 3.EA 1.BMIfirst_cat 2.BMIfirst_cat 3.BMIfirst_cat  ///
0.Household2 1.Household2 2.Household2 0.Gender 1.Gender 1.Age_cat2 2.Age_cat2 3.Age_cat2 4.Age_cat2 5.Age_cat2 1.Chronic_cov) ylab(1"Event" 2"2 events" 3"3 events" 4"4 events" 5"5 events") ///
bgcolor(white) title("All events") graphregion(color(white)) eform plotlabels("BMI increase" "BMI decrease") name(Accum_all, replace)

