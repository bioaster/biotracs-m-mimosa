% BIOASTER
%> @file 		GapFillerConfig.m
%> @class 		biotracs.mimosa.model.GapFillerConfig
%> @link			http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2016


classdef GapFillerConfig <  biotracs.mimosa.model.BaseProcessConfig
	 
	 properties(Constant)
	 end
	 
	 properties(SetAccess = protected)
	 end

	 % -------------------------------------------------------
	 % Public methods
	 % -------------------------------------------------------
	 
	 methods
		  
		  % Constructor
          function this = GapFillerConfig( )
              this@ biotracs.mimosa.model.BaseProcessConfig( );
              this.setDescription('Configuration for filling gaps');
              this.createParam('LoQ', 0, ...
                  'Constraint',  biotracs.core.constraint.IsPositive(), ...
                  'Description', 'Define the limit of Quantitation of the intensites.' ...
                  );
              this.createParam('GapFillingMultiplier', 0.1, ...
                  'Constraint',  biotracs.core.constraint.IsBetween([0,1]), ...
                  'Description', '' ...
                  );
          end
		  
		  
	 end
	 
	 % -------------------------------------------------------
	 % Protected methods
	 % -------------------------------------------------------
	 
	 methods(Access = protected)
	 end

end
