% BIOASTER
%> @file 		MultiplicationFactorConfig.m
%> @class 		biotracs.mimosa.model.MultiplicationFactorConfig
%> @link			http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2016


classdef MultiplicationFactorConfig <  biotracs.mimosa.model.BaseProcessConfig
	 
	 properties(Constant)
	 end
	 
	 properties(SetAccess = protected)
	 end

	 % -------------------------------------------------------
	 % Public methods
	 % -------------------------------------------------------
	 
	 methods
		  
		  % Constructor
          function this = MultiplicationFactorConfig( )
              this@ biotracs.mimosa.model.BaseProcessConfig( );
              this.setDescription('Configuration for multiplicative factor');
              this.createParam('ColumnName', '', ...
                  'Constraint',  biotracs.core.constraint.IsText(), ...
                  'Description', 'Define the name of the comluimn in the metadata which contains the multiplicative factor to be used per ligne of the featureSet' ...
                  );
%               this.createParam('GapFillingMultiplier', 0.1, ...
%                   'Constraint',  biotracs.core.constraint.IsBetween([0,1]), ...
%                   'Description', '' ...
%                   );
          end
		  
		  
	 end
	 
	 % -------------------------------------------------------
	 % Protected methods
	 % -------------------------------------------------------
	 
	 methods(Access = protected)
	 end

end
