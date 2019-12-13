% BIOASTER
%> @file 		FeatureSummary.m
%> @class 		biotracs.mimosa.model.FeatureSummary
%> @link			http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018

classdef FeatureSummary < biotracs.mimosa.model.BaseProcess
    
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
        function this = FeatureSummary()
            %#function biotracs.mimosa.model.FeatureSummaryConfig biotracs.spectra.data.model.MSFeatureSet biotracs.data.model.DataMatrix biotracs.data.model.DataTable biotracs.mimosa.model.FeatureSummaryResult
            
            this@biotracs.mimosa.model.BaseProcess();
            this.configType = 'biotracs.mimosa.model.FeatureSummaryConfig';
            this.setDescription('Algorithm for extracting the Consensus table');
%             this.bindView( biotracs.mimosa.view.FeatureSummary() );
            
            this.setInputSpecs({...
                struct(...
                'name', 'OriginalFeatureSet',...
                'class', 'biotracs.spectra.data.model.MSFeatureSet' ...
                ),...
                struct(...
                'name', 'QcCVPerBatch',...
                'class', 'biotracs.data.model.DataMatrix' ...
                ),struct(...
                'name', 'UngroupedFeaturesSelected',...
                'class', 'biotracs.data.model.DataTable' ...
                )...
                });
            
            this.setOutputSpecs({...
                struct(...
                'name', 'ResourceSet', ...
                'class', 'biotracs.mimosa.model.FeatureSummaryResult' ...
                ) ...
                });
        end
        
    end
    
  
    
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        
        function doRun( this )
            originalFeatureSet = this.getInputPortData('OriginalFeatureSet');
            qcCv = this.getInputPortData('QcCVPerBatch');
            listFeaturesSelected = this.getInputPortData('UngroupedFeaturesSelected');
            [ resourceSet ] = this.doFeatureSummary( originalFeatureSet,  qcCv, listFeaturesSelected);

            this.setOutputPortData('ResourceSet', resourceSet);

        end

        function [ resourceSet ] = doFeatureSummary( ~, originalFeatureSet,  qcCv, listFeaturesSelected )

            selectedFeatures = listFeaturesSelected.getRowNames;
            originalIntensities = originalFeatureSet.selectByColumnName(selectedFeatures);
            qcCvValues = qcCv.selectByColumnName(selectedFeatures);
            
            resourceSet = biotracs.mimosa.model.FeatureSummaryResult();
            resourceSet.set('intensities', originalIntensities);
            resourceSet.set('qcCvValues', qcCvValues);
            
        end
        
        
    end
    
    
end
