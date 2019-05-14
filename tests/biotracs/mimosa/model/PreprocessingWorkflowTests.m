classdef PreprocessingWorkflowTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs/mimosa/PreprocessingWorkflowTests');
    end
    
    
    methods (Test)
        
        function testWorkflow(testCase)
%                         return
            workflow = biotracs.mimosa.model.PreprocessingWorkflow();
            workflow.getConfig()...
                .updateParamValue( 'WorkingDirectory', [testCase.workingDir, '/PosAndNeg'] );
            
            %% Import SampleMetaData
            inputAdpter = workflow.getNode('SampleMetaDataFileImporter');
            inputAdpter.addInputFilePath( '../../../testdata/SingleModePreprocessing/SampleMetadata.xlsx' );
            
            %% Import FeatureSet
            inputAdpter = workflow.getNode('PosConsensusFileImporter');
            inputAdpter.addInputFilePath( '../../../testdata/SingleModePreprocessing/BlankExtrac_B3_pos_20160926_057.csv' );
            
            % ConsensusDataParser
            w1 = workflow.getNode('PosModePreprocessingWorkflow');
            consensusDataParser = w1.getNode('ConsensusDataParser');
            consensusDataParser.getConfig()...
                .updateParamValue('NbHeaderLines', 1);
            
            consensusDataExtractor = w1.getNode('ConsensusDataExtractor');
            consensusDataExtractor.getConfig()...
                .updateParamValue('Polarity', 'Pos')...
                .updateParamValue('BatchPattern', 'MSBatch:([^_]*)')...
                .updateParamValue('QcPattern', 'MSSampleType:QC')...
                .updateParamValue('SamplePattern', 'MSSampleType:Sample')...
                .updateParamValue('SequenceNumberPattern', 'MSSequenceNumber:([^_]*)');
            
            % Annotate
            consensusDataAnnotator = w1.getNode('ConsensusDataAnnotator');
            consensusDataAnnotator.getConfig()...
                .updateParamValue('HeadersToUse', {'Injection', 'TimePoint', 'Individual', 'AcquisitionDatetime','MSBatch','BiologicalReplicate', 'MSSequenceNumber', 'MSSampleType', 'MSPolarity'})...
                .updateParamValue('UserIdHeader', 'UserFileName');
            
            %% DataRemove
            dataSelector = w1.getNode('DataSelector');
            dataSelector.getConfig().updateParamValue(...
                'ListOfNames', ...
                {'QC_B3_pos_HCD40-60_20160926_056', ...
                'QC_B3_pos_HDC10-20_20160926_055', ...
                'StdLipids_1ppm_B3_pos_20160926_060', ...
                'QC_B4_pos_HCD40-60_20160928_064', ...
                'StdLipids_IS_0p5ppm_B4_pos_20160928_003', ...
                'StdLipids_IS_0p5ppm_B4_pos_20160928_068'});
            
            % Filter by 80 %
            percentageRuleFilter = w1.getNode('PercentageRuleFilter');
            percentageRuleFilter.getConfig()...
                .updateParamValue('PercentageRuleThreshold', 0.8)...
                .updateParamValue('GroupList', {'Injection:Cond1', 'Injection:Cond2','Injection:CTL'});
            w1.getNode('PercentageRuleFilterFileExporter');
            
            % FilterCv 20%
            qcCvFilter = w1.getNode('QcCvFilter');
            qcCvFilter.getConfig()...
                .updateParamValue('QcCvThreshold', 0.2)...
                .updateParamValue('PercentageRuleThreshold', 0)...
                .updateParamValue('LoQ', 1e4);
            
            %% Negative Workflow
            
            % Import FeatureSet
            inputAdpter = workflow.getNode('NegConsensusFileImporter');
            inputAdpter.addInputFilePath( '../../../testdata/SingleModePreprocessing/BlankExtrac_B1_neg_201609019_057.csv' );
            
            % ConsensusDataParser
            w2 = workflow.getNode('NegModePreprocessingWorkflow');
            consensusDataParser = w2.getNode('ConsensusDataParser');
            consensusDataParser.getConfig()...
                .updateParamValue('NbHeaderLines', 1);
            
            consensusDataExtractor = w2.getNode('ConsensusDataExtractor');
            consensusDataExtractor.getConfig()...
                .updateParamValue('Polarity', 'Neg')...
                .updateParamValue('BatchPattern', 'MSBatch:([^_]*)')...
                .updateParamValue('QcPattern', 'MSSampleType:QC')...
                .updateParamValue('SamplePattern', 'MSSampleType:Sample')...
                .updateParamValue('SequenceNumberPattern', 'MSSequenceNumber:([^_]*)');
            
            % Annotate
            consensusDataAnnotator = w2.getNode('ConsensusDataAnnotator');
            consensusDataAnnotator.getConfig()...
                .updateParamValue('HeadersToUse', {'Injection', 'TimePoint', 'Individual', 'AcquisitionDatetime','MSBatch','BiologicalReplicate', 'MSSequenceNumber', 'MSSampleType', 'MSPolarity'}) ...
                .updateParamValue('UserIdHeader', 'UserFileName');
            
            % Filter by 80 %
            percentageRuleFilter = w2.getNode('PercentageRuleFilter');
            percentageRuleFilter.getConfig()...
                .updateParamValue('PercentageRuleThreshold', 0.8)...
                .updateParamValue('GroupList', {'Injection:Cond1', 'Injection:Cond2','Injection:CTL'});
            
            % FilterCv 20%
            qcCvFilter = w2.getNode('QcCvFilter');
            qcCvFilter.getConfig()...
                .updateParamValue('QcCvThreshold', 0.2)...
                .updateParamValue('PercentageRuleThreshold', 0)...
                .updateParamValue('LoQ', 1e4);
            w2.getNode('QcCvFilterFileExporter');
            
            featureMerger = workflow.getNode('FeatureSetMerger');
            featureMerger.getConfig()...
                .updateParamValue('AnnotationNamesForMerging',{ 'TimePoint', 'Individual',   'MSSampleType'});
            %% Run MergeWorkflow
            workflow.run();
        end
        
        
        
        function testWorkflowPos(testCase)
