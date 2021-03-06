classdef DriftCorrectorTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs/mimosa/DriftCorrectorTests');
    end
    
    
    methods (Test)
        
        function testInterDriftCorrector(testCase)
            samplesForInterBatchCorrection = 'QCOnly';
            [ correctedFeatureSet ] = testCase.doInterDriftCorrector( samplesForInterBatchCorrection );
            expectedCorrectedFeatureSet = biotracs.spectra.data.model.MSFeatureSet.import( '../../../testdata/DriftCorrection/CorrectedFeatureSetInter_WithQCOnly.csv' );
            testCase.verifyEqual( correctedFeatureSet.data, expectedCorrectedFeatureSet.data, 'RelTol', 1e-6 );
            
            samplesForInterBatchCorrection = 'SamplesWithoutQC';
            [ correctedFeatureSet ] = testCase.doInterDriftCorrector( samplesForInterBatchCorrection );
            expectedCorrectedFeatureSet = biotracs.spectra.data.model.MSFeatureSet.import( '../../../testdata/DriftCorrection/CorrectedFeatureSetInter_WithoutQC.csv' );
            testCase.verifyEqual( correctedFeatureSet.data, expectedCorrectedFeatureSet.data, 'RelTol', 1e-6 );
            
            samplesForInterBatchCorrection = 'All';
            [ correctedFeatureSet ] = testCase.doInterDriftCorrector( samplesForInterBatchCorrection );
            expectedCorrectedFeatureSet = biotracs.spectra.data.model.MSFeatureSet.import( '../../../testdata/DriftCorrection/CorrectedFeatureSetInter_WithAllSamples.csv' );
            testCase.verifyEqual( correctedFeatureSet.data, expectedCorrectedFeatureSet.data, 'RelTol', 1e-6 );
        end

        function testIntraDriftCorrector(testCase)
            %Set deterministic testing
            s = RandStream.getGlobalStream();
            s2 = RandStream.create('mrg32k3a','Seed',0);
            RandStream.setGlobalStream(s2);
            
            rowNameKeyValPatterns = {...
                'BatchPattern', 'MSBatch:([^_]*)', ...
                'SamplePattern', 'MSSampleType:Sample', ...
                'QcPattern', 'MSSampleType:QC', ...
                'SequenceNumberPattern', 'SeqNb:([^_]*)'};
            featureMatrix = biotracs.spectra.data.model.MSFeatureSet.import(...
                '../../../testdata/Data/ecoli_fake.csv', ...
                rowNameKeyValPatterns{:} ...
                );

            % Drift Correction Intra
            process = biotracs.mimosa.model.DriftCorrector();
            process.setInputPortData('FeatureSet', featureMatrix);
            c = process.getConfig();
            c.updateParamValue('NbFirstQcToIgnore', 0);
            c.updateParamValue('LoQ', 1e3);
            c.updateParamValue('IntraBatchCorrection', true);
            c.updateParamValue('CorrectionModel', 'linear');
            process.run();
            correctedFeatureSet = process.getOutputPortData('FeatureSet');
            correctedFeatureSet.export([ testCase.workingDir, '/CorrectedFeatureSetIntra.csv' ]);
            
            %test result
            expectedCorrectedFeatureSet = biotracs.spectra.data.model.MSFeatureSet.import( '../../../testdata/DriftCorrection/CorrectedFeatureSetIntra.csv' );
            testCase.verifyEqual( correctedFeatureSet.data, expectedCorrectedFeatureSet.data, 'RelTol', 1e-6 );
            correctedFeatureSet.view('QcDriftPlot');
            
            %Restore stream
            RandStream.setGlobalStream(s);
        end
   
    end
    
    methods
        
        function [ correctedFeatureSet ] = doInterDriftCorrector(testCase, samplesForInterBatchCorrection)
            %Set deterministic testing
            s = RandStream.getGlobalStream();
            s2 = RandStream.create('mrg32k3a','Seed',0);
            RandStream.setGlobalStream(s2)
            
            rowNameKeyValPatterns = {...
                'BatchPattern', 'MSBatch:([^_]*)', ...
                'SamplePattern', 'MSSampleType:Sample', ...
                'QcPattern', 'MSSampleType:QC', ...
                'SequenceNumberPattern', 'SeqNb:([^_]*)'};
            featureMatrix = biotracs.spectra.data.model.MSFeatureSet.import(...
                '../../../testdata/Data/ecoli_fake.csv', ...
                rowNameKeyValPatterns{:} ...
                );

            process = biotracs.mimosa.model.DriftCorrector();
            process.setInputPortData('FeatureSet', featureMatrix);
            c = process.getConfig();
            c.updateParamValue('NbFirstQcToIgnore', 1);
            c.updateParamValue('CorrectionModel', 'linear');
            c.updateParamValue('LoQ', 1e3);
            c.updateParamValue('InterBatchCorrection', true);
            c.updateParamValue('SamplesToUseForInterBatchCorrection', samplesForInterBatchCorrection);
            c.updateParamValue('WorkingDirectory', testCase.workingDir);
            process.run();
            correctedFeatureSet = process.getOutputPortData('FeatureSet');
            correctedFeatureSet.export([ testCase.workingDir, '/CorrectedFeatureSetInter.csv' ] );

            % Pca
            pca = biotracs.atlas.model.PCALearner();
            c = pca.getConfig();
            c.updateParamValue('NbComponents',2);
            c.updateParamValue('WorkingDirectory',testCase.workingDir);
            pca.setInputPortData('TrainingSet',featureMatrix.toDataSet());
            pca.run();
            result = pca.getOutputPortData('Result');
            result.view('ScorePlot', ...
                'GroupList', {'MSBatch'},...
                'LabelFormat', {'MSBatch:([^_]*)', 'MSSampleType:([^_]*)'} ...
            );
            
            pca = biotracs.atlas.model.PCALearner();
            c = pca.getConfig();
            c.updateParamValue('NbComponents',2);
            c.updateParamValue('WorkingDirectory',testCase.workingDir);
            pca.setInputPortData('TrainingSet',correctedFeatureSet.toDataSet());
            pca.run();
            result = pca.getOutputPortData('Result');
            result.view('ScorePlot', ...
                'GroupList', {'MSBatch'},...
                'LabelFormat', {'MSBatch:([^_]*)', 'MSSampleType:([^_]*)'} ...
            );

            %Restore stream
            RandStream.setGlobalStream(s);
        end
        
    end
    
end

