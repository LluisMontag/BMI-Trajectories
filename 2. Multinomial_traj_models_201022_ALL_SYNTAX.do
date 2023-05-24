use "G:\OV20_0544\COVID Reduced Datasets Correct 120521\STATA\Reduced Datasets\Paper 5\COVQ_LIFELINES_LONG_MERGED_310522.dta", clear
sysdir set PLUS "I:\Lifelines\Programs\STATA-packages-installed"

*******
**All necessary steps to reproduce paper #6 are in syntax #1 (Syntax_Paper6_BMI_140223cor). These are just some extra calculations, sensitivity analyses, etc. 
**********************************************************


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


mlogit Traj_BMI3c i.Critical_cov i.Laidoff_cov i.Workhome_cov i.ZZP_cov i.Temp_cov i.Isolation_cov i.MD_cov i.Anx_cov i.Employment2 ib2.Household2 i.Gender ib3.Age_cat2 ib3.EA i.Chronic_cov i.BMIfirst_cat if ID==1 & count>1, base(2)rrr 
est store M3cat
margins, dydx(*) predict(outcome(1) xb) post
est store m3cat1
est save m3cat1
est restore M3cat
margins, dydx(*) predict(outcome(3) xb) post
est store m3cat3
est save m3cat3

coefplot (m3cat3, symbol(S) col(black) offset(0.1)) (m3cat1, symbol(T) offset(-0.3)), drop(_cons 5.Employment2 2.EA 1.BMIfirst_cat 2.BMIfirst_cat 3.BMIfirst_cat) xline(1) ///  
ylab(1"Criticaljob" 2"Laid-off" 3"Work from home" 4"Freelancer" 5"Temporary job" 6"Loneliness" 7"Depression" 8"Anxiety" 9"Retired" 10"Unemployed" 11"Disabled" ///
12"Lives alone" 13"Family & children" 14"Female" 15"Age40" 16"Age 41-50" 17"Age 61-70" 18"Age 70+" 19"Lower SES" 20"Chronic disease") ///
graphregion(color(white)) bgcolor(white) eform plotlabels("BMI increase" "BMI decrease") 


coefplot (m3cat3, symbol(T)), drop(_cons 5.Employment2 2.EA 1.BMIfirst_cat 2.BMIfirst_cat 3.BMIfirst_cat) xline(1) ylab(1"Criticaljob" 2"Laid-off" 3"Work from home" 4"Freelancer" 5"Temporary job" 6"Loneliness" /// 
7"Depression" 8"Anxiety" 9"Retired" 10"Unemployed" 11"Disabled" 12"Lives alone" 13"Family & children" 14"Female" 15"Age40" 16"Age 41-50" 17"Age 61-70" 18"Age 70+" 19"Lower SES" 20"Chronic disease") ///
graphregion(color(white)) bgcolor(white) eform title("BMI increase") name("BMI3inc", replace)

coefplot (m3cat1, symbol(D)), drop(_cons 5.Employment2 2.EA 1.BMIfirst_cat 2.BMIfirst_cat 3.BMIfirst_cat) xline(1) ylab(1"Criticaljob" 2"Laid-off" 3"Work from home" 4"Freelancer" 5"Temporary job" 6"Loneliness" /// 
7"Depression" 8"Anxiety" 9"Retired" 10"Unemployed" 11"Disabled" 12"Lives alone" 13"Family & children" 14"Female" 15"Age40" 16"Age 41-50" 17"Age 61-70" 18"Age 70+" 19"Lower SES" 20"Chronic disease") ///
graphregion(color(white)) bgcolor(white) eform title("BMI decrease") name("BMI3dec")

graph combine BMI3inc BMI3dec 

****************
 *Stratified by Gender  
mlogit Traj_BMI3c i.Critical_cov i.Laidoff_cov i.Workhome_cov i.ZZP_cov i.Temp_cov i.Isolation_cov i.MD_cov i.Anx_cov i.Employment2 ib2.Household2 ib3.Age_cat2 ib3.EA i.Chronic_cov i.BMIfirst_cat if ID==1 & count>1 & Gender==0 , base(2)rrr 
est store Men3cat

mlogit Traj_BMI3c i.Critical_cov i.Laidoff_cov i.Workhome_cov i.ZZP_cov i.Temp_cov i.Isolation_cov i.MD_cov i.Anx_cov i.Employment2 ib2.Household2 ib3.Age_cat2 ib3.EA i.Chronic_cov i.BMIfirst_cat if ID==1 & count>1 & Gender==1 , base(2)rrr 
est store Women3cat


