% BIOASTER
%> @file 		DriftCorrectorConfig.m
%> @class 		biotracs.mimosa.model.DriftCorrectorConfig
%> @link			http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date			2016


classdef DriftCorrectorConfig < biotracs.mimosa.model.BaseProcessConfig
	 
	 properties(Constant)
	 end
	 
	 properties(SetAccess = protected)
	 end

	 % -------------------------------------------------------
	 % Public methods
	 % -------------------------------------------------------
	 
	 methods
		  
		  % Constructor
		  function this = DriftCorrectorConfig( )
				this@biotracs.mimosa.model.BaseProcessConfig( );
				this.setDescription('Configuration of the feature selection instrument');
            
                this.createParam('IntraBatchCorrection', false, ...
                    'Constraint', biotracs.core.constraint.IsBoolean() ...
                    );
                this.createParam('InterBatchCorrection', false, ...
                    'Constraint', biotracs.core.constraint.IsBoolean()...
                    );
                this.createParam('NbFirstQcToIgnore', 0, ...
                    'Constraint',  biotracs.core.constraint.IsPositive() ...
                    );
                this.createParam('NameQcToIgnore', {}...
                    );
                this.createParam('LoQ', 0, ...
                    'Constraint',  biotracs.core.constraint.IsPositive()...
                    );
                this.createParam('CorrectionModel', 'linear', ...
                    'Constraint',  biotracs.core.constraint.IsInSet({'linear','lowess'})...
                    );
                this.createParam('RemoveUndetectedFeatures', false, ...
                    'Constraint',  biotracs.core.constraint.IsBoolean()...
                    );
%                 this.createParam('NbComponentsPerEffect', 1, ...
%                     'Constraint', biotracs.core.constraint.IsPositive(), ...
%                     'Description', 'Number of component per effect to use' );
%                this.createParam( 'ReferenceGroups', '', ...
%                    'Constraint', biotracs.core.constraint.IsText('IsScalar', false), ...
%                    'Description', 'Name of the effect to filter from samples' );
                this.createParam( 'CorrectionMethod', 'CenterReduced', ...
                   'Constraint', biotracs.core.constraint.IsInSet({'CenterReduced', 'Quantile'}), ...
                   'Description', 'Method to perform the drift correction between batches' );
          end
		  
		  
	 end
	 
	 % -------------------------------------------------------
	 % Protected methods
	 % -------------------------------------------------------
	 
	 methods(Access = protected)
	 end

end
