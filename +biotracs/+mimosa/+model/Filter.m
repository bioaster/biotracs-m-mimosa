% BIOASTER
%> @file 		Filter.m
%> @class 		biotracs.mimosa.model.Filter
%> @link			http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date			2016

classdef Filter < biotracs.mimosa.model.BaseProcess
    
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
        function this = Filter()
            this@biotracs.mimosa.model.BaseProcess();
            this.setDescription('Algorithm for filtering a FeatureSet');
            
            this.addOutputSpecs({...
                struct(...
                'name', 'QcCvDataMatrix',...
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
            featureSet = this.getInputPortData('FeatureSet');
            
            [ filteredFeatureSet ] = doIntensityBlankFilter(this,  featureSet );
            [ filteredFeatureSet ] = doPercRuleFilter( this, filteredFeatureSet );
            QcCvThreshold = this.config.getParamValue('QcCvThreshold');
            if ~isempty(QcCvThreshold) && QcCvThreshold < Inf
                [ filteredFeatureSet, qcCvDm ] = doQcCvFilter( this, filteredFeatureSet );      
%                 this.setOutputPortData('FeatureSet', filteredFeatureSet);
                this.setOutputPortData('QcCvDataMatrix', qcCvDm);
            end
            this.setOutputPortData('FeatureSet', filteredFeatureSet);

        end
        
        function [ filteredFeatureSet, qcCvDm ] = doQcCvFilter( this, iFeatureSet )
            
            [ iQcFeatureSetContainer, ~  ] = iFeatureSet.split(); %, this.config );
            QcCvThreshold = this.config.getParamValue('QcCvThreshold');
            
            [~,nbFeatures] = getSize(iFeatureSet);
            
            %Apply CV threshold
            nbBatches = getLength(iQcFeatureSetContainer);
            indexesOfFeatruesStableInQcs = true(1,nbFeatures);
            if nbBatches <= 2
                if ~isempty(QcCvThreshold) && QcCvThreshold < Inf
                    fprintf( '\nFilter using a QC CV threshold of %1.1f\n. The CV must be inferior to the threhold in both batches', QcCvThreshold );
                    qcCvDm = biotracs.data.model.DataMatrix(zeros(0,nbFeatures));

                    for i=1:nbBatches
                        qcFeatureSet = iQcFeatureSetContainer.getAt(i);
                        qcCvPerBatch = varcoef( qcFeatureSet );
                        isFeatureStableInThisBatch = (qcCvPerBatch.data <= QcCvThreshold);
                        indexesOfFeatruesStableInQcs = indexesOfFeatruesStableInQcs & isFeatureStableInThisBatch;     %AND
                        qcCvDm = vertcat(qcCvDm, qcCvPerBatch);

                    end
                    batches = 1:nbBatches;
                    rowNames = strtrim(cellstr(num2str(batches'))');
                    qcCvDm.setColumnNames(qcFeatureSet.getColumnNames);
                    qcCvDm.setRowNames(rowNames);
                    nbFeaturesRemaining = sum(indexesOfFeatruesStableInQcs);
                    fprintf(' > initial number of features: %d, final number of features %d.\n > data is be reduced by %1.1f%%\n', nbFeatures ,nbFeaturesRemaining, 100*(nbFeatures-nbFeaturesRemaining)/nbFeatures);
                    filteredFeatureSet = iFeatureSet.selectByColumnIndexes(indexesOfFeatruesStableInQcs);
                else
                    filteredFeatureSet = iFeatureSet.copy();
                    %filteredFeatureSet = iFeatureSet.copy('IgnoreProcess', true);
                end
            else
                if ~isempty(QcCvThreshold) && QcCvThreshold < Inf
                    fprintf( '\nFilter using a QC CV threshold of %1.1f\n. The median of the CV of each feature in each Batch is calculated and must be inferior to the thershold', QcCvThreshold );
                    
                    qcCvDm = biotracs.data.model.DataMatrix(zeros(0,nbFeatures));
                    for i=1:nbBatches
                        qcFeatureSet = iQcFeatureSetContainer.getAt(i);
                        qcCvPerBatch = varcoef( qcFeatureSet );
                        qcCvDm = vertcat(qcCvDm, qcCvPerBatch);
                    end
                    rowNames = strtrim(cellstr(num2str([1:nbBatches]'))');
                    qcCvDm.setColumnNames(qcFeatureSet.getColumnNames);
                    qcCvDm.setRowNames(rowNames);
                   
                    qcCv = median(qcCvDm.data);
                    indexesOfFeatruesStableInQcs = qcCv <= QcCvThreshold;
                    nbFeaturesRemaining = sum(indexesOfFeatruesStableInQcs);
                    fprintf(' > initial number of features: %d, final number of features %d.\n > data is be reduced by %1.1f%%\n', nbFeatures ,nbFeaturesRemaining, 100*(nbFeatures-nbFeaturesRemaining)/nbFeatures);
                    filteredFeatureSet = iFeatureSet.selectByColumnIndexes(indexesOfFeatruesStableInQcs);
                    
                else
                    filteredFeatureSet = iFeatureSet.copy();
                    qcCvDm = biotracs.data.model.DataMatrix();
                end
            end
        end
        
        function [ indexesOfDetectedInThisGroup ] = doFilterByPercentageRule( ~, featureSet, pattern, limitOfQuantitation, percentageRuleThreshold )
            groupDataSet = featureSet.selectByRowName({'pattern' ,pattern} );
            indexesOfDetected = groupDataSet.data > limitOfQuantitation;
            [nbGroups,~] = getSize(groupDataSet);
            nbOfDetected = sum(indexesOfDetected);
            percentageOfDetected = nbOfDetected/nbGroups;
            indexesOfDetectedInThisGroup = percentageOfDetected >= percentageRuleThreshold;
        end
        
        function [ filteredFeatureSet ] = doPercRuleFilter( this, iFeatureSet )
            
            percentageRuleThreshold = this.config.getParamValue('PercentageRuleThreshold');
            sampleGroupList = this.config.getParamValue('GroupList');
            methodOfFiltering =  this.config.getParamValue('MethodOfFiltering');
            limitOfQuantitation = this.config.getParamValue('LoQ');
            [ iQcFeatureSetContainer, iSampleFeatureSetContainer ] = iFeatureSet.split(); %, this.config );
            [~,nbFeatures] = getSize(iFeatureSet);
            nbBatches = getLength(iSampleFeatureSetContainer);
            
            indexesOfFeaturesDetectedInAllGroupsAndBatches = true(1,nbFeatures);
            
            if ~isempty(percentageRuleThreshold) && percentageRuleThreshold > 0
                if isempty(iQcFeatureSetContainer.elements)
                    for i=1:nbBatches
                        indexesOfFeaturesDetectedInAtLeastOneGroup = false(1,nbFeatures);
                        indexesOfFeaturesDetectedInAllGroups = true(1,nbFeatures);
                        fprintf( '\nFilter using the percentage rule with a threhold of %1.0f%% in groups {''%s''}\n', 100*percentageRuleThreshold, strjoin(sampleGroupList,''',''') );
                        
                        %apply on Sample groups
                        for j=1:length(sampleGroupList)
                            
                            pattern  = sampleGroupList{j};
                            if ~contains(pattern, ':')
                                error('The GroupList is not valid, use SampleType:QC for e.g.')
                            end
                            
                            sampleFeatureSet = iSampleFeatureSetContainer.getAt(i);
                            indexesOfDetectedInThisGroup = this.doFilterByPercentageRule( sampleFeatureSet, pattern, limitOfQuantitation, percentageRuleThreshold);
                            indexesOfFeaturesDetectedInAtLeastOneGroup = indexesOfFeaturesDetectedInAtLeastOneGroup | indexesOfDetectedInThisGroup;	 %OR
                            
                            %At least one sample
                            indexesOfFeaturesDetectedInAllGroups = indexesOfFeaturesDetectedInAtLeastOneGroup;
                            
                        end
                    end
                    indexesOfFeaturesDetectedInAllGroupsAndBatches = indexesOfFeaturesDetectedInAllGroupsAndBatches & indexesOfFeaturesDetectedInAllGroups;
                    
                    
                    nbFeaturesRemaining = sum(indexesOfFeaturesDetectedInAllGroupsAndBatches);
                    fprintf(' > initial number of features: %d, final number of features %d.\n > data is be reduced by %1.1f%%\n', nbFeatures ,nbFeaturesRemaining, 100*(nbFeatures-nbFeaturesRemaining)/nbFeatures);
                    
                else
                    %Apply 80 % on QCs
                    for i=1:nbBatches
                        qcFeatureSet = iQcFeatureSetContainer.getAt(i);
                        indexesOfDetectedInQcs = this.doFilterByPercentageRule(qcFeatureSet, '.*' , limitOfQuantitation, percentageRuleThreshold);
                        if strcmp(methodOfFiltering, 'QcOnly')
                            indexesOfFeaturesDetectedInAllGroups = indexesOfDetectedInQcs;
                        else
                            indexesOfFeaturesDetectedInAtLeastOneGroup = false(1,nbFeatures);
                            indexesOfFeaturesDetectedInAllGroups = true(1,nbFeatures);
                            fprintf( '\nFilter using the percentage rule with a threhold of %1.0f%% in groups {''%s''}\n', 100*percentageRuleThreshold, strjoin(sampleGroupList,''',''') );
                            
                            %apply on Sample groups
                            for j=1:length(sampleGroupList)
                                pattern  = sampleGroupList{j};
                                sampleFeatureSet = iSampleFeatureSetContainer.getAt(i);
                                indexesOfDetectedInThisGroup = this.doFilterByPercentageRule( sampleFeatureSet, pattern, limitOfQuantitation, percentageRuleThreshold);
                                indexesOfFeaturesDetectedInAtLeastOneGroup = indexesOfFeaturesDetectedInAtLeastOneGroup | indexesOfDetectedInThisGroup;	 %OR
                                if strcmp(methodOfFiltering, 'QcAndSample')
                                    %QC AND At least one sample(Or Sample)
                                    indexesOfFeaturesDetectedInAllGroups = indexesOfDetectedInQcs & indexesOfFeaturesDetectedInAtLeastOneGroup;
                                else
                                    %QC OR At least one sample(Or Sample)
                                    indexesOfFeaturesDetectedInAllGroups = indexesOfDetectedInQcs | indexesOfFeaturesDetectedInAtLeastOneGroup;
                                end
                            end
                        end
                        indexesOfFeaturesDetectedInAllGroupsAndBatches = indexesOfFeaturesDetectedInAllGroupsAndBatches & indexesOfFeaturesDetectedInAllGroups;
                    end
                    
                    nbFeaturesRemaining = sum(indexesOfFeaturesDetectedInAllGroupsAndBatches);
                    fprintf(' > initial number of features: %d, final number of features %d.\n > data is be reduced by %1.1f%%\n', nbFeatures ,nbFeaturesRemaining, 100*(nbFeatures-nbFeaturesRemaining)/nbFeatures);
                end
            end
            filteredFeatureSet = iFeatureSet.selectByColumnIndexes(indexesOfFeaturesDetectedInAllGroupsAndBatches);
            
        end
        
        
        
        function [ filteredFeatureSet ] = doIntensityBlankFilter( this, iFeatureSet )
            blankIntensityThreshold = this.config.getParamValue('BlankIntensityRatio');
            if isempty(blankIntensityThreshold)
                filteredFeatureSet= iFeatureSet.copy();
            else
                blankFeature = iFeatureSet.selectByRowName('SampleType:Blank');
                
                qcSampleFeature = iFeatureSet.removeByRowName('SampleType:Blank');
                intMeanFeatureInBlank = blankFeature.mean();
                intMeanFeatureInQcSample = qcSampleFeature.mean();
                [~,n1] = getSize(iFeatureSet);
                
                if ~isempty(blankIntensityThreshold) && blankIntensityThreshold < Inf
                    fprintf( '\nFiltering the Features presnt in Blank using a threshold of %1.1f\n', blankIntensityThreshold );
                    isFeatureNotPresentInBlank = (intMeanFeatureInQcSample.data >= blankIntensityThreshold * intMeanFeatureInBlank.data);
                    n2 = sum(isFeatureNotPresentInBlank);
                    fprintf(' > initial number of features: %d, final number of features %d.\n > data is be reduced by %1.1f%%\n', n1 ,n2, 100*(n1-n2)/n1);
                    filteredFeatureSet = iFeatureSet.selectByColumnIndexes(isFeatureNotPresentInBlank);
                else
                    filteredFeatureSet = iFeatureSet;
                end
            end
        end
        
    end
end