%             return;
            workflow = biotracs.mimosa.model.PreprocessingWorkflow();
            workflow.getConfig()...
                .updateParamValue( 'WorkingDirectory', [testCase.workingDir, 'Pos'] );
            
            %% Import SampleMetaData
            inputAdpter = workflow.getNode('SampleMetaDataFileImporter');
            inputAdpter.addInputFilePath( '../../../testdata/SingleModePreprocessing/SampleMetadata.xlsx' );
            
            %% Import FeatureSet
            inputAdpter = workflow.getNode('PosConsensusFileImporter');
            inputAdpter.addInputFilePath( '../../../testdata/SingleModePreprocessing/BlankExtrac_B3_pos_20160926_057.csv' );
            
            % ConsensusDataParser
            w1 = workflow.getNode('PosModePreprocessingWorkflow');
            consensusDataParser = w1.getNode('ConsensusDataParser');
            consensusDataParser.getConfig()...
                .updateParamValue('NbHeaderLines', 1);
            
            consensusDataExtractor = w1.getNode('ConsensusDataExtractor');
            consensusDataExtractor.getConfig()...
                .updateParamValue('Polarity', 'Pos')...
                .updateParamValue('BatchPattern', 'MSBatch:([^_]*)')...
                .updateParamValue('QcPattern', 'MSSampleType:QC')...
                .updateParamValue('SamplePattern', 'MSSampleType:Sample')...
                .updateParamValue('SequenceNumberPattern', 'MSSequenceNumber:([^_]*)');
            
            % Annotate
            consensusDataAnnotator = w1.getNode('ConsensusDataAnnotator');
            consensusDataAnnotator.getConfig()...
                .updateParamValue('HeadersToUse', {'Injection', 'TimePoint', 'Individual', 'AcquisitionDatetime','MSBatch','BiologicalReplicate', 'MSSequenceNumber', 'MSSampleType', 'MSPolarity'})...
                .updateParamValue('UserIdHeader', 'UserFileName');
            
            %% DataRemove
            dataSelector = w1.getNode('DataSelector');
            dataSelector.getConfig().updateParamValue(...
                'ListOfNames', ...
                {'QC_B3_pos_HCD40-60_20160926_056', ...
                'QC_B3_pos_HDC10-20_20160926_055', ...
                'StdLipids_1ppm_B3_pos_20160926_060', ...
                'QC_B4_pos_HCD40-60_20160928_064', ...
                'StdLipids_IS_0p5ppm_B4_pos_20160928_003', ...
                'StdLipids_IS_0p5ppm_B4_pos_20160928_068'});
            
            % Filter by 80 %
            percentageRuleFilter = w1.getNode('PercentageRuleFilter');
            percentageRuleFilter.getConfig()...
                .updateParamValue('PercentageRuleThreshold', 0.8)...
                .updateParamValue('GroupList', {'Injection:Cond1', 'Injection:Cond2','Injection:CTL'});
            w1.getNode('PercentageRuleFilterFileExporter');
            
            % FilterCv 20%
            qcCvFilter = w1.getNode('QcCvFilter');
            qcCvFilter.getConfig()...
                .updateParamValue('QcCvThreshold', 0.2)...
                .updateParamValue('PercentageRuleThreshold', 0)...
                .updateParamValue('LoQ', 1e4);
            
            
            
            %% Run MergeWorkflow
            workflow.run();
        end
        
        function testWorkflowNeg(testCase)
