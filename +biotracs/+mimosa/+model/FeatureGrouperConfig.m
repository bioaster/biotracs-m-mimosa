% BIOASTER
%> @file 		FeatureGrouperConfig.m
%> @class 		biotracs.mimosa.model.FeatureGrouperConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017


classdef FeatureGrouperConfig <  biotracs.mimosa.model.BaseProcessConfig
	 
	 properties(Constant)
	 end
	 
	 properties(SetAccess = protected)
	 end

	 % -------------------------------------------------------
	 % Public methods
	 % -------------------------------------------------------
	 
	 methods
		  
		  % Constructor
          function this = FeatureGrouperConfig( )
              this@ biotracs.mimosa.model.BaseProcessConfig( );
              this.setDescription('Configuration for feature grouping');
          end
		  
		  
	 end
	 
	 % -------------------------------------------------------
	 % Protected methods
	 % -------------------------------------------------------
	 
	 methods(Access = protected)
	 end

end