est restore Men3cat
margins, dydx(*) predict(outcome(1) xb) post
est save men1cat, replace
est restore Women3cat
margins, dydx(*) predict(outcome(1) xb) post
est save women1cat, replace
est restore Men3cat
margins, dydx(*) predict(outcome(3) xb) post
est save men3cat, replace
est restore Women3cat
margins, dydx(*) predict(outcome(3) xb) post
est save women3cat, replace

est use men1cat 
est store men1cat
est use women1cat
est store women1cat
est use men3cat 
est store men3cat
est use women3cat
est store women3cat


coefplot men3cat women3cat, drop(_cons 5.Employment2 2.EA 1.BMIfirst_cat 2.BMIfirst_cat 3.BMIfirst_cat) xline(1) ylab(1"Essentialjob" 2"Laid-off" 3"Work from home" 4"Freelancer" 5"Temporary job" 6"Loneliness" /// 
7"Depression" 8"Anxiety" 9"Retired" 10"Unemployed" 11"Disabled" 12"Lives alone" 13"Family & children" 14"Age <40" 15"Age 41-50" 16"Age 61-70" 17"Age 70+" 18"Lower SES" 19"Chronic disease") ///
graphregion(color(white)) bgcolor(white) eform title("BMI increase") plotlabels("Men" "Women") name("BMI3inc_gender", replace)

coefplot men1cat women1cat, drop(_cons 5.Employment2 2.EA 1.BMIfirst_cat 2.BMIfirst_cat 3.BMIfirst_cat) xline(1) ylab(1"Essentialjob" 2"Laid-off" 3"Work from home" 4"Freelancer" 5"Temporary job" 6"Loneliness" /// 
7"Depression" 8"Anxiety" 9"Retired" 10"Unemployed" 11"Disabled" 12"Lives alone" 13"Family & children" 14"Age <40" 15"Age 41-50" 16"Age 61-70" 17"Age 70+" 18"Lower SES" 19"Chronic disease") ///
graphregion(color(white)) bgcolor(white) eform title("BMI decrease") plotlabels("Men" "Women") name("BMI3dec_gender", replace)

graph combine BMI3inc_gender BMI3dec_gender

*Stratified by BMI at baseline 

*Normal weight: same story
mlogit Traj_BMI3c i.Critical_cov i.Laidoff_cov i.Workhome_cov i.ZZP_cov i.Temp_cov i.Isolation_cov i.MD_cov i.Anx_cov i.Employment2 ib2.Household2 i.Gender ib3.Age_cat2 ib3.EA i.Chronic_cov if ID==1 & count>1 & BMIfirst_cat==1 , base(2) rrr
est store M3normal

*Overweight: same for increase, differences with decrease
mlogit Traj_BMI3c i.Critical_cov i.Laidoff_cov i.Workhome_cov i.ZZP_cov i.Temp_cov i.Isolation_cov i.MD_cov i.Anx_cov i.Employment2 ib2.Household2 i.Gender ib3.Age_cat2 ib3.EA i.Chronic_cov if ID==1 & count>1 & BMIfirst_cat==2 , base(2) rrr
est store M3over

*Obesity: same for increase, differences for decrease
mlogit Traj_BMI3c i.Critical_cov i.Laidoff_cov i.Workhome_cov i.ZZP_cov i.Temp_cov i.Isolation_cov i.MD_cov i.Anx_cov i.Employment2 ib2.Household2 i.Gender ib3.Age_cat2 ib3.EA i.Chronic_cov if ID==1 & count>1 & BMIfirst_cat==3 , base(2) rrr
est store M3obese

est restore M3normal
margins, dydx(*) predict(outcome(1) xb) post
est store normal1
est save normal1, replace

est restore M3over
margins, dydx(*) predict(outcome(1) xb) post
est save over1, replace
est store over1

est restore M3obese
margins, dydx(*) predict(outcome(1) xb) post
est store obese1
est save obese1, replace

est restore M3normal
margins, dydx(*) predict(outcome(3) xb) post
est store normal3
est save normal3, replace

est restore M3over
margins, dydx(*) predict(outcome(3) xb) post
est save over3, replace
est store over3

est restore M3obese
margins, dydx(*) predict(outcome(3) xb) post
est store obese3
est save obese3, replace

coefplot normal1 over1 obese1, drop(_cons 5.Employment2 2.EA) xline(1) title("BMI decrease") ylab(1"Criticaljob" 2"Laid-off" 3"Work from home" 4"Freelancer" 5"Temporary job" 6"Loneliness" /// 
7"Depression" 8"Anxiety" 9"Retired" 10"Unemployed" 11"Disabled" 12"Lives alone" 13"Family & children" 14"Female" 15"Age40" 16"Age 41-50" 17"Age 61-70" 18"Age 70+" 19"Lower SES" 20"Chronic disease")  plotlabels("Normal" "Overweight" "Obesity") graphregion(color(white)) bgcolor(white) eform name(Decrease3, replace)

