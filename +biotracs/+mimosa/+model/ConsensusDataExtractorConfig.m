% BIOASTER
%> @file 		ConsensusDataExtractorConfig.m
%> @class 		biotracs.mimosa.model.ConsensusDataExtractorConfig
%> @link			http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2016


classdef ConsensusDataExtractorConfig <  biotracs.mimosa.model.BaseProcessConfig
	 
	 properties(Constant)
	 end
	 
	 properties(SetAccess = protected)
	 end

	 % -------------------------------------------------------
	 % Public methods
	 % -------------------------------------------------------
	 
	 methods
		  
		  % Constructor
          function this = ConsensusDataExtractorConfig( )
              this@ biotracs.mimosa.model.BaseProcessConfig( );
              this.setDescription('Configuration for extracting consensus feature');
              this.createParam('BatchPattern', 'Batch:([^_]*)', 'Constraint',  biotracs.core.constraint.IsText());
              this.createParam('QcPattern', 'SampleType:QC', 'Constraint',  biotracs.core.constraint.IsText());
              this.createParam('SamplePattern', 'SampleType:Sample', 'Constraint',  biotracs.core.constraint.IsText());
              this.createParam('SequenceNumberPattern', 'SequenceNumber:([^_]*)', 'Constraint',  biotracs.core.constraint.IsText());
              this.createParam('Polarity', '',...
                  'Constraint',  biotracs.core.constraint.IsInSet({'Pos', 'Neg'}), ...
                  'Description', 'Indicate the polarity of the injected samples (Pos or Neg)');

          end
		  
	 end
	 
	 % -------------------------------------------------------
	 % Protected methods
	 % -------------------------------------------------------
	 
	 methods(Access = protected)
	 end

end
