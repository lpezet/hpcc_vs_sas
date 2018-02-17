# Overview

This is a collection of HPCC ECL code trying to replicate some of the SAS papers/tutorials/analysis found around the web.
The goal is to understand how each side goes about different kind of analysis and data handling, especially in the context of modelling.


# Cases

## Aerobic Fitness Prediction

Source: https://support.sas.com/documentation/cdl/en/statug/63033/HTML/default/viewer.htm#statug_reg_sect055.htm

### SAS results
**Analysis of variance**:

| Source | DF | Sum of Squares | Mean Square | F Value | Pr > F |
| ------ | -- | -------------- | ----------- | ------- | ------ |
| Model | 5 | 721.97309 | 144.39462 | 27.90 | <.0001 |
| Error | 25 | 129.40845 | 5.17634 | | |	 	
| Corrected Total | 30 | 851.38154 | | |

**Parameter Estimates**:

| Variable | Parameter Estimate | Standard Error | Type II SS | F Value | Pr > F |
| -------- | ------------------ | -------------- | ---------- | ------- | ------ |
| Intercept | 102.20428 | 11.97929 | 376.78935 | 72.79 | <.0001 |
| Age | -0.21962 | 0.09550 | 27.37429 | 5.29 | 0.0301 |
| Weight | -0.07230 | 0.05331 | 9.52157 | 1.84 | 0.1871 |
| RunTime | -2.68252 | 0.34099 | 320.35968 | 61.89 | <.0001 |
| RunPulse | -0.37340 | 0.11714 | 52.59624 | 10.16 | 0.0038 |
| MaxPulse | 0.30491 | 0.13394 | 26.82640 | 5.18 | 0.0316 |

### HPCC results

**Analysis of variance**:

| Source | DF | Sum of Squares | Mean Square | F Value | Pr > F |
| ------ | -- | -------------- | ----------- | ------- | ------ |
| Model | 3 | 690.5508562698315 | 230.1836187566105 | 38.64285952967916 |  |
| Error | 27 | 160.8306885688717 | 5.9566921692169217469 | | |	 	
| Corrected Total | 30 | 851.3815448387031 | | |

**Parameter Estimates**:

| Variable | Parameter Estimate | Standard Error | Type II SS | F Value | Pr > F |
| -------- | ------------------ | -------------- | ---------- | ------- | ------ |
| Intercept | 111.7180644300601 | 10.2350883564144 |  |  |  |
| Age | -0.2563982563644796 | 0.09622891968604332  |  |  |  |
| RunTime | -2.825378672375977 | 0.3582804133589825  |  |  |  |
| RunPulse | -0.1309087004205246 | 0.059010925127248 | | | |

