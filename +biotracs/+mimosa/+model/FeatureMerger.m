% BIOASTER
%> @file 		FeatureMerger.m
%> @class 		biotracs.mimosa.model.FeatureMerger
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date	    2017

classdef FeatureMerger < biotracs.mimosa.model.BaseProcess
    
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
        function this = FeatureMerger()
            %#function biotracs.mimosa.model.FeatureMergerConfig biotracs.spectra.data.model.MSFeatureSet
            
            this@biotracs.mimosa.model.BaseProcess();
            this.configType = 'biotracs.mimosa.model.FeatureMergerConfig';
            this.setDescription('Algorithm for feature modes merging');

            this.setInputSpecs({...
                struct(...
                'name', 'PosFeatureSet',...
                'class', 'biotracs.spectra.data.model.MSFeatureSet', ...
                'Required', true ...
                ),...
                struct(...
                'name', 'NegFeatureSet',...
                'class', 'biotracs.spectra.data.model.MSFeatureSet', ...
                'Required', true ...
                )...
                });

        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function doBeforeRun( this )
            this.doBeforeRun@biotracs.mimosa.model.BaseProcess()
%             hasOnlyNeg = this.getInputPort('NegFeatureSet').hasData() && ~this.getInputPort('PosFeatureSet').hasData();
%             hasOnlyPos = this.getInputPort('PosFeatureSet').hasData() && ~this.getInputPort('NegFeatureSet').hasData();
            hasOnlyNeg = ~this.getInputPortData('NegFeatureSet').hasEmptyData() && this.getInputPortData('PosFeatureSet').hasEmptyData();
            hasOnlyPos = ~this.getInputPortData('PosFeatureSet').hasEmptyData() && this.getInputPortData('NegFeatureSet').hasEmptyData();
           

            if hasOnlyNeg || hasOnlyPos
                disp('coucou')
                this.setIsPhantom( true );
            end
        end
        
        function doRun( this )

            if isempty( this.config.getParamValue('AnnotationNamesForMerging'))
                error('Define the annotation which will be kept for the merging')
            end
            
            posFeatureSet = this.getInputPortData('PosFeatureSet');
            negFeatureSet = this.getInputPortData('NegFeatureSet');
            [ mergedMatrix] = this.doMerge( posFeatureSet,  negFeatureSet);
            
            mergedMatrix.setLabel(posFeatureSet.getLabel());
            this.setOutputPortData('FeatureSet', mergedMatrix);
            
        end

        function doPass( this )

            posFeatureSet = this.getInputPortData('PosFeatureSet');
            negFeatureSet = this.getInputPortData('NegFeatureSet');
            
%             if( this.getInputPort('NegFeatureSet').hasData() && ~this.getInputPort('PosFeatureSet').hasData() )
%                 this.setOutputPortData('FeatureSet', negFeatureSet);
%             elseif( this.getInputPort('PosFeatureSet').hasData() && ~this.getInputPort('NegFeatureSet').hasData() )
%                 this.setOutputPortData('FeatureSet', posFeatureSet);
%             end
            
            if ( ~this.getInputPortData('NegFeatureSet').hasEmptyData() && this.getInputPortData('PosFeatureSet').hasEmptyData() )
                this.setOutputPortData('FeatureSet', negFeatureSet);
            elseif( ~this.getInputPortData('PosFeatureSet').hasEmptyData() && this.getInputPortData('NegFeatureSet').hasEmptyData() )
                this.setOutputPortData('FeatureSet', posFeatureSet);
            end
        end
        
        function [ outputMergedMatrix ] = doMerge (this, posFeatureSet, negFeatureSet)

            posPattern = posFeatureSet.getRowNameKeyValPatterns();
            negPattern = negFeatureSet.getRowNameKeyValPatterns();
            posFeatureSet = posFeatureSet.selectByRowName(posPattern.SamplePattern);
            negFeatureSet = negFeatureSet.selectByRowName(negPattern.SamplePattern);
            namesToKeep = this.config.getParamValue('AnnotationNamesForMerging');

            
            % PosFeatureSet
            splitRowNames = cellfun(@(x) strsplit(x, '_'), posFeatureSet.rowNames, 'UniformOutput', false);
            rowNameChoice = cellfun(@(x)  x(contains(x, namesToKeep)), splitRowNames, 'UniformOutput', false);
            newRowNames = cellfun(@(x)  strjoin(x, '_'), rowNameChoice, 'UniformOutput', false);
 
            if ~contains(posFeatureSet.columnNames,'_Pos')
                error('The column names of the featureSet have to contain the polarity');
            end

            posFeatureSet.setRowNames( newRowNames );

            splitRowNames = cellfun(@(x) strsplit(x, '_'), negFeatureSet.rowNames, 'UniformOutput', false);
            rowNameChoice = cellfun(@(x)  x(contains(x, namesToKeep)), splitRowNames, 'UniformOutput', false);
            newRowNames = cellfun(@(x)  strjoin(x, '_'), rowNameChoice, 'UniformOutput', false);
            
            
            if ~contains(negFeatureSet.columnNames,'_Neg')
                error('The column names of the featureSet have to contain the polarity');
            end

            negFeatureSet.setRowNames( newRowNames );
            
            % Merge
            outputMergedMatrix = horzmerge(...
                posFeatureSet.selectByRowName(posFeatureSet.getRowNameKeyValPatterns().SamplePattern), ...
                negFeatureSet.selectByRowName(negFeatureSet.getRowNameKeyValPatterns().SamplePattern), ...
                'Force', true);            
        end
        
        
    end
    
    
end