coefplot normal3 over3 obese3, drop(_cons 5.Employment2 2.EA) xline(1) title("BMI Increase") ylab(1"Criticaljob" 2"Laid-off" 3"Work from home" 4"Freelancer" 5"Temporary job" 6"Loneliness" /// 
7"Depression" 8"Anxiety" 9"Retired" 10"Unemployed" 11"Disabled" 12"Lives alone" 13"Family & children" 14"Female" 15"Age40" 16"Age 41-50" 17"Age 61-70" 18"Age 70+" 19"Lower SES" 20"Chronic disease")  plotlabels("Normal" "Overweight" "Obesity") graphregion(color(white)) bgcolor(white) eform name(Increase3, replace)

graph combine Increase3 Decrease3 


*****************5 TRAJECTORIES
merge 1:1 PSEUDOIDEXT ID using "G:\OV20_0544\COVID Reduced Datasets Correct 120521\STATA\Reduced Datasets\Paper 5\Traj5c_070722.dta", nogenerate

mlogit Traj_BMI5c i.Critical_cov i.Laidoff_cov i.Workhome_cov i.ZZP_cov i.Temp_cov i.Isolation_cov i.MD_cov i.Anx_cov i.Employment2 ib2.Household2 i.Gender ib3.Age_cat2 ib3.EA i.Chronic_cov i.BMIfirst_cat if ID==1 & count>1, base(3)rrr 
est store M5c

margins, dydx(*) predict(outcome(1) xb) post
est store m5cat1
est save m5cat1, replace
est restore M5c 
margins, dydx(*) predict(outcome(5) xb) post
est store m5cat5
est save m5cat5, replace

coefplot m5cat5, drop(_cons 5.Employment2 2.EA 1.BMIfirst_cat 2.BMIfirst_cat 3.BMIfirst_cat) xline(1) ylab(1"Criticaljob" 2"Laid-off" 3"Work from home" 4"Freelancer" 5"Temporary job" 6"Loneliness" /// 
7"Depression" 8"Anxiety" 9"Retired" 10"Unemployed" 11"Disabled" 12"Lives alone" 13"Family & children" 14"Female" 15"Age40" 16"Age 41-50" 17"Age 61-70" 18"Age 70+" 19"Lower SES" 20"Chronic disease") ///
graphregion(color(white)) bgcolor(white) eform title("Strong BMI increase (5 cat)") name("BMI5inc", replace)

coefplot m5cat1, drop(_cons 5.Employment2 2.EA 1.BMIfirst_cat 2.BMIfirst_cat 3.BMIfirst_cat) xline(1) ylab(1"Criticaljob" 2"Laid-off" 3"Work from home" 4"Freelancer" 5"Temporary job" 6"Loneliness" /// 
7"Depression" 8"Anxiety" 9"Retired" 10"Unemployed" 11"Disabled" 12"Lives alone" 13"Family & children" 14"Female" 15"Age40" 16"Age 41-50" 17"Age 61-70" 18"Age 70+" 19"Lower SES" 20"Chronic disease") ///
graphregion(color(white)) bgcolor(white) eform title("(Strong)BMI decrease") name("BMI5dec")

graph combine BMI3inc BMI5inc 

 *Stratified by Gender 
mlogit Traj_BMI5c ib3.Age_cat2 ib3.EA i.Employment2 ib2.Household2 i.Chronic_cov i.Critical_cov i.Laidoff_cov i.Workhome_cov i.ZZP_cov i.Temp_cov i.Isolation_cov i.MD_cov i.Anx_cov c.BMI_first if ID==1 & count>1 & Gender==0 , base(3) rrr
est store Men5c
mlogit Traj_BMI5c  ib3.Age_cat2 ib3.EA i.Employment2 ib2.Household2 i.Chronic_cov i.Critical_cov i.Laidoff_cov i.Workhome_cov i.ZZP_cov i.Temp_cov i.Isolation_cov i.MD_cov i.Anx_cov c.BMI_first if ID==1 & count>1 & Gender==1 , base(3) rrr
est store Women5c

