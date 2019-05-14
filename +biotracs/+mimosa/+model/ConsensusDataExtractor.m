% BIOASTER
%> @file 		ConsensusDataExtractor.m
%> @class 		biotracs.mimosa.model.ConsensusDataExtractor
%> @link			http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date			2016

classdef ConsensusDataExtractor < biotracs.mimosa.model.BaseProcess
    
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
        function this = ConsensusDataExtractor()
            this@biotracs.mimosa.model.BaseProcess();
            this.configType = 'biotracs.mimosa.model.ConsensusDataExtractorConfig';
            this.setDescription('Algorithm for extracting the Consensus table');
            
            this.setInputSpecs({...
                struct(...
                'name', 'ExtDataTable',...
                'class', 'biotracs.mimosa.model.ConsensusExtDataTable' ...
                )...
                });
        end
        
    end
    
  
    
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function doBeforeRun( this )
            this.doBeforeRun@biotracs.mimosa.model.BaseProcess();
            if isempty(this.config.getParamValue('Polarity'))
                error('Please fill the parameter of polarity, Neg or Pos')
            end
        end
        
        function doRun( this )
            extDataTable = this.getInputPortData('ExtDataTable');
            [ consensusMatrix ] = this.doExtractConsensus( extDataTable );
            consensusMatrix.setLabel(extDataTable.getLabel());  
            this.setOutputPortData('FeatureSet', consensusMatrix);
        end

        function [oFeatureMatrix] = doExtractConsensus( this, extDataTable )
            map = extDataTable.get('MAP');
            mapNames = map.getDataByColumnName('filename');
            [~, prettyFileNames, ~] = cellfun(@fileparts,mapNames,'UniformOutput', false);
            consensus = extDataTable.get('CONSENSUS');
            mz = consensus.getDataByColumnName('^mz_cf$');
            rt = consensus.getDataByColumnName('^rt_cf$');
            rowNames = strcat(...
                'M', cellfun(@num2str, mz, 'UniformOutput', false),...
                '_', ...
                'T', cellfun(@num2str, rt, 'UniformOutput', false), ...
                '_', ...
                this.config.getParamValue('Polarity') ...
                );
            oFeatureTable = consensus.selectByColumnName('^intensity_\d+');
            oFeatureTable.setColumnNames(prettyFileNames);
            oFeatureTable.setRowNames(rowNames);            
            oFeatureMatrix = biotracs.spectra.data.model.MSFeatureSet.fromDataTable(oFeatureTable.transpose());
            params = this.config.getParamsAsCell();
            oFeatureMatrix.setRowNameKeyValPatterns( params{:} );
            oFeatureMatrix = replace(oFeatureMatrix, nan, 0);
        end
        
        
    end
    
    
end
