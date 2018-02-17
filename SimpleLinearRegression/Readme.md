#

Source: https://support.sas.com/documentation/cdl/en/statug/63033/HTML/default/viewer.htm#statug_reg_sect003.htm

# How to run it

You'll need to have Machine Learning bundle loaded up.
Then load ``Main.ecl`` file and just submit it.
The data is inline and outputs are used to present the results below.

## SAS results

Those are the results provided on the SAS site (see source above).

**Analysis of variance**:

| Source | DF | Sum of Squares | Mean Square | F Value | Pr > F |
| ------ | -- | -------------- | ----------- | ------- | ------ |
| Model | 1 | 7193.24912 | 7193.24912 | 57.08 | <.0001 |
| Error | 17 | 2142.48772 | 126.026869 | | |	 	
| Corrected Total | 18 | 9335.73684 | | |

**Parameter Estimates**:

| Variable | Parameter Estimate | Standard Error | t Value | Pr > F |
| -------- | ------------------ | -------------- | ---------- | ------ |
| Intercept | -143.02692 | 32.27459 | -4.43 | 0.0004 |
| Height | 3.89903 | 0.51609 | 7.55 | 7.55 | <.0001 |

## HPCC results

**Analysis of variance**:

| Source | DF | Sum of Squares | Mean Square | F Value | Pr > F |
| ------ | -- | -------------- | ----------- | ------- | ------ |
| Model | 1 | 7193.249118637699 | 7193.249118637699 | 57.07628271443527 |  |
| Error | 17 | 2142.487723467553 | 126.0286896157384 | | |	 	
| Corrected Total | 18 | 9335.736842105252 | | |

**Parameter Estimates**:

| Variable | Parameter Estimate | Standard Error | t Value | Pr > F |
| -------- | ------------------ | -------------- | ---------- | ------ |
| Intercept | -143.0269184393352 | 32.27459130325634 | -4.431564046634558 |  |
| Height | 3.899030268783662 | 0.5160939481632426  | 7.554884692331992  |  |