est restore Men5c
margins, dydx(*) predict(outcome(1) xb) post
est save men51, replace
est restore Women5c
margins, dydx(*) predict(outcome(1) xb) post
est save women51, replace
coefplot men51 women51, drop(_cons 5.Employment2 2.EA) xline(1) title("Strong BMI decrease") ylab(1"Age40" 2"Age 41-50" 3"Age 61-70" 4"Age 70+" 5"Lower SES" 6"Retired" 7"Unemployed" 8"Disabled" 9"Lives alone" 10"Family & children" 11"Chronic disease" /// 
12"Critical Job" 13"Laid-off" 14"Work from home" 15"Freelancer" 16"Temporary job" 17"Loneliness" 18"Depression" 19"Anxiety Disorder" 20"BMI at baseline") plotlabels("Men" "Women") graphregion(color(white)) bgcolor(white) eform name(Strong_Decrease, replace)

est restore Men5c
margins, dydx(*) predict(outcome(5) xb) post
est save men55, replace
est restore Women5c
margins, dydx(*) predict(outcome(5) xb) post
est save women55, replace
coefplot men55 women55, drop(_cons 5.Employment2 2.EA) xline(1) title("Strong BMI increase") ylab(1"Age40" 2"Age 41-50" 3"Age 61-70" 4"Age 70+" 5"Lower SES" 6"Retired" 7"Unemployed" 8"Disabled" 9"Lives alone" 10"Family & children" 11"Chronic disease" /// 
12"Critical Job" 13"Laid-off" 14"Work from home" 15"Freelancer" 16"Temporary job" 17"Loneliness" 18"Depression" 19"Anxiety Disorder" 20"BMI at baseline") plotlabels("Men" "Women") graphregion(color(white)) bgcolor(white) eform name(Strong_Increase5, replace)
graph combine Strong_Increase Strong_Decrease   

est use men51
est store men51
est use women51
est store women51

est use men55
est store men55
est use women55
est store women55

graph combine Increase Strong_Increase5

*Stratified by BMI at baseline (similar results to the 3-group category...stick to that one, as it is more parsimonious!)
*Normal weight: same story
mlogit Traj_BMI5c i.Gender ib3.Age_cat2 ib3.EA i.Employment2 ib2.Household2 i.Chronic_cov i.Critical_cov i.Laidoff_cov i.Workhome_cov i.ZZP_cov i.Temp_cov i.Isolation_cov i.MD_cov i.Anx_cov if ID==1 & count>1 & BMIfirst_cat==1 , base(3) rrr
est store M5normal

*Overweight: same for increase, differences with decrease
mlogit Traj_BMI5c i.Gender ib3.Age_cat2 ib3.EA i.Employment2 ib2.Household2 i.Chronic_cov i.Critical_cov i.Laidoff_cov i.Workhome_cov i.ZZP_cov i.Temp_cov i.Isolation_cov i.MD_cov i.Anx_cov if ID==1 & count>1 & BMIfirst_cat==2 , base(3) rrr
est store M5over

*Obesity: same for increase, differences for decrease
mlogit Traj_BMI5c i.Gender ib3.Age_cat2 ib3.EA i.Employment2 ib2.Household2 i.Chronic_cov i.Critical_cov i.Laidoff_cov i.Workhome_cov i.ZZP_cov i.Temp_cov i.Isolation_cov i.MD_cov i.Anx_cov if ID==1 & count>1 & BMIfirst_cat==3 , base(3) rrr
est store M5obese

est restore M5normal
margins, dydx(*) predict(outcome(1) xb) post
est store normal51
est save normal51

est restore M5over
margins, dydx(*) predict(outcome(1) xb) post
est save over51
est store over51

est restore M5obese
margins, dydx(*) predict(outcome(1) xb) post
est store obese51
est save obese51

est restore M5normal
margins, dydx(*) predict(outcome(5) xb) post
est store normal55
est save normal55

est restore M5over
margins, dydx(*) predict(outcome(5) xb) post
est save over55
est store over55

est restore M5obese
margins, dydx(*) predict(outcome(5) xb) post
est store obese55
est save obese55

coefplot normal51 over51 obese51, drop(_cons 5.Employment2 2.EA) xline(1) title("BMI decrease") ylab(1"Women" 2"Age40" 3"Age 41-50" 4"Age 61-70" 5"Age 70+" 6"Lower SES" 7"Retired" 8"Unemployed" 9"Disabled" 10"Lives alone" 11"Family & children" 12"Chronic disease" /// 
13"Critical Job" 14"Laid-off" 15"Work from home" 16"Freelancer" 17"Temporary job" 18"Loneliness" 19"Depression" 20"Anxiety Disorder") plotlabels("Normal" "Overweight" "Obesity") graphregion(color(white)) bgcolor(white) eform name(Decrease5, replace)

