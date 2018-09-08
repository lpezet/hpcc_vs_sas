IMPORT ML_Core AS ML;
IMPORT LinearRegression AS LR;
//IMPORT AerobicFitnessPrediction AS AFR;

/* 
	===================================================================================
	Utility functions
	===================================================================================
*/
augment_field_name( pResult, pDS, pFields, pIdField, pNameField ) := MACRO
	pResult := JOIN( pDS, #EXPAND(#TEXT(pFields) + '_Map'), (STRING) LEFT.pIdField = RIGHT.assigned_name, TRANSFORM( { STRING pNameField; RECORDOF( pDS ) },
		SELF.pNameField := RIGHT.orig_name;
		SELF := LEFT;
	), LEFT OUTER);
ENDMACRO;

fillin_field_name_( pResult, pDS, pFields, pIdField, pNameField ) := MACRO
	pResult := JOIN( pDS, #EXPAND(#TEXT(pFields) + '_Map'), (STRING) LEFT.pIdField = RIGHT.assigned_name, TRANSFORM( RECORDOF( pDS ),
		SELF.pNameField := RIGHT.orig_name;
		SELF := LEFT;
	), LEFT OUTER);
ENDMACRO;

filter_by_name( pFields, pNames ) := FUNCTIONMACRO
	RETURN
		JOIN( pFields, #EXPAND(#TEXT(pFields) + '_Map'), (STRING) LEFT.number = RIGHT.assigned_name, TRANSFORM( RECORDOF( pFields ), 
			SKIP( RIGHT.orig_name NOT IN pNames );
			SELF := LEFT;
		));
ENDMACRO;


report_on_parameters( pOLS, pRegression, pFields ) := MACRO
	parameter_estimate_layout := RECORD
		UNSIGNED id;
		UNSIGNED variable_id;
		STRING variable_name := '';
		UNSIGNED df := 1;
		REAL8 parameter_estimate := 0.0;
		REAL8 standard_error := 0.0;
		REAL8 t_value := 0.0;
	END;
	ParameterEstimates_0 := JOIN( pOLS.Betas( pRegression), pOLS.SE, LEFT.id = RIGHT.id AND LEFT.number = RIGHT.number, TRANSFORM( parameter_estimate_layout,
		SELF.id := LEFT.id;
		SELF.variable_id := LEFT.number;
		SELF.parameter_estimate := LEFT.value;
		SELF.standard_error := RIGHT.value;
	), LEFT OUTER );
	ParameterEstimates_1 := JOIN( ParameterEstimates_0, pOLS.TStat, LEFT.id = RIGHT.id AND LEFT.variable_id = RIGHT.number, TRANSFORM( parameter_estimate_layout,
		SELF.t_value := RIGHT.value;
		SELF := LEFT;
	), LEFT OUTER );
	fillin_field_name_( ParameterEstimates, ParameterEstimates_1, pFields, variable_id, variable_name );
	OUTPUT(ParameterEstimates, NAMED('ParameterEstimates') );
ENDMACRO;


report_on_variance( pRegression, pFields ) := MACRO
	anova_layout := RECORD
		STRING source;
		UNSIGNED df := 1;
		STRING sum_of_squares;
		STRING mean_square;
		STRING f_value;
	END;

	anova_layout tx_anova( RECORDOF( pRegression.Anova ) pRecord, INTEGER pVar ) := TRANSFORM
		SELF.source := CASE( pVar, 1 => 'Model', 2 => 'Error', 3 => 'Corrected Total', '' );
		SELF.df := CASE( pVar, 1 => pRecord.model_df, 2 => pRecord.error_df, 3 => pRecord.total_df, 0 );
		SELF.sum_of_squares := CASE( pVar, 1 => '' + pRecord.model_ss, 2 => '' + pRecord.error_ss, 3 => '' + pRecord.total_ss, '' );
		SELF.mean_square := CASE( pVar, 1 => '' + pRecord.model_ms, 2 => '' + pRecord.error_ms, '' );
		SELF.f_value := CASE( pVar, 1 => '' + pRegression.FTest[1].model_f, '');
	END;

	Anova1 := NORMALIZE( pRegression.Anova, 3, tx_anova(LEFT, COUNTER) );
	OUTPUT( Anova1, NAMED('AnalysisOfVariance') );
ENDMACRO;


report_on_misc( pRegression, pFields ) := MACRO

	misc_layout := RECORD
		UNSIGNED variable_id;
		STRING variable_name := '';
		STRING name;
		STRING value;
	END;

	Misc_0 := PROJECT( pRegression.RSquared, TRANSFORM( misc_layout,
		SELF.variable_id := LEFT.number;
		SELF.name := 'R-Sq';
		SELF.value := '' + LEFT.rsquared;
	));
	Misc_1 := PROJECT( pRegression.AdjRSquared, TRANSFORM( misc_layout,
		SELF.variable_id := LEFT.number;
		SELF.name := 'Adj R-Sq';
		SELF.value := '' + LEFT.rsquared;
	));
	Misc_2 := Misc_0 + Misc_1;
	fillin_field_name_( Misc, Misc_2, pFields, variable_id, variable_name );
	OUTPUT( Misc, NAMED('Misc') );

