% BIOASTER
%> @file 		FeatureGrouper.m
%> @class 		biotracs.msproessing.model.FeatureGrouper
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date	    2017

classdef FeatureGrouper < biotracs.mimosa.model.BaseProcess
    
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
        function this = FeatureGrouper()
            this@biotracs.mimosa.model.BaseProcess();
            this.configType = 'biotracs.mimosa.model.FeatureGrouperConfig';
            this.setDescription('Algorithm for feature grouping');

            this.addOutputSpecs({...
                struct(...
                'name', 'IsoFeatureSet',...
                'class', 'biotracs.spectra.data.model.MSFeatureSet' ...
                ),...
                struct(...
                'name', 'AdductFeatureSet',...
                'class', 'biotracs.spectra.data.model.MSFeatureSet' ...
                ),...
                struct(...
                'name', 'AdductMatrix',...
                'class', 'biotracs.data.model.DataMatrix' ...
                )...
                });
        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function doRun( this )
            dataSet = this.getInputPortData('FeatureSet');
            [ calculator ] = biotracs.mimosa.helper.AdductCalculator( dataSet );
            [ adductFeatureSet, reducedIsoFeatureMatrix, reducedAdductMatrix ] = this.doAdductGrouping( calculator );
            adductFeatureSet.setLabel(dataSet.getLabel());
            this.setOutputPortData('AdductMatrix', adductFeatureSet);
            this.setOutputPortData('IsoFeatureSet', reducedIsoFeatureMatrix);
            this.setOutputPortData('AdductFeatureSet', reducedAdductMatrix);
        end

        function [adductMatrix, reducedIsoFeatureMatrix, reducedAdductMatrix] = doAdductGrouping( ~, calculator )
            adductMatrix = calculator.adductMatrix();
            nbAdducts =  sum( sum(adductMatrix.data == 3) >= 1 );
            nbIsoFeatures=  sum( sum(adductMatrix.data == 1) >= 1 );
            nbAdductsFeatures= sum( sum(adductMatrix.data == 2) >= 1 );
            fprintf(' > number of redundants = %d\n', nbAdducts);
            fprintf(' > number of isofeatures = %d\n', nbIsoFeatures);
            fprintf(' > number of adducts = %d\n', nbAdductsFeatures);
            [ reducedIsoFeatureMatrix, ~ ] = calculator.reduceTrainingSetUsingIsofeatureMap( );
            [ reducedAdductMatrix, ~ ] = calculator.reduceTrainingSetUsingAdductMap( );
        end

    end
    
    
end