coefplot normal55 over55 obese55, drop(_cons 5.Employment2 2.EA) xline(1) title("BMI Increase") ylab(1"Women" 2"Age40" 3"Age 41-50" 4"Age 61-70" 5"Age 70+" 6"Lower SES" 7"Retired" 8"Unemployed" 9"Disabled" 10"Lives alone" 11"Family & children" 12"Chronic disease" /// 
13"Critical Job" 14"Laid-off" 15"Work from home" 16"Freelancer" 17"Temporary job" 18"Loneliness" 19"Depression" 20"Anxiety Disorder") plotlabels("Normal" "Overweight" "Obesity") graphregion(color(white)) bgcolor(white) eform name(Increase5, replace)

graph combine Increase5 Decrease5 


save "G:\OV20_0544\COVID Reduced Datasets Correct 120521\STATA\Reduced Datasets\Paper 5\COVQ_LIFELINES_LONG_MERGED_121022.dta", replace

*****************************************************************************************************
**COMPARE 1st & 2nd LOCKDOWN

bysort PSEUDOIDEXT: replace Traj3_1lock = Traj3_1lock[_n-1] if missing(Traj3_1lock) & Days<=214

 
*Models 1st lockdown:
mlogit Traj3_1lock i.Gender ib3.Age_cat2 ib3.EA i.Employment2 ib2.Household2 i.Chronic_cov i.Critical_cov i.Laidoff_cov i.Workhome_cov i.ZZP_cov i.Temp_cov i.Isolation_cov i.MD_cov i.Anx_cov i.BMIfirst_cat if ID==1 & count>1 & Lockdown==1, base(2)rrr 
est store Traj3lock1

est restore Traj3lock1
margins, dydx(*) predict(outcome(1) xb) post
est save t31lock1, replace
est restore Traj3lock1
margins, dydx(*) predict(outcome(3) xb) post
est save t33lock1, replace

***2nd Lockdown
bysort PSEUDOIDEXT: replace Traj3_2lock = Traj3_2lock[_n-1] if missing(Traj3_2lock) & Days>214

mlogit Traj3_2lock i.Gender ib3.Age_cat2 ib3.EA i.Employment2 ib2.Household2 i.Chronic_cov i.Critical_cov i.Laidoff_cov i.Workhome_cov i.ZZP_cov i.Temp_cov i.Isolation_cov i.MD_cov i.Anx_cov i.BMIfirst_cat if count>1 & Lockdown==2, base(2)rrr 
est store Traj3lock2 

est restore Traj3lock2
margins, dydx(*) predict(outcome(1) xb) post
est save t31lock2, replace 
est restore Traj3lock2
margins, dydx(*) predict(outcome(3) xb) post
est save t33lock2, replace

est use t31lock1 
est store t31lock1
est use t33lock1
est store t33lock1
est use t31lock2
est store t31lock2
est use t33lock2
est store t33lock2

coefplot t31lock1 t31lock2, drop(_cons 5.Employment2 2.EA 1.BMIfirst_cat 2.BMIfirst_cat 3.BMIfirst_cat) xline(1) title("BMI Decrease") ylab(1"Women" 2"Age40" 3"Age 41-50" 4"Age 61-70" 5"Age 70+" 6"Lower SES" 7"Retired" 8"Unemployed" 9"Disabled" 10"Lives alone" 11"Family & children" 12"Chronic disease" /// 
13"Critical Job" 14"Laid-off" 15"Work from home" 16"Freelancer" 17"Temporary job" 18"Loneliness" 19"Depression" 20"Anxiety") plotlabels("1st lockdown" "2nd lockdown") graphregion(color(white)) bgcolor(white) eform name(Decrease3lock, replace)

coefplot t33lock1 t33lock2, drop(_cons 5.Employment2 2.EA 1.BMIfirst_cat 2.BMIfirst_cat 3.BMIfirst_cat) xline(1) title("BMI Increase") ylab(1"Women" 2"Age40" 3"Age 41-50" 4"Age 61-70" 5"Age 70+" 6"Lower SES" 7"Retired" 8"Unemployed" 9"Disabled" 10"Lives alone" 11"Family & children" 12"Chronic disease" /// 
13"Critical Job" 14"Laid-off" 15"Work from home" 16"Freelancer" 17"Temporary job" 18"Loneliness" 19"Depression" 20"Anxiety") plotlabels("1st lockdown" "2nd lockdown") graphregion(color(white)) bgcolor(white) eform name(Increase3lock, replace)

graph combine Increase3lock Decrease3lock 
 

 
 **ACCUMULATIVE EFFECTS: AGGREGATE DISRUPTIVE EVENTS
 *Working sphere
gen Disrupt_Work = Critical_cov + Laidoff_cov + Workhome_cov + ZZP_cov + Temp_cov
recode Disrupt_Work 4=3 5=3 6=3
 
gen Disrupt_Health = Isolation_cov  + MD_cov  + Anx_cov

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


coefplot mdisrupt3, drop(_cons 5.Employment2 2.EA 1.BMIfirst_cat 2.BMIfirst_cat 3.BMIfirst_cat) xline(1) title("BMI Increase") ///
ylab(1"Workrelatedevents" 2"2 events" 3"3+ events" 4"Health-related events (1)" 5"2 events" 6"3+ events" 7"Retired" 8"Unemployed" 9"Disabled" ///
10"Lives alone" 11"Family & children" 12"Female" 13"Age40" 14"Age 41-50" 15"Age 61-70" 16"Age 70+" 17"Lower SES" 18"Chronic disease") ///
graphregion(color(white)) bgcolor(white) eform name(Disrupt3inc, replace)

coefplot mdisrupt1, drop(_cons 5.Employment2 2.EA 1.BMIfirst_cat 2.BMIfirst_cat 3.BMIfirst_cat) xline(1) title("BMI Decrease") ///
ylab(1"Workrelatedevents" 2"2 events" 3"3+ events" 4"Health-related Event(1)" 5"2 events" 6"3+ events" 7"Retired" 8"Unemployed" 9"Disabled" ///
10"Lives alone" 11"Family & children" 12"Female" 13"Age40" 14"Age 41-50" 15"Age 61-70" 16"Age 70+" 17"Lower SES" 18"Chronic disease") ///
graphregion(color(white)) bgcolor(white) eform name(Disrupt3dec, replace)

graph combine Disrupt3inc Disrupt3dec

*All in one graph...confusing
coefplot mdisrupt3 mdisrupt1, drop(_cons 5.Employment2 2.EA 1.BMIfirst_cat 2.BMIfirst_cat 3.BMIfirst_cat) xline(1) /// 
ylab(1"Workrelatedevents" 2"2 events" 3"3+ events" 4"Health-related events (1)" 5"2 events" 6"3+ events" 7"Retired" 8"Unemployed" 9"Disabled" ///
10"Lives alone" 11"Family & children" 12"Female" 13"Age40" 14"Age 41-50" 15"Age 61-70" 16"Age 70+" 17"Lower SES" 18"Chronic disease") /// 
graphregion(color(white)) bgcolor(white) eform plotlabels("BMI increase" "BMI decrease") 


*Focus on these two spheres:
coefplot mdisrupt3, drop(_cons 1.Employment2 2.Employment2 3.Employment2 4.Employment2 5.Employment2 1.EA 2.EA 3.EA 1.BMIfirst_cat 2.BMIfirst_cat 3.BMIfirst_cat  ///
0.Household2 1.Household2 2.Household2 0.Gender 1.Gender 1.Age_cat2 2.Age_cat2 3.Age_cat2 4.Age_cat2 5.Age_cat2 1.Chronic_cov) xline(1) ///
title("BMI Increase") ylab(1"Workrelatedevents" 2"2 events" 3"3+ events" 4"Health-related events (1)" 5"2 events" 6"3+ events" ) ///
graphregion(color(white)) bgcolor(white) eform name(Disrupt3inc_focus, replace)

coefplot mdisrupt1, drop(_cons 1.Employment2 2.Employment2 3.Employment2 4.Employment2 5.Employment2 1.EA 2.EA 3.EA 1.BMIfirst_cat 2.BMIfirst_cat 3.BMIfirst_cat  ///
0.Household2 1.Household2 2.Household2 0.Gender 1.Gender 1.Age_cat2 2.Age_cat2 3.Age_cat2 4.Age_cat2 5.Age_cat2 1.Chronic_cov) xline(1) ///
title("BMI Decrease") ylab(1"Workrelatedevents" 2"2 events" 3"3+ events" 4"Health-related events (1)" 5"2 events" 6"3+ events" ) ///
graphregion(color(white)) bgcolor(white) eform xscale(r(1(.5)2.5)) name(Disrupt3dec_focus, replace)

graph combine Disrupt3inc_focus Disrupt3dec_focus 

