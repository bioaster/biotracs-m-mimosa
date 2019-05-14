% BIOASTER
%> @file 		AdductCalculator.m
%> @class 		biotracs.mimosa.helper.AdductCalculator
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2016

classdef AdductCalculator < handle
    
    properties(Constant)
        POSITIVE_ADDUCT_LIST = biotracs.spectra.data.model.Compound.POSITIVE_ADDUCT_LIST;
        NEGATIVE_ADDUCT_LIST = biotracs.spectra.data.model.Compound.NEGATIVE_ADDUCT_LIST;
        REDUNDANCY_FLAG_VALUE = 1;
        ISOFEATURE_FLAG_VALUE = 2;
        ADDUCT_FLAG_VALUE = 3;
    end
    
    properties(SetAccess = protected)
        mzPpmError                 = 7;       %ppm
        maxRetentionTimeShift      = 10;       %sec
        redundancyCorrelation      = 0.80;
        linkIsofeatures = false;
        
        featureSet;
        redundancyMatrix;
        adductMatrix;
        adductPairsTable;
        adductMap;
        isofeatureMatrix;
        isofeatureMap;
    end
    
    methods(Access = public)
        %TODO: remove the data not used in calculator
        function this = AdductCalculator( iFeatureSet, varargin )
            p = inputParser();
            p.addParameter('LinkIsofeatures', false, @islogical);
            p.KeepUnmatched = true;
            p.parse( varargin{:} );
            
            this.linkIsofeatures = p.Results.LinkIsofeatures;
            
            this.featureSet = iFeatureSet;
            this.calculateRedundancyMatrix( varargin{:} );
            this.calculateIsofeatureMatrix( varargin{:} );
            this.calculateAdductMatrix( varargin{:} );
            this.createMapFromAdductMatrix( varargin{:}  );
            this.createMapFromIsofeatureMatrix( varargin{:} );
            
        end
        
        %-- C --
        
        %> @brief Compute the redundancy matrix R, i.e. the covariance matrix of
        %> the @a iTrainingSet. The redundancy flag is given by attribute
        %> @a REDUNDANCY_FLAG_VALUE, i.e. when features i and j are redundant
        %> then R(i,j) = @a REDUNDANCY_FLAG_VALUE
        %> @param[in, optional] varargin
        %> @return biotracs.data.model.DataMatrix the redundancy matrix
        function calculateRedundancyMatrix( this, varargin )
            fprintf('Calculate redundancy matrix...\n');
            corrMatrix = corr(this.featureSet);
            redundancyData = double(corrMatrix.data >= this.redundancyCorrelation);
            n = size(redundancyData,1);
            redundancyData(eye(n,'logical')) = 0;
            
            this.redundancyMatrix = biotracs.data.model.DataMatrix(...
                redundancyData, ...
                this.featureSet.getColumnNames(), ...
                this.featureSet.getColumnNames()...
                );
        end
        
        %> @brief Compute the isofeature matrix I. Features i and j are
        %> isofeature if they are redundant and the difference between
        %> their retention times is smaller than @a maxRetentionTimeShift.
        %> In this case I(i,j) = @a ISOFEATURE_FLAG_VALUE
        %> @param[in, optional] varargin
        %> @return the isofeature matrix (biotracs.data.model.DataMatrix)
        function calculateIsofeatureMatrix( this, varargin )
            fprintf('Calculate isofeature matrix...\n');
            %[ redundancyMatrix ] = this.calculateRedundancyMatrix( varargin{:} );
            [ ~, rtVector, ~ ] = this.retrieveFeatureInfoFromTrainingSet( );

            n = getSize( this.redundancyMatrix,1 );
            isofeatureData = this.redundancyMatrix.data;
            for i = 1:n
                for j = i+1:n
                    areRedundant = this.redundancyMatrix.data(i,j);
                    haveCoeluted = abs(rtVector(i)-rtVector(j)) <= this.maxRetentionTimeShift;
                    if areRedundant && haveCoeluted
                        isofeatureData(i,j) = this.ISOFEATURE_FLAG_VALUE;
                        isofeatureData(j,i) = this.ISOFEATURE_FLAG_VALUE;
                    end
                end
            end 
            
            if this.linkIsofeatures
                % Compact isofeature matrix based on the tansitivity property
                % i.e. if A1 & A2 have coeluted and A2 & A3 have coeluted then
                % A1 & A2 & A3 have coeluted
                % Denote by A, the adjacency matrix A(i,j) = 3 if Ai and Aj are
                % isofeatures
                % Denote by x = diag(n) = I the matrix representing the set of
                % all initial node positions
                % Then F = x + A*x + ... A^(n-1)*x = I + A + A^2 + ... + A^n-1 the is
                % walking function, say the linking function, from any nodes to
                % all the other nodes of the graph in n-1 steps
                % According to the transitivity property, F will link all the
                % node (isofeatures linked between them)
                % trick : After scaling each walking step by 1/n!, we have
                % F = I + A + A^2/2 + ... + A^n-1/(n-1)! = expm(A) 

                A = isofeatureData;
                idx = (A >= this.ISOFEATURE_FLAG_VALUE);
                A(idx) = 1; A(~idx) = 0;
                isofeatureData  = expm(A);
                isofeatureData( isofeatureData > 0 ) = this.ISOFEATURE_FLAG_VALUE;
            end
            
            this.isofeatureMatrix = biotracs.data.model.DataMatrix(...
                isofeatureData, ...
                this.featureSet.getColumnNames(), ...
                this.featureSet.getColumnNames()...
                );
        end
        
        %> @brief Compute the adduct matrix A. Features i and j are
        %> putative adducts if they are redundant and validate the adduct
        %> table. In this case A(i,j) = @a ADDUCT_FLAG_VALUE
        %> @param[in, optional] varargin
        %> @return the adduct matrix (biotracs.data.model.DataMatrix)
        function calculateAdductMatrix( this, varargin  )
            %[ redundancyMatrix ] = this.calculateRedundancyMatrix( varargin{:} );
            %[ isofeatureMatrix ] = this.calculateIsofeatureMatrix( varargin{:} );
            fprintf('Calculate adduct matrix...\n');
            
            n = getSize( this.redundancyMatrix,1 );
            adductData = this.isofeatureMatrix.data;
            adductPairsData = cell(n,n);

            [ mzVector, rtVector, modeVector ] = this.retrieveFeatureInfoFromTrainingSet();
            [ putativeNeutralMasses ] = this.computePutativeNeutralMasses( mzVector, modeVector );

            for i=1:n
                for j = i+1:n
                    areIsofeatures = this.isofeatureMatrix.data(i,j) >=  this.ISOFEATURE_FLAG_VALUE;
                    areAlreadyComputedAsAdducts = adductData(i,j) >=  this.ADDUCT_FLAG_VALUE;
                    if ~areIsofeatures, continue; end
                    if areAlreadyComputedAsAdducts, continue; end
 
                    [ putativeAdductPairIndexes ] = this.computePutativeAdductPairs( putativeNeutralMasses{i}, putativeNeutralMasses{j} );
                    areKnownPutativeAdducts =  any(putativeAdductPairIndexes(:));
                    
                    if areKnownPutativeAdducts
                        [ lhsAdductIndexes, rhsAdductIndexes ] = find( putativeAdductPairIndexes );
                        nbAdductCombinations = length(lhsAdductIndexes);
%                         thereIsMoreThanOneAdductPairs = nbAdductCombinations > 1;
%                         if thereIsMoreThanOneAdductPairs
%                             lhsAdductIndexes = lhsAdductIndexes(1);
%                             rhsAdductIndexes = rhsAdductIndexes(1);
%                             fprintf( 'More than one adduct pairs found for freatures M%d_T%d and M%d_T%d \n', mzVector(i), rtVector(i), mzVector(j), rtVector(j) );
%                         end
       
                        adductData(i,j) = this.ADDUCT_FLAG_VALUE;
                        adductData(j,i) = this.ADDUCT_FLAG_VALUE;
                        adductPairsData{i,j} = cell(1,nbAdductCombinations);
                        for ii=1:nbAdductCombinations
                            k = lhsAdductIndexes(ii);
                            l = rhsAdductIndexes(ii);
                            adductName1 = this.retrieveAdductNameFromShiftTables( k, modeVector{i} );
                            adductName2 = this.retrieveAdductNameFromShiftTables( l, modeVector{j} );
                            adductPairsData{i,j}{ii} = {adductName1,adductName2};
                            adductPairsData{j,i}{ii} = {adductName2,adductName1};
                        end
                    end
                    
                end
            end
            
            this.adductMatrix = biotracs.data.model.DataMatrix(...
                adductData, ...
                this.featureSet.getColumnNames(), ...
                this.featureSet.getColumnNames()...
                );
            this.adductMatrix.bindView( biotracs.mimosa.view.AdductMatrix() );
            
            this.adductPairsTable = biotracs.data.model.DataTable(...
                adductPairsData, ...
                this.featureSet.getColumnNames(), ...
                this.featureSet.getColumnNames()...
                );
        end
        
        function [ delta ] = computeCrossMassDelta( ~, data1, data2 )
            m = size(data1,1);
            n = size(data2,1);
            
            delta = nan(m,n);
            for i=1:m
                for j=1:n
                    delta(i,j) = abs(data1(i) - data2(j));
                end
            end
        end
        
        function [ count ] = countUnique( ~, corrMatrix )
            count = sum( sum(corrMatrix.data) >= 1 );
        end
         
        function [ nbAdducts ] = computeNbAdducts( ~  )
            nbAdducts = this.countUnique( );
        end
        
        function [ adductPairIndexes ] = computePutativeAdductPairs( this, iFirstPutativeNeutralMasses, iSecondPutativeNeutralMasses )
            massDelta = this.computeCrossMassDelta(iFirstPutativeNeutralMasses, iSecondPutativeNeutralMasses);
            
            %compute minimal ppm distance
            [k,l] = find( massDelta == min(massDelta(:)) );
            thereIsMoreThanOneAdductPairs = (length(k)>1);
            if thereIsMoreThanOneAdductPairs
                k = k(1);
                l = l(1);
            end
            mass(1) = iFirstPutativeNeutralMasses(k);
            mass(2) = iSecondPutativeNeutralMasses(l);
            ppmDistance = 1e6*massDelta/mean(mass);
            
            adductPairIndexes = ppmDistance <= this.mzPpmError;
        end
        
        function [ putativeNeutralMasses ] = computePutativeNeutralMasses( this, mz, mode )
            n = length(mz);
            posAdductMzShift = cell2mat(this.POSITIVE_ADDUCT_LIST(:,2));
            negAdductMzShift = cell2mat(this.NEGATIVE_ADDUCT_LIST(:,2));
            putativeNeutralMasses = cell(1,n);
            for i=1:n
                if strcmp(mode{i},'Pos')
                    putativeNeutralMasses{i} = mz(i) - posAdductMzShift;
                elseif strcmp(mode{i},'Neg')
                    putativeNeutralMasses{i} = mz(i) - negAdductMzShift;
                else
                    error('Invalid acquisition mode');
                end
            end
        end
        
        function createMapFromIsofeatureMatrix( this, varargin  )
            fprintf('Calculate isofeature map from isofeature matrix...\n');
            this.isofeatureMap = this.doCreateMapFromMatrix( this.isofeatureMatrix, this.ISOFEATURE_FLAG_VALUE  );
        end
        
        function createMapFromAdductMatrix( this, varargin  )
            fprintf('Calculate adduct map from adduct matrix...\n');
            this.adductMap = this.doCreateMapFromMatrix( this.adductMatrix, this.ADDUCT_FLAG_VALUE  );
        end
        
        %-- E --
        
        function exportAdductPairsInfo( this, iFilePath, writeNone )
            fid = fopen(iFilePath, 'w+');
            n = length(this.adductMap);
            if nargin < 5
                writeNone = true;
            end
            for featureIndex=1:n
                adductPairList = this.getAdductPairList( featureIndex );
                isNotAdduct = isempty(adductPairList);
                
                if isNotAdduct
                    if writeNone
                        fprintf(fid, '%s \t None\n', this.adductPairsTable.getRowName(featureIndex) );
                    end
                else
                    for i=1:length(adductPairList)
                        m = length(adductPairList{i});
                        for k=1:m
                            adductPair = adductPairList{i}{k};
                            fprintf(fid, ...
                                '%s, %s \t %s, %s\n', ...
                                adductPair{1}.feature, adductPair{1}.formula, adductPair{2}.feature, adductPair{2}.formula);
                        end
                    end
                    fprintf(fid, ' \t \n');
                end
            end
            fclose(fid);
        end
        
        function exportIsofeaturePairsInfo( this, iFilePath, writeNone )
            fid = fopen(iFilePath, 'w+');
            n = length(this.adductMap);
            if nargin < 7
                writeNone = true;
            end
            for featureIndex=1:n
                isofeatureIndexes = this.isofeatureMap{featureIndex};
                isofeatureNames = this.featureSet.getColumnNames( isofeatureIndexes );
                
                isNotIsofeature = isempty(isofeatureIndexes);
                if isNotIsofeature
                    if writeNone
                        fprintf(fid, '%s \t None\n', this.featureSet.getColumnName(featureIndex) );
                    end
                else
                    adductPairList = this.getAdductPairList( featureIndex );
                    isNotAdduct = isempty(adductPairList);

                    if isNotAdduct
                        for i=1:length(isofeatureNames)
                            fprintf(fid, ...
                                '%s, X \t %s, X\n', ...
                                this.featureSet.getColumnName(featureIndex), isofeatureNames{i} );
                        end
                    else
                        for i=1:length(adductPairList)
                            m = length(adductPairList{i});
                            for k=1:m
                                adductPair = adductPairList{i}{k};
                                fprintf(fid, ...
                                    '%s, %s \t %s, %s\n', ...
                                    adductPair{1}.feature, adductPair{1}.formula, adductPair{2}.feature, adductPair{2}.formula );
                            end
                        end
                    end
                    fprintf(fid, ' \t \n');
                end
            end
            fclose(fid);
        end
        
        %-- G --
        
        function [ adductPairList, indexes ] = getAdductPairList( this, iFeatureIndex )
            indexes = this.adductMap{iFeatureIndex};
            adductPairList = cell(1:length(indexes));
            if isempty(indexes)
                adductPairList = {};
            else
                for j=1:length(indexes)
                    namePairs = this.adductPairsTable.data{iFeatureIndex,indexes(j)};
                    m = length(namePairs);
                    adductPairList{j} = cell(1,m);
                    for k=1:m
                        namePair = namePairs{k};
                        adductPairList{j}{k} = { ...
                            struct(...
                            'feature', this.adductPairsTable.getRowName(iFeatureIndex), ...
                            'formula', namePair{1} ...
                            ), ...
                            struct(...
                            'feature', this.adductPairsTable.getRowName(indexes(j)), ...
                            'formula', namePair{2} ...
                            ) ...
                            };
                    end
                end
            end
        end
        
        function nbAdducts = getNbRedundants( this )
            nbAdducts = sum( sum(this.redundancyMatrix.data >= this.REDUNDANCY_FLAG_VALUE) >= 1 );
        end
        
        function nbAdducts = getNbAdducts( this )
            nbAdducts = sum( sum(this.adductMatrix.data >= this.ADDUCT_FLAG_VALUE) >= 1 );
        end
        
        function nbAdducts = getNbIsofeatures( this )
            nbAdducts = sum( sum(this.isofeatureMatrix.data >= this.ISOFEATURE_FLAG_VALUE) >= 1 );
        end
        
        %-- D --
        
        function displayAdductPairsInfo( this, iFeatureIndex )
            adductPairList = this.getAdductPairList( iFeatureIndex );
            if isempty(adductPairList)
                fprintf(' > %s has no adducts\n', this.adductPairsTable.getRowName(iFeatureIndex) );
            else
                for i=1:length(adductPairList)  %for each feature
                    m = length(adductPairList{i});
                    for k=1:m                   %for each adduct pair
                        adductPair = adductPairList{i}{k};
                        fprintf(...
                            ' > {%s, %s} = {%s, %s}\n', ...
                            adductPair{1}.feature, adductPair{1}.formula, adductPair{2}.feature, adductPair{2}.formula ...
                            );
                    end
                end
            end
        end
        
        
        %-- R --
        
        function [ adductName ] = retrieveAdductNameFromShiftTables( this, i, mode )
            if strcmp(mode,'Pos')
                adductName = this.POSITIVE_ADDUCT_LIST{i,1};
            else
                adductName = this.NEGATIVE_ADDUCT_LIST{i,1};
            end
        end
        
        %> @brief Reduce the training set by grouping all putative adducts
        %> together. The group is representing by one feature of the group.
        %> @param[in] training set to reduce
        %> @param[in] adduct map to use for reduction
        %> @param[in] adduct pair table to use
        function [ reducedTrainingSet, selectedFeatureIdx ] = reduceTrainingSetUsingAdductMap( this )
            reducedTrainingSet =  this.featureSet.copy();
			%reducedTrainingSet =  this.featureSet.copy('IgnoreProcess', true);
            [m,n] = getSize( this.featureSet );
            selectedFeatureIdx = true(1,n);
            nbAdductGroups = 0;
            for i=1:n
                [adductPairList, idx] = this.getAdductPairList( i );
                isFeatureAlreadyDiscarded = ~selectedFeatureIdx(i);
                isNotAdduct = isempty(adductPairList);
                if isNotAdduct
                    %Do not discard this feature
                    nbAdductGroups = nbAdductGroups + 1;
                    reducedTrainingSet.setColumnTag( i, 'AdductGroupIndex', nbAdductGroups );
                elseif ~isFeatureAlreadyDiscarded
                    reducedTrainingSet.setDataAt( 1:m, i, mean(reducedTrainingSet.getDataAt(1:m,idx),2) );
                    reducedTrainingSet.setColumnTag( i, 'AdductsPairs', adductPairList );
                    reducedTrainingSet.setColumnTag( i, 'AdductsIndexes', idx );
                    selectedFeatureIdx( idx ) = false;
                    
                    nbAdductGroups = nbAdductGroups + 1;
                    reducedTrainingSet.setColumnTag( i, 'AdductGroupIndex', nbAdductGroups );
                end
            end
            [reducedTrainingSet] = reducedTrainingSet.selectByColumnIndexes(selectedFeatureIdx);
        end

        function [ reducedTrainingSet, selectedFeatureIdx ] = reduceTrainingSetUsingIsofeatureMap( this )
            reducedTrainingSet =  this.featureSet.copy();
			%reducedTrainingSet =  this.featureSet.copy('IgnoreProcess', true);
            [m,n] = getSize( this.featureSet );
            selectedFeatureIdx = true(1,n);
            nbIsofeatureGroups = 0;
            for i=1:n
                isofeatureIndexes = this.isofeatureMap{i};
                isofeatureNames = this.featureSet.getColumnNames( isofeatureIndexes );
                isFeatureAlreadyDiscarded = ~selectedFeatureIdx(i);
                isNotIsofeature = isempty(isofeatureIndexes);
                if isNotIsofeature
                    %Do not discard this feature
                    nbIsofeatureGroups = nbIsofeatureGroups + 1;
                    reducedTrainingSet.setColumnTag( i, 'IsofeatureGroupIndex', nbIsofeatureGroups );
                elseif ~isFeatureAlreadyDiscarded
                    %reduce according to isofeatures
                    selectedFeatureIdx( isofeatureIndexes ) = false;
                    reducedTrainingSet.setColumnTag( i, 'IsofeatureIndexes', isofeatureIndexes );
                    reducedTrainingSet.setColumnTag( i, 'IsofeatureNames', isofeatureNames );
                    
                    %@BugFixed ! (Mean were used initially only if adducts exist)
                    reducedTrainingSet.setDataAt( 1:m, i, mean(this.featureSet.getDataAt(1:m,isofeatureIndexes),2) );
                    
                    %set adducts infos
                    [adductPairList, adductIndexes] = this.getAdductPairList( i );
                    adductNames = this.featureSet.getColumnNames( adductIndexes );
                    isAdduct = ~isempty(adductIndexes);
                    if isAdduct
                        reducedTrainingSet.setColumnTag( i, 'AdductPairs', adductPairList );
                        reducedTrainingSet.setColumnTag( i, 'AdductIndexes', adductIndexes );
                        reducedTrainingSet.setColumnTag( i, 'AdductNames', adductNames );
                    end
                    nbIsofeatureGroups = nbIsofeatureGroups + 1;
                    reducedTrainingSet.setColumnTag( i, 'IsofeatureGroupIndex', nbIsofeatureGroups );
                end
            end
            [reducedTrainingSet] = reducedTrainingSet.selectByColumnIndexes(selectedFeatureIdx);
        end
        
        function [ mzVector, rtVector, modeVector ] = retrieveFeatureInfoFromTrainingSet( this )
            n = this.featureSet.getNbColumns();
            parsedFeatureName = cellfun( @(x)(regexp(x,'^M(.+)_T(.+)_(Neg|Pos)$','tokens')), this.featureSet.getColumnNames(), 'UniformOutput', false);            
            
            rtVector = zeros(1,n);
            mzVector = zeros(1,n);
            modeVector = cell(1,n);
            for i=1:n
                tab = parsedFeatureName{i}{1};
                mzVector(i) = str2double(tab{1});
                rtVector(i) = str2double(tab{2});
                modeVector{i} = tab{3};
            end
        end
        
    end
    
    methods(Access = protected)
        
        function [ oMap ] = doCreateMapFromMatrix( ~, iMatrix, iFlagValue  )
            n = getSize(iMatrix,1);
            oMap = cell(1,n);
            for i=1:n
                idx = find( iMatrix.data(i, :) >= iFlagValue );
                oMap{i} = idx;
            end
        end
        
    end
    
end

