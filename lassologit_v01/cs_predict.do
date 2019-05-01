
clear all 


********************************************************************************
*** Verify post-logit predictions 											 ***
********************************************************************************

insheet using "spam.data", clear delim(" ")
gen myholdout = _n>4000

foreach lam in 0.18 .1 .05 .01 0.005 0.001 {
	
	cap drop yhat* phat*
	
	lassologit v58 v1-v57, l(`lam') postlogit 
	predict double yhat_my, xb
	predict double phat_my, pr

	local sel = e(selected)
	logit v58 `sel'
	predict double yhat_logit, xb
	predict double phat_logit, pr
	
	assert reldif(yhat_my,yhat_logit)<10e4
	assert reldif(phat_my,phat_logit)<10e4
}
//

********************************************************************************
*** Verify "predict" using internal ("Mata") predictions					 ***
********************************************************************************

foreach lam in 0.18 .1 .05 .01 0.005 0.001 {

	insheet using "spam.data", clear delim(" ")
	gen myholdout = _n>4000

	lassologit v58 v1-v57, l(`lam') savep
	mat P = e(phat)
	svmat P

	predict double p0, pr
	
	assert reldif(P1,p0)<10e-4
	
}
//

foreach lam in 0.18 .1 .05 .01 0.005 0.001 {

	insheet using "spam.data", clear delim(" ")
	gen myholdout = _n>4000

	lassologit v58 v1-v57, l(`lam') savep postlogit
	mat P = e(phat)
	svmat P

	predict double p0, pr
	
	assert reldif(P1,p0)<10e-4
	
}
//

foreach lam in 0.18 .1 .05 .01 0.005 0.001 {

	insheet using "spam.data", clear delim(" ")
	gen myholdout = _n>4000

	lassologit v58 v1-v57, l(`lam') savep nocons
	mat P = e(phat)
	svmat P

	predict double p0, pr
	
	assert reldif(P1,p0)<10e-4
	
}
//

********************************************************************************
*** Verify using glmnet	(cs_predict.R)										 ***
********************************************************************************

insheet using prostate.data, clear

gen ybin = lpsa > 2

lassologit ybin lcavol-pgg45, lam(.2 .11 .1 0.05 0.01) savep
mat P = e(phat)
mat P = P[97,1..5]
mat G = ( 0.761871934040682,0.883722877193935,0.895110432984738,0.955542318252603,0.999505561515738)
assert mreldif(P,G)<0.01

lassologit ybin lcavol-pgg45, lam(.2 .11 .1 0.05 0.01) savep nocons
mat P = e(phat)
mat P = P[97,1..5]
mat G = ( 0.761411339295924,0.883320216213757,0.893762132556822,0.956213536648691,0.999298395412146)
assert mreldif(P,G)<0.01

lassologit ybin lcavol-pgg45, lam(.2 .11 .1 0.05 0.01) savep nostd
mat P = e(phat)
mat P = P[97,1..5]
mat G = ( 0.708638828605104,0.858851204259658,0.872566014019627,0.931492511316991,0.998846180327787)
assert mreldif(P,G)<0.01

lassologit ybin lcavol-pgg45, lam(.2 .11 .1 0.05 0.01) savep nostd nocons
mat P = e(phat)
mat P = P[97,1..5]
mat G = ( 0.703648308982215,0.853973607193486,0.868497657957821,0.929886289492582,0.998267904285371)
assert mreldif(P,G)<0.01



********************************************************************************
*** comparison with mata predicted values									 ***
********************************************************************************


insheet using "spam.data", clear delim(" ")
gen myholdout = _n<50


*** in-sample

lassologit v58 v1-v57, lambda(0.1) savep holdout(myh)
mat Phat1 = e(phat)

svmat Phat1

predict double Phat2 , pr

assert abs(Phat1 - Phat2)<10e-8


*** in-sample

lassologit v58 v1-v57, lambda(0.1) savep
mat Phat1 = e(phat)

svmat Phat1

predict double Phat2, pr

assert abs(Phat1 - Phat2)<10e-8