coefplot (mdisrupt3,symbol(T)col(black)) (mdisrupt1, symbol(D)col(gray)), drop(_cons 1.Employment2 2.Employment2 3.Employment2 4.Employment2 5.Employment2 1.EA 2.EA 3.EA 1.BMIfirst_cat 2.BMIfirst_cat 3.BMIfirst_cat  ///
0.Household2 1.Household2 2.Household2 0.Gender 1.Gender 1.Age_cat2 2.Age_cat2 3.Age_cat2 4.Age_cat2 5.Age_cat2 1.Chronic_cov) ///
title("Work & Health domains") ylab(1"Workrelatedevents" 2"2 events" 3"3+ events" 4"Health-related events (1)" 5"2 events" 6"3+ events" ) ///
graphregion(color(white)) bgcolor(white) eform plotlabels("BMI increase" "BMI decrease") name(Workhealthacc, replace)
 
 
*Accumulative ALL 
gen Events_All = Critical_cov + Laidoff_cov + Workhome_cov + ZZP_cov + Temp_cov + Isolation_cov  + MD_cov  + Anx_cov
recode Events_All 7=6

mlogit Traj_BMI3c i.Events_All i.Employment2 ib2.Household2 i.Gender ib3.Age_cat2 ib3.EA i.Chronic_cov i.BMIfirst_cat if ID==1 & count>1, base(2)rrr 
est store Mevents

est restore Mevents
margins, dydx(*) predict(outcome(3) xb) post
est save mevents3, replace
est store mevents3

est restore Mevents
margins, dydx(*) predict(outcome(1) xb) post
est save mevents1, replace
est store mevents1

coefplot (mevents3, col(black)) (mevents1, symbol(T) col(gray)), drop(_cons 1.Employment2 2.Employment2 3.Employment2 4.Employment2 5.Employment2 1.EA 2.EA 3.EA 1.BMIfirst_cat 2.BMIfirst_cat 3.BMIfirst_cat  ///
0.Household2 1.Household2 2.Household2 0.Gender 1.Gender 1.Age_cat2 2.Age_cat2 3.Age_cat2 4.Age_cat2 5.Age_cat2 1.Chronic_cov) ylab(1"DisruptiveEvent" 2"2 events" 3"3 events" 4"4 events" 5"5 events" 6"6+ events") ///
bgcolor(white) graphregion(color(white)) eform plotlabels("BMI increase" "BMI decrease")   


*Recode
gen Events_All2 = Critical_cov + Laidoff_cov + Workhome_cov + ZZP_cov + Temp_cov + Isolation_cov  + MD_cov  + Anx_cov
recode Events_All2 7=5 6=5

mlogit Traj_BMI3c i.Events_All2 i.Employment2 ib2.Household2 i.Gender ib3.Age_cat2 ib3.EA i.Chronic_cov i.BMIfirst_cat if ID==1 & count>1, base(2)rrr 
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

graph combine Workhealthacc Accum_all, cols(1) 



*BMI changes in PERCENT
merge 1:1 PSEUDOIDEXT ID using "G:\OV20_0544\COVID Reduced Datasets Correct 120521\STATA\Reduced Datasets\Paper 5\Traj_BMIpercent_181022.dta", nogenerate
drop if Gender==. 


bysort PSEUDOIDEXT: replace Traj_BMI3percent = Traj_BMI3percent[_n-1] if missing(Traj_BMI3percent)

mlogit Traj_BMI3percent i.Critical_cov i.Laidoff_cov i.Workhome_cov i.ZZP_cov i.Temp_cov i.Isolation_cov i.MD_cov i.Anx_cov i.Employment2 ib2.Household2 i.Gender ib3.Age_cat2 ib3.EA i.Chronic_cov i.BMIfirst_cat if ID==1 & count>1, base(2)rrr 
est store M3percent

margins, dydx(*) predict(outcome(1) xb) post
est store m3percent1
est save m3percent1
est restore M3percent
margins, dydx(*) predict(outcome(3) xb) post
est store m3percent3
est save m3percent3

coefplot (m3percent3, symbol(T)), drop(_cons 5.Employment2 2.EA 1.BMIfirst_cat 2.BMIfirst_cat 3.BMIfirst_cat) xline(1) ylab(1"Criticaljob" 2"Laid-off" 3"Work from home" 4"Freelancer" 5"Temporary job" 6"Loneliness" /// 
7"Depression" 8"Anxiety" 9"Retired" 10"Unemployed" 11"Disabled" 12"Lives alone" 13"Family & children" 14"Female" 15"Age40" 16"Age 41-50" 17"Age 61-70" 18"Age 70+" 19"Lower SES" 20"Chronic disease") ///
graphregion(color(white)) bgcolor(white) eform title("BMI increase") name("BMI3percent_inc")

