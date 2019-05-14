% BIOASTER
%> @file 		FeatureMergerConfig.m
%> @class 		biotracs.mimosa.model.FeatureMergerConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017


classdef FeatureMergerConfig <  biotracs.mimosa.model.BaseProcessConfig
	 
	 properties(Constant)
	 end
	 
	 properties(SetAccess = protected)
	 end

	 % -------------------------------------------------------
	 % Public methods
	 % -------------------------------------------------------
	 
	 methods
		  
		  % Constructor
          function this = FeatureMergerConfig( )
              this@ biotracs.mimosa.model.BaseProcessConfig( );
              this.setDescription('Configuration for feature merging');
              
              this.createParam('AnnotationNamesForMerging', {}, ...
                  'Description', 'Names of the annotation to keep for merging the pos and neg batches');
          end
 
	 end
	 
	 % -------------------------------------------------------
	 % Protected methods
	 % -------------------------------------------------------
	 
	 methods(Access = protected)
	 end

end