%             return;
            workflow = biotracs.mimosa.model.PreprocessingWorkflow();
            workflow.getConfig()...
                .updateParamValue( 'WorkingDirectory', [testCase.workingDir, '/Neg'] );
            
            %% Import SampleMetaData
            inputAdpter = workflow.getNode('SampleMetaDataFileImporter');
            inputAdpter.addInputFilePath( '../../../testdata/SingleModePreprocessing/SampleMetadata.xlsx' );
            
            
            
            %% Negative Workflow
            
            % Import FeatureSet
            inputAdpter = workflow.getNode('NegConsensusFileImporter');
            inputAdpter.addInputFilePath( '../../../testdata/SingleModePreprocessing/BlankExtrac_B1_neg_201609019_057.csv' );
            
            % ConsensusDataParser
            w2 = workflow.getNode('NegModePreprocessingWorkflow');
            consensusDataParser = w2.getNode('ConsensusDataParser');
            consensusDataParser.getConfig()...
                .updateParamValue('NbHeaderLines', 1);
            
            consensusDataExtractor = w2.getNode('ConsensusDataExtractor');
            consensusDataExtractor.getConfig()...
                .updateParamValue('Polarity', 'Neg')...
                .updateParamValue('BatchPattern', 'MSBatch:([^_]*)')...
                .updateParamValue('QcPattern', 'MSSampleType:QC')...
                .updateParamValue('SamplePattern', 'MSSampleType:Sample')...
                .updateParamValue('SequenceNumberPattern', 'MSSequenceNumber:([^_]*)');
            
            % Annotate
            consensusDataAnnotator = w2.getNode('ConsensusDataAnnotator');
            consensusDataAnnotator.getConfig()...
                .updateParamValue('HeadersToUse', {'Injection', 'TimePoint', 'Individual', 'AcquisitionDatetime','MSBatch','BiologicalReplicate', 'MSSequenceNumber', 'MSSampleType', 'MSPolarity'}) ...
                .updateParamValue('UserIdHeader', 'UserFileName');
            
            % Filter by 80 %
            percentageRuleFilter = w2.getNode('PercentageRuleFilter');
            percentageRuleFilter.getConfig()...
                .updateParamValue('PercentageRuleThreshold', 0.8)...
                .updateParamValue('GroupList', {'Injection:Cond1', 'Injection:Cond2','Injection:CTL'});
            
            % FilterCv 20%
            qcCvFilter = w2.getNode('QcCvFilter');
            qcCvFilter.getConfig()...
                .updateParamValue('QcCvThreshold', 0.2)...
                .updateParamValue('PercentageRuleThreshold', 0)...
                .updateParamValue('LoQ', 1e4);
            w2.getNode('QcCvFilterFileExporter');
            
            %% Run MergeWorkflow
            workflow.run();
        end
        
        
    end
    
end