coefplot (m3percent1, symbol(D)), drop(_cons 5.Employment2 2.EA 1.BMIfirst_cat 2.BMIfirst_cat 3.BMIfirst_cat) xline(1) ylab(1"Criticaljob" 2"Laid-off" 3"Work from home" 4"Freelancer" 5"Temporary job" 6"Loneliness" /// 
7"Depression" 8"Anxiety" 9"Retired" 10"Unemployed" 11"Disabled" 12"Lives alone" 13"Family & children" 14"Female" 15"Age40" 16"Age 41-50" 17"Age 61-70" 18"Age 70+" 19"Lower SES" 20"Chronic disease") ///
graphregion(color(white)) bgcolor(white) eform title("BMI decrease") name("BMI3percent_dec")

graph combine BMI3percent_inc BMI3percent_dec 



save "G:\OV20_0544\COVID Reduced Datasets Correct 120521\STATA\Reduced Datasets\Paper 5\COVQ_LIFELINES_LONG_MERGED_121022.dta", replace



***********************************************
***********************************************
************************************************
**Group-based trajectory analyses (loop) 

use "G:\OV20_0544\COVID Reduced Datasets Correct 120521\STATA\Reduced Datasets\Paper 5\COVQ_LIFELINES_LONG_MERGED_310522.dta", clear
sysdir set PLUS "I:\Lifelines\Programs\STATA-packages-installed"


*Create dummies
gen Unemployed=1 if Employment2==3
replace Unemployed=0 if Unemployed==.
replace Unemployed=. if Employment2==.

gen Retired=1 if Employment2==2
replace Retired=0 if Retired==.
replace Retired=. if Employment2==.

gen Disabled=1 if Employment2==4
replace Disabled=0 if Disabled==.
replace Disabled=. if Employment2==.


gen age_40less=1 if Age_cat2==1
replace age_40less=0 if age_40less==. & Age_cat2!=.

gen age_4150=1 if Age_cat2==2
replace age_4150=0 if age_4150==. & Age_cat2!=.

gen age_6170=1 if Age_cat2==4
replace age_6170=0 if age_6170==. & Age_cat2!=.

gen age_70plus=1 if Age_cat2==5
replace age_70plus=0 if age_70plus==. & Age_cat2!=.


gen low=1 if EA==1
replace low=0 if low==. & EA!=.

gen mid=1 if EA==2
replace mid=0 if mid==. & EA!=.


contract PSEUDOIDEXT Wave Days BMIchange BMI_first Gender age* low mid Retired Unemployed Disabled Livealone Kids Chronic_cov Critical_cov Laidoff_cov Workhome_cov ZZP_cov Temp_cov Isolation_cov MD_cov Anx_cov count ID

keep if Wave>0 & count>1
drop count ID 

reshape wide Days BMIchange BMI_first Gender age* low mid Retired Unemployed Disabled Livealone Kids Chronic_cov Critical_cov Laidoff_cov Workhome_cov ZZP_cov Temp_cov Isolation_cov MD_cov Anx_cov, i(PSEUDOIDEXT) j(Wave)

drop *10 *16 *18


*Fill empty cells at first observation with values from next observations
foreach var in BMI_first Gender age_40less age_4150 age_6170 age_70plus low mid Unemployed Retired Disabled Livealone Kids Chronic_cov Critical_cov Laidoff_cov Workhome_cov ZZP_cov Temp_cov Isolation_cov MD_cov Anx_cov {
 forvalues i = 2/24 {
	capture noisily replace `var'1 = `var'`i' if `var'1==.
	}
}
	

traj, var(BMIchange*) indep(Days*) model(cnorm) order(3 3 3) min(-2.5) max(2.5) risk(BMI_first1 Gender1 age_40less1 age_41501 age_61701 age_70plus1 low1 mid1 Unemployed1 Retired1 Disabled1 Livealone1 Kids1 Chronic_cov1 Critical_cov1 Laidoff_cov1 Workhome_cov1 ZZP_cov1 Temp_cov1 Isolation_cov1 MD_cov1 Anx_cov1) refgroup(2)
rename _traj_Group Traj3_covcons2


traj, var(BMIchange*) indep(Days*) model(cnorm) order(3 3 3 3 3) min(-2.5) max(2.5) risk(BMI_first1 Gender1 age_40less1 age_41501 age_61701 age_70plus1 low1 mid1 Unemployed1 Retired1 Disabled1 Livealone1 Kids1 Chronic_cov1 Critical_cov1 Laidoff_cov1 Workhome_cov1 ZZP_cov1 Temp_cov1 Isolation_cov1 MD_cov1 Anx_cov1) refgroup(3)
rename _traj_Group Traj5_covcons2

keep PSEUDO Traj3_covcons2 Traj5_covcons2 
gen Wave=1
save "G:\OV20_0544\COVID Reduced Datasets Correct 120521\STATA\Reduced Datasets\Paper 5\Traj_variables_COVcons_050722.dta"
