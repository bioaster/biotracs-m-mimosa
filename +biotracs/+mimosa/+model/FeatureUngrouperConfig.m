% BIOASTER
%> @file 		FeatureUngrouperConfig.m
%> @class 		biotracs.mimosa.model.FeatureUngrouperConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018


classdef FeatureUngrouperConfig <  biotracs.mimosa.model.BaseProcessConfig
	 
	 properties(Constant)
	 end
	 
	 properties(SetAccess = protected)
	 end

	 % -------------------------------------------------------
	 % Public methods
	 % -------------------------------------------------------
	 
	 methods
		  
		  % Constructor
          function this = FeatureUngrouperConfig( )
              this@ biotracs.mimosa.model.BaseProcessConfig( );
              this.setDescription('Configuration for feature unGrouping');
              
               this.createParam('Direction', 'Column', ...
                    'Constraint', biotracs.core.constraint.IsInSet({'Column','Row'}), ...
                    'Description', 'The variables names to be ungrouped are on the row or column, (default: Coulmn)' ...
                    );
          end
		  
		  
	 end
	 
	 % -------------------------------------------------------
	 % Protected methods
	 % -------------------------------------------------------
	 
	 methods(Access = protected)
         
	 end

end
