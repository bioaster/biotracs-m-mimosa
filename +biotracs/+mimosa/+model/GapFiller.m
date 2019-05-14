% BIOASTER
%> @file 		GapFiller.m
%> @class 		biotracs.mimosa.model.GapFiller
%> @link			http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date			2016

classdef GapFiller < biotracs.mimosa.model.BaseProcess
    
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
        function this = GapFiller()
             this@biotracs.mimosa.model.BaseProcess();
             this.configType = 'biotracs.mimosa.model.GapFillerConfig';
             this.setDescription('Algrithm for gap filling');
        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function doBeforeRun( this )
            this.doBeforeRun@biotracs.mimosa.model.BaseProcess();
            limitOfQuantitation = this.config.getParamValue('LoQ');
            if (limitOfQuantitation == 0)
                this.setIsPhantom( true)
            end
%             this.isPhantom = (limitOfQuantitation == 0);

        end
        
        function doRun( this )
            trainingSet = this.getInputPortData('FeatureSet');
            [ gapFilledFeatureSet ] = this.doFillGaps( trainingSet );  
            this.setOutputPortData('FeatureSet', gapFilledFeatureSet);
        end

        function [oTrainingSet] = doFillGaps( this, iTrainingSet )
            oTrainingSet = iTrainingSet.copy().discardProcess();
            limitOfQuantitation = this.config.getParamValue('LoQ');
            fprintf('\nPerform gap filling with value = %1.1e\n', limitOfQuantitation);
            indexesOfZeros = oTrainingSet.data <= limitOfQuantitation;
            
            [m,n] = size(indexesOfZeros);
            
            expectedMean = limitOfQuantitation * this.config.getParamValue('GapFillingMultiplier');
            expectedCV = 0.1;
            expectedStd = expectedMean * expectedCV;
            randValues = biotracs.math.rand(m, n, expectedMean, expectedStd);
            
            data = oTrainingSet.getData();
            data(indexesOfZeros) = data(indexesOfZeros) + randValues(indexesOfZeros);
            
            oTrainingSet.setData( data, false );
            nbFilled = sum(sum(indexesOfZeros));
            fprintf( ' > %d gaps filled (%1.2f%% of the feature matrix)\n', nbFilled, 100*nbFilled/(m*n) );
        end
        
    end
    
    
end
