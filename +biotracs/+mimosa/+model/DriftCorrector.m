% BIOASTER
%> @file 		DriftCorrector.m
%> @class 		biotracs.mimosa.model.DriftCorrector
%> @link			http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date			2016

classdef DriftCorrector < biotracs.mimosa.model.BaseProcess
    
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
        function this = DriftCorrector()
            this@biotracs.mimosa.model.BaseProcess();
            this.setDescription('Algorithms for inter and intra-batch analytical drift correction.');
            
            e = biotracs.atlas.model.EffectRemover();
            this.bindEngine( e, 'EffectRemover' );
        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function doRun( this )
            originalFeatureSet = this.getInputPortData('FeatureSet');
            if hasEmptyData(originalFeatureSet)
                error('BIOAPPS:DriftCorrector:EmptyData', 'The FeatureSet has empty data');
            end

            [ qcFeatureSetContainer, sampleFeatureSetContainer, otherFeatureSetContainer  ] = originalFeatureSet.split();
            % merge sampleFeatureSetContainer & otherFeatureSetContainer
            for i=1:length(sampleFeatureSetContainer)
                set1 = sampleFeatureSetContainer.getAt(i);
                set2 = otherFeatureSetContainer.getAt(i);     
                mergedSet = vertmerge(set1, set2);
                sampleFeatureSetContainer.setAt(i, mergedSet);
            end
            
            if this.config.getParamValue('IntraBatchCorrection')
                [ sampleFeatureSetContainer, qcFeatureSetContainer ] = this.correctIntraBatchDrift( sampleFeatureSetContainer, qcFeatureSetContainer );
                correctedFeatureSet = vertmerge( ...
                    sampleFeatureSetContainer.elements{:}, ...
                    qcFeatureSetContainer.elements{:} ...
                    );
                
                correctedFeatureSet.setLabel(originalFeatureSet.getLabel());
                this.setOutputPortData('FeatureSet', correctedFeatureSet);
            end
            
            if this.config.getParamValue('InterBatchCorrection')
                [ sampleFeatureSetContainer, qcFeatureSetContainer ] = this.correctInterBatchDrift( sampleFeatureSetContainer, qcFeatureSetContainer );
                correctedFeatureSet = vertmerge( ...
                    sampleFeatureSetContainer.elements{:}, ...
                    qcFeatureSetContainer.elements{:} ...
                    );
                
                correctedFeatureSet.setLabel(originalFeatureSet.getLabel());
                this.setOutputPortData('FeatureSet', correctedFeatureSet);
            end
            
        end
        
        function [ oSampleFeatureSetContainer, oQcFeatureSetContainer ] = correctIntraBatchDrift( this, iSampleFeatureSetContainer, iQcFeatureSetContainer )
            oQcFeatureSetContainer = biotracs.core.mvc.model.ResourceSet();
            oSampleFeatureSetContainer = biotracs.core.mvc.model.ResourceSet();
            LoQ = this.config.getParamValue('LoQ');
            correctionModel = this.config.getParamValue('CorrectionModel');
            nbBatches = getLength(iQcFeatureSetContainer);
            undetectedFeatureIndexes = zeros(0,1);

            if LoQ == 0
                warning('No LoQ value is provided. This may result in invalid intra-batch drift corrections');
            end
            
            for batchIndex=1:nbBatches
                qcFeatureSet = iQcFeatureSetContainer.getAt(batchIndex);
                sampleFeatureSet = iSampleFeatureSetContainer.getAt(batchIndex);
                someValueAreEqualToZeroInQcs = sum(sum(qcFeatureSet.data == 0)) > 0;
                if someValueAreEqualToZeroInQcs
                    error('BIOAPPS:DriftCorrectot:DataNotGapFilled','Some features are zeros in QC %d. Please perform gap filling before drift correction', batchIndex);
                end
                
                if hasEmptyData(qcFeatureSet)
                    break;
                end
                
                [qcSeqNum] = qcFeatureSet.getSequenceNumbers();
                if any(isnan(qcSeqNum))
                    error('BIOAPPS:DriftCorrectot:InvalidSequenceNumbers','Some sequence numbers of the FeatureSet are NaN values. Please check rowNameKeyValPatterns in meta');
                end
                
                [qcSeqNum, idx] = sort(qcSeqNum);
                qcFeatureSet = qcFeatureSet.selectByRowIndexes( idx );
                
                [sampleSeqNum] = sampleFeatureSet.getSequenceNumbers();
                [sampleSeqNum, idx] = sort(sampleSeqNum);
                sampleFeatureSet = sampleFeatureSet.selectByRowIndexes( idx );
                
                %correction
                correctedQcData = zeros( size(qcFeatureSet.data) );
                correctedSampleData = zeros( size(sampleFeatureSet.data) );
                [nbQcs, nbFeatures] = getSize( qcFeatureSet );
                [nbSamples, ~] = getSize( sampleFeatureSet );
                %build interplotation sampling
                fullSeqNum =  sort([qcSeqNum,sampleSeqNum])';
                areSeqNumUnique = all(diff(fullSeqNum));
                if( ~areSeqNumUnique )
                    error('BIOAPPS:DriftCorrectot:InvalidSequenceNumbers','Acquisition sequence numbers must be unique.');
                end
                
                %allocate undetectedFeatureIndexes here
                if isempty(undetectedFeatureIndexes)
                    undetectedFeatureIndexes = false(1,nbFeatures);
                end
                
                for featureIdx = 1:nbFeatures
                    X = qcSeqNum;
                    y = qcFeatureSet.data(:,featureIdx);
                    
                    nbDetected = sum(y > LoQ);
                    isSignificantlyDetectedInAllQcs = (nbDetected == nbQcs);
                    isSignificantlyDetectedInAlmostAllQcs = (nbDetected >= 0.7*nbQcs);
                    if isSignificantlyDetectedInAllQcs
                        %Ok !
                    elseif isSignificantlyDetectedInAlmostAllQcs
                        %Only replace missing values by the mean value of this
                        %feature
                        indexesOfUndetected = y <= LoQ;
                        y( indexesOfUndetected ) = mean( y(~indexesOfUndetected)   );
                    else
                        %QC values are not reliable for this feature
                        %Replace all values by the mean value of all
                        %features
                        meanQcFeatureSet = mean(qcFeatureSet,'direction', 'row');
                        y = meanQcFeatureSet.data;
                        undetectedFeatureIndexes(featureIdx) = true;
                    end
                    
                    if strcmpi(correctionModel,'linear')
                        qcMdl = fitlm(X,y);
                        [Ypred] = predict(qcMdl,fullSeqNum);
                    else
                        [Ypred] = biotracs.math.lowess(X, y, 1, fullSeqNum);
                    end
                    
                    xf = qcSeqNum(end);
                    refQcPred = mean(Ypred(fullSeqNum == xf));
                    
                    %correct QC drifts at position featureIdx
                    for i=1:nbQcs
                        xi = qcSeqNum(i);
                        idx = (fullSeqNum == xi);
                        qcPred = Ypred( idx );
                        ratio = refQcPred / qcPred;
                        correctedQcData(i,featureIdx) = ratio * qcFeatureSet.data(i,featureIdx);
                    end
                    
                    %correct sample drifts at position featureIdx
                    for i=1:nbSamples
                        xi = sampleSeqNum(i);
                        idx = (fullSeqNum == xi);
                        samplePred = Ypred( idx );
                        ratio = refQcPred / samplePred;
                        correctedSampleData(i,featureIdx) = ratio * sampleFeatureSet.data(i,featureIdx);
                    end
                end
                
                name = iQcFeatureSetContainer.getElementName(batchIndex);
                correctedQcData( correctedQcData < 0 ) = LoQ*rand() / 10;
                qcFeatureSet.setData( correctedQcData, false );
                oQcFeatureSetContainer.set(name, qcFeatureSet);
                
                name = iSampleFeatureSetContainer.getElementName(batchIndex);
                correctedSampleData( correctedSampleData < 0 ) = LoQ*rand() / 10;
                sampleFeatureSet.setData( correctedSampleData, false );
                oSampleFeatureSetContainer.set(name, sampleFeatureSet);
            end
            
            if this.config.getParamValue('RemoveUndetectedFeatures') && any(undetectedFeatureIndexes)
                fprintf(...
                    '%d over %d features are undetected in at least one batch (%1.1f%% of features) and are removed after inter-drift correction', ...
                    sum(undetectedFeatureIndexes), ...
                    nbFeatures, ...
                    100*sum(undetectedFeatureIndexes)/nbFeatures...
                    );
                
                for batchIndex=1:nbBatches
                    dataMatrix = oQcFeatureSetContainer.getAt(batchIndex);
                    dataMatrix = dataMatrix.selectByColumnIndexes(~undetectedFeatureIndexes);
                    oQcFeatureSetContainer.setAt(batchIndex, dataMatrix);
                    
                    dataMatrix = oSampleFeatureSetContainer.getAt(batchIndex);
                    dataMatrix = dataMatrix.selectByColumnIndexes(~undetectedFeatureIndexes);
                    oSampleFeatureSetContainer.setAt(batchIndex, dataMatrix);
                end
            end
            
        end
        
        function [ oSampleFeatureSetContainer, oQcFeatureSetContainer ] = correctInterBatchDrift( this, iSampleFeatureSetContainer, iQcFeatureSetContainer )
            oQcFeatureSetContainer = biotracs.core.mvc.model.ResourceSet();
            oSampleFeatureSetContainer = biotracs.core.mvc.model.ResourceSet();
            nbBatches = getLength(iQcFeatureSetContainer);
            LoQ = this.config.getParamValue('LoQ');
            
            %Compute reference batch
            refBatchIndex = 1;
            
            if strcmp(this.config.getParamValue('SamplesToUseForInterBatchCorrection'), 'All')
                refFeatureSet = vertmerge( iQcFeatureSetContainer.getAt(1), iSampleFeatureSetContainer.getAt(1) );
            elseif strcmp(this.config.getParamValue('SamplesToUseForInterBatchCorrection'), 'QCOnly')
                refFeatureSet = iQcFeatureSetContainer.getAt(1);
            elseif strcmp(this.config.getParamValue('SamplesToUseForInterBatchCorrection'), 'SamplesWithoutQC')
                refFeatureSet = iSampleFeatureSetContainer.getAt(1);
            end
            
            for batchIndex=2:nbBatches
                if strcmp(this.config.getParamValue('SamplesToUseForInterBatchCorrection'), 'All')
                    currentFeatureSet = vertmerge( iQcFeatureSetContainer.getAt(batchIndex), iSampleFeatureSetContainer.getAt(batchIndex) );
                elseif strcmp(this.config.getParamValue('SamplesToUseForInterBatchCorrection'), 'QCOnly')
                    currentFeatureSet = iQcFeatureSetContainer.getAt(batchIndex);
                elseif strcmp(this.config.getParamValue('SamplesToUseForInterBatchCorrection'), 'SamplesWithoutQC')
                    currentFeatureSet = iSampleFeatureSetContainer.getAt(batchIndex);
                end
                isAverageIntensityHigher = mean(mean(currentFeatureSet.data)) > mean(mean(refFeatureSet.data));
                if isAverageIntensityHigher
                    refBatchIndex = batchIndex;
                    refFeatureSet = currentFeatureSet;
                end
            end
            fprintf(' > the reference batch is %d\n', refBatchIndex);
            
            for batchIndex=1:nbBatches
                qcFeatureSet = iQcFeatureSetContainer.getAt(batchIndex);
                sampleFeatureSet = iSampleFeatureSetContainer.getAt(batchIndex);
                someValueAreEqualToZeroInQcs = sum(sum(qcFeatureSet.data == 0)) > 0;
                if someValueAreEqualToZeroInQcs
                    error('Some features are not detected in QC %d. Please perform gap filling before drift correction', batchIndex);
                end
                
                isRefBatch = isequal(refBatchIndex,batchIndex);
                isCorrectionNotNecessaryForThisBatch = (isRefBatch || nbBatches == 1);
                
                if isCorrectionNotNecessaryForThisBatch
                    oQcFeatureSetContainer.set(...
                        iQcFeatureSetContainer.getElementName(batchIndex), ...
                        qcFeatureSet);
                    
                    oSampleFeatureSetContainer.set(...
                        iSampleFeatureSetContainer.getElementName(batchIndex), ...
                        sampleFeatureSet);
                else
                    % If:
                    % 1) The correction is based on QCs => suppose that the
                    % QCs must have the same statistical properties in all
                    % batches
                    % 2) The correction is based on all the samples =>
                    % suppose that the samples distributions must have the
                    % same statistical properties in all batches. Than mean
                    % that data are well randomized
                    if strcmp(this.config.getParamValue('SamplesToUseForInterBatchCorrection'), 'All')
                        corrFeatureSet = vertmerge( iQcFeatureSetContainer.getAt(batchIndex), iSampleFeatureSetContainer.getAt(batchIndex) );
                    elseif strcmp(this.config.getParamValue('SamplesToUseForInterBatchCorrection'), 'QCOnly')
                        corrFeatureSet = iQcFeatureSetContainer.getAt(batchIndex);
                    elseif strcmp(this.config.getParamValue('SamplesToUseForInterBatchCorrection'), 'SamplesWithoutQC')
                        corrFeatureSet = iSampleFeatureSetContainer.getAt(batchIndex);
                    end
                    
                    % Mean/Std-based correction
                    qcData = biotracs.math.centerscale(...
                        qcFeatureSet.data, ...
                        corrFeatureSet.data, ...
                        'Center', true, ...
                        'Scale', 'uv' ...
                        );
                    
                    % Mean/Std-based correction
                    sampleData = biotracs.math.centerscale(...
                        sampleFeatureSet.data, ...
                        corrFeatureSet.data, ...
                        'Center', true, ...
                        'Scale', 'uv' ...
                        );
                    
                    %Reverse scaling accoding to the reference QC
                    qcData = biotracs.math.reversecenterscale(...
                        qcData, ...
                        refFeatureSet.data, ...
                        'Center', true, ...
                        'Scale', 'uv' ...
                        );
                    
                    sampleData = biotracs.math.reversecenterscale(...
                        sampleData, ...
                        refFeatureSet.data, ...
                        'Center', true, ...
                        'Scale', 'uv' ...
                        );
                    
                    qcData( qcData < 0 ) = LoQ*rand() / 10;
                    sampleData( sampleData < 0 ) = LoQ*rand() / 10;
                    qcFeatureSet.setData(qcData, false);
                    sampleFeatureSet.setData(sampleData, false);
                    
                    oQcFeatureSetContainer.set(...
                        iQcFeatureSetContainer.getElementName(batchIndex), ...
                        qcFeatureSet);
                    
                    oSampleFeatureSetContainer.set(...
                        iSampleFeatureSetContainer.getElementName(batchIndex), ...
                        sampleFeatureSet);
                end
            end
        end
        
        
        function [ oSampleFeatureSetContainer, qcFeatureSetContainer ] = removeBatchEffect( this, iSampleFeatureSetContainer, qcFeatureSetContainer )
            e = this.getEngine('EffectRemover');
            e.setInputPortData('DataSet', iSampleFeatureSetContainer);
            e.config.updateParamValue('EffectsToRemove', {'Batch'});
            e.config.updateParamValue('ReferenceGroups', this.config.getParamValue('ReferenceGroups'));
            e.run();
            oSampleFeatureSetContainer = e.getOutputPortData('DataSet');
            oSampleFeatureSetContainer = biotracs.spectra.data.model.MSFeatureSet.fromDataSet(oSampleFeatureSetContainer);

        end
    end
    
    
end
