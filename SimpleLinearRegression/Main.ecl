IMPORT ML;

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

layout := RECORD
	STRING name;
	REAL8 height;
	REAL8 weight;
	UNSIGNED age;
END;

oRawDS := DATASET([
	{ 'Alfred', 69.0, 112.5, 14 },
  { 'Alice', 56.5, 84.0, 13 },
  { 'Barbara', 65.3, 98.0, 13 },
	{ 'Carol', 62.8, 102.5, 14 },
  { 'Henry', 63.5, 102.5, 14 },
  { 'James', 57.3, 83.0, 12 },
	{ 'Jane', 59.8, 84.5, 12 },
  { 'Janet', 62.5, 112.5, 15 },
  { 'Jeffrey', 62.5, 84.0, 13 },
	{ 'John', 59.0, 99.5, 12 },
  { 'Joyce', 51.3, 50.5, 11 },
  { 'Judy', 64.3, 90.0, 14 },
	{ 'Louise', 56.3, 77.0, 12 },
  { 'Mary', 66.5, 112.0, 15 },
  { 'Philip', 72.0, 150.0, 16 },
	{ 'Robert', 64.8, 128.0, 12 },
  { 'Ronald', 67.0, 133.0, 15 },
  { 'Thomas', 57.5, 85.0, 11 },
	{ 'William', 66.5, 112.0, 15}
	], layout );
	
	
ml_layout := RECORD( layout )
	UNSIGNED __id;
END;

oDS := PROJECT( oRawDS, TRANSFORM( ml_layout,
	SELF.__id := COUNTER;
	SELF := LEFT;
));

ML.ToField( oDS, oFields, __id );
oFields_Map;
X := oFields( Number = 1 );
Y := oFields( Number = 2 );
Reg := ML.Regression.Sparse.OLS_LU(X,Y);
augment_field_name( Betas, Reg.Betas, oFields, number, var_name );
OUTPUT( Betas, NAMED('RegressionBetas') );
OUTPUT( Reg.RSquared, NAMED('RegressionRSquared') );
OUTPUT( Reg.Anova, NAMED('RegressionAnova') );

report_on_parameters( pRegression, pFields ) := MACRO
	parameter_estimate_layout := RECORD
		UNSIGNED id;
		UNSIGNED variable_id;
		STRING variable_name := '';
		UNSIGNED df := 1;
		REAL8 parameter_estimate := 0.0;
		REAL8 standard_error := 0.0;
		REAL8 t_value := 0.0;
	END;
	ParameterEstimates_0 := JOIN( pRegression.Betas, pRegression.SE, LEFT.id = RIGHT.id AND LEFT.number = RIGHT.number, TRANSFORM( parameter_estimate_layout,
		SELF.id := LEFT.id;
		SELF.variable_id := LEFT.number;
		SELF.parameter_estimate := LEFT.value;
		SELF.standard_error := RIGHT.value;
	), LEFT OUTER );
	ParameterEstimates_1 := JOIN( ParameterEstimates_0, pRegression.tStat, LEFT.id = RIGHT.id AND LEFT.variable_id = RIGHT.number, TRANSFORM( parameter_estimate_layout,
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

report_on_parameters( Reg, oFields );
report_on_variance( Reg, oFields );
report_on_misc( Reg, oFields );