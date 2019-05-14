% BIOASTER
%> @file 		MultiplicationFactor.m
%> @class 		biotracs.mimosa.model.MultiplicationFactor
%> @link			http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date			2016

classdef MultiplicationFactor < biotracs.mimosa.model.BaseProcess
    
    properties(Constant)
    end
    
    properties(Dependent)
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = MultiplicationFactor()
             this@biotracs.mimosa.model.BaseProcess();
             this.configType = 'biotracs.mimosa.model.MultiplicationFactorConfig';
             this.setDescription('Algorithm for normalizing the data by a factor of multiplication');
        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function doBeforeRun( this )
            this.doBeforeRun@biotracs.mimosa.model.BaseProcess();
            columnName = this.config.getParamValue('ColumnName');
            this.setIsPhantom(isempty(columnName))
        end
        
        function doRun( this )
            trainingSet = this.getInputPortData('FeatureSet');
            [ normalizedFeatureSet ] = this.doMultiplication( trainingSet ); 
            
            normalizedFeatureSet.setLabel(trainingSet.getLabel());
            this.setOutputPortData('FeatureSet', normalizedFeatureSet);
        end

        function [oTrainingSet] = doMultiplication( this, iTrainingSet )
            oTrainingSet = iTrainingSet.copy().discardProcess();
            columnName = this.config.getParamValue('ColumnName');
            fprintf('\nPerform normalization by a multiplicative factor');
              
            for j = 1:length(oTrainingSet.rowNames)
                f = regexprep(oTrainingSet.rowNames{j}, strcat('.*',columnName,':([^_]*).*'), '$1');
                
                factor{j} = f;
            end
          
            factors = transpose(cellfun(@str2double,factor));
            if any(isnan(factors))
                error('BIOAPPS:MultiplicationFactor:InvalidFactors','Some samples have not a value and are NaN values. Please check the values in the metaData');
            end
            normalizedData = oTrainingSet.data.* factors;
            oTrainingSet.setData(normalizedData, false);


        end
        
    end
    
    
end