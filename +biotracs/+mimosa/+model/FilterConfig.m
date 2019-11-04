% BIOASTER
%> @file 		FilterConfig.m
%> @class 		biotracs.mimosa.model.FilterConfig
%> @link			http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date        2016


classdef FilterConfig <  biotracs.mimosa.model.BaseProcessConfig
	 
	 properties(Constant)
	 end
	 
	 properties(SetAccess = protected)
	 end

	 % -------------------------------------------------------
	 % Public methods
	 % -------------------------------------------------------
	 
	 methods
		  
		  % Constructor
		  function this = FilterConfig( )
				this@biotracs.mimosa.model.BaseProcessConfig( );
				this.setDescription('Configuration for filtering a FeatureSet'); 
                this.createParam('GroupList', {'SampleType:Sample'}, ...
                'Constraint', biotracs.core.constraint.IsText('IsScalar', false));
                 this.createParam('QcGroup', {'SampleType:QC'}, ...
                'Constraint', biotracs.core.constraint.IsText('IsScalar', false));
                this.createParam('PercentageRuleThreshold', 0, ...
                    'Constraint',  biotracs.core.constraint.IsBetween([0,1]), ...
                    'Description', 'Percentage of features required in each sample group');
                this.createParam('QcCvThreshold', 0.2, ...
                    'Constraint',  biotracs.core.constraint.IsBetween([0,1]) ...
                    );
                this.createParam('BlankIntensityRatio', [], ...
                    'Constraint',  biotracs.core.constraint.IsNumeric(), ...
                    'Description', 'Threshold between Intensity of a feature in the Blank compared to the feature in a QC or Sample');
                this.createParam('LoQ', 0, ...
                    'Constraint',  biotracs.core.constraint.IsPositive() ...
                    );
                this.createParam('NbFirstQcToIgnore', 0, ...
                    'Constraint',  biotracs.core.constraint.IsPositive() ...
                    );
                this.createParam('NameQcToIgnore', {} ...
                    );
                 this.createParam('MethodOfFiltering', 'QcOnly', ...
                    'Constraint',  biotracs.core.constraint.IsInSet({'QcOnly', 'SampleOnly', 'QcAndSample', 'QcOrSample'}) ...
                    );
          end
		  
		  
	 end
	 
	 % -------------------------------------------------------
	 % Protected methods
	 % -------------------------------------------------------
	 
	 methods(Access = protected)
	 end

end
