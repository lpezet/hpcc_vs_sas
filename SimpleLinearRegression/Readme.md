# Simple Linear Regression

The original example uses regression analysis to find out how well you can predict a child's weight if you know that child's height. 
The data used here are from a study of nineteen children. Height and weight are measured for each child.

You can find the original example here: https://support.sas.com/documentation/cdl/en/statug/63033/HTML/default/viewer.htm#statug_reg_sect003.htm

# How to run it

You'll need to have Machine Learning bundle loaded up.
Then load ``Main.ecl`` file and just submit it.
The data is inline and outputs are used to present the results below.

The core of the ECL code lies in the following:
```ecl
X := filter_by_name( oFields, [ 'height' ] );
Y := filter_by_name( oFields, [ 'weight' ]);
Reg := ML.Regression.Sparse.OLS_LU(X,Y);
```

# Conclusion

Results are similar between HPCC and SAS. Both SAS and HPCC use Ordinary Least Square method to find model parameters here.

# Results


## Analysis of variance

| Source |     | DF | Sum of Squares | Mean Square | F Value | Pr > F |
| --- | ------ | -- | -------------- | ----------- | ------- | ------ |
| Model | SAS  | 1 | 7,193.24912 | 7,193.24912 | 57.08 | <.0001 |
|       | HPCC | 1 | 7,193.249118637699 | 7,193.249118637699 | 57.07628271443527 |  |
| Error | SAS  | 17 | 2,142.48772 | 126.026869 | | |	 	
|       | HPCC | 17 | 2,142.487723467553 | 126.0286896157384 | | |	 	
| Corrected Total | SAS  | 18 | 9,335.73684 | | |
|                 | HPCC | 18 | 9,335.736842105252 | | |


## Model

**SAS**:

| Variable | Parameter Estimate | Standard Error | t Value | Pr > F |
| -------- | ------------------ | -------------- | ---------- | ------ |
| Intercept | -143.02692 | 32.27459 | -4.43 | 0.0004 |
| Height | 3.89903 | 0.51609 | 7.55 | 7.55 | <.0001 |

**HPCC**:

| Variable | Parameter Estimate | Standard Error | t Value | Pr > F |
| -------- | ------------------ | -------------- | ---------- | ------ |
| Intercept | -143.0269184393352 | 32.27459130325634 | -4.431564046634558 |  |
| Height | 3.899030268783662 | 0.5160939481632426  | 7.554884692331992  |  |


# References

[1] SAS Regression, https://support.sas.com/rnd/app/stat/procedures/Regression.html