ENDMACRO;



/* 
	===================================================================================
	Analysis
	===================================================================================
*/
layout := RECORD
	UNSIGNED age;
	REAL8 weight;
	REAL8 oxygen;
	REAL8 runTime;
	UNSIGNED restPulse;
	UNSIGNED runPulse;
	UNSIGNED maxPulse;
END;

oRawData := DATASET([
	{ 44, 89.47, 44.609, 11.37, 62, 178, 182 },
	{ 40, 75.07, 45.313, 10.07, 62, 185, 185 },
	{ 44, 85.84, 54.297,  8.65, 45, 156, 168 },
	{ 42, 68.15, 59.571,  8.17, 40, 166, 172 },
	{ 38, 89.02, 49.874,  9.22, 55, 178, 180 },
	{ 47, 77.45, 44.811, 11.63, 58, 176, 176 },
	{ 40, 75.98, 45.681, 11.95, 70, 176, 180 },
	{ 43, 81.19, 49.091, 10.85, 64, 162, 170 },
	{ 44, 81.42, 39.442, 13.08, 63, 174, 176 },
	{ 38, 81.87, 60.055,  8.63, 48, 170, 186 },
	{ 44, 73.03, 50.541, 10.13, 45, 168, 168 },   
	{ 45, 87.66, 37.388, 14.03, 56, 186, 192 },
	{ 45, 66.45, 44.754, 11.12, 51, 176, 176 },   
	{ 47, 79.15, 47.273, 10.60, 47, 162, 164 },
	{ 54, 83.12, 51.855, 10.33, 50, 166, 170 },   
	{ 49, 81.42, 49.156,  8.95, 44, 180, 185 },
	{ 51, 69.63, 40.836, 10.95, 57, 168, 172 },   
	{ 51, 77.91, 46.672, 10.00, 48, 162, 168 },
	{ 48, 91.63, 46.774, 10.25, 48, 162, 164 },   
	{ 49, 73.37, 50.388, 10.08, 67, 168, 168 },
	{ 57, 73.37, 39.407, 12.63, 58, 174, 176 },   
	{ 54, 79.38, 46.080, 11.17, 62, 156, 165 },
	{ 52, 76.32, 45.441,  9.63, 48, 164, 166 },  
	{ 50, 70.87, 54.625,  8.92, 48, 146, 155 },
	{ 51, 67.25, 45.118, 11.08, 48, 172, 172 },   
	{ 54, 91.63, 39.203, 12.88, 44, 168, 172 },
	{ 51, 73.71, 45.790, 10.47, 59, 186, 188 },
	{ 57, 59.08, 50.545,  9.93, 49, 148, 155 },
	{ 49, 76.32, 48.673,  9.40, 56, 186, 188 },
	{ 48, 61.24, 47.920, 11.50, 52, 170, 176 },
	{ 52, 82.78, 47.467, 10.50, 53, 170, 172 }
	], layout );
	
	
a_layout := RECORD( layout )
	UNSIGNED __id;
END;

oData := PROJECT( oRawData, TRANSFORM( a_layout,
	SELF.__id := COUNTER;
	SELF := LEFT;
));

ML.ToField( oData, oFields, __id );
OUTPUT( oFields, NAMED('Fields') );
OUTPUT( oFields_Map, NAMED('FieldsMap') );

X := oFields( Number IN [ 1, 2, 4, 6, 5, 7 ] ); // Age, Weight, RunTime, RunPulse, RestPulse, MaxPulse
Y := oFields( Number IN [ 3 ] ); // Oxygen
/*
layoutExtra := RECORD(RECORDOF(oFields))
	STRING var_name := '';
END;
XPrime := PROJECT(X, layoutExtra);
YPrime := PROJECT(Y, layoutExtra);
fillin_field_name_( OutX, XPrime, oFields, number, var_name);
fillin_field_name_( OutY, YPrime, oFields, number, var_name);
OUTPUT(OutX, ALL);
OUTPUT(OutY, ALL);
*/

// OLD "ML" Code
// Forward model-selection method
/*
ForwardReg := ML.StepRegression.ForwardRegression( X, Y );
ForwardModel := ForwardReg.BestModel;
report_on_parameters( ForwardModel, oFields );
report_on_variance( ForwardModel, oFields );
report_on_misc( ForwardModel, oFields );

OUTPUT( ForwardReg.Steps, NAMED('ForwardSteps') );
OUTPUT( ForwardModel.FTest, NAMED('FTests') );
*/

MyLR := LR.OLS( X, Y );
MyLRModel := MyLR.GetModel;
report_on_parameters( MyLR, MyLRModel, oFields );

//MyLR.RSquared;

//MyLR.Betas();
//MyLR.SE;
/*
MyLR.TStat;

MyLR.Anova;
MyLR.AdjRSquared;
//SomeReg.AICRec;
MyLR.AIC;
MyLR.pVal;
MyLR.FTest;

//report_on_parameters( MyLR, SomeModel, oFields );
//report_on_variance( MyLR, oFields );
//report_on_misc( MyLR, oFields );
*/