classdef SingleModePreprocessingWorkflowTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs/mimosa/SingleModePreprocessingWorkflowTests');
    end
    
    
    methods (Test)
        
        function testPosModePreprocessingWorkflow(testCase)
            return
            workflow = testCase.doBuildWorflow( 'Pos' );
            workflow.run();
            
            intraBatchDriftCorrector = workflow.getNode('IntraBatchDriftCorrector');
            featureSet = intraBatchDriftCorrector.getOutputPortData('FeatureSet');
            featureSet.view('QcDriftPlot');
            featureSet.view('QcCvPlot');
            featureSet.view(...
                'FeatureCountPlot', ...
                'LoQ', 1e4, ...
                'LabelFormat', {'pattern',{'MSSampleType:([^_]*)','MSBatch:([^_]*)'}});
        end
        
        function testNegModePreprocessingWorkflow(testCase)
            workflow = testCase.doBuildWorflow( 'Neg' );
            workflow.run();
            
        end
        
    end
    
    methods (Access = protected)
        
        function workflow = doBuildWorflow(testCase, iPolarity)
            workflow = biotracs.mimosa.model.SingleModePreprocessingWorkflow();
            
            
            %% Input FeatureSet
            inputAdpter = workflow.getNode('FeatureSetFileImporter');
            
            if strcmpi(iPolarity, 'Pos')
                workflow.getConfig().updateParamValue( 'WorkingDirectory', [testCase.workingDir, 'SingleModePreprocessing\Pos\'] );
                inputAdpter.addInputFilePath( '../../../testdata/SingleModePreprocessing/BlankExtrac_B3_pos_20160926_057.csv' );
            else
                workflow.getConfig().updateParamValue( 'WorkingDirectory', [testCase.workingDir, 'SingleModePreprocessing\Neg\'] );
                inputAdpter.addInputFilePath( '../../../testdata/SingleModePreprocessing/BlankExtrac_B1_neg_201609019_057.csv' );
            end
            
            %% Input SampleMetaData
            inputAdpter = workflow.getNode('SampleMetaDataFileImporter');
            inputAdpter.addInputFilePath( '../../../testdata/SingleModePreprocessing/SampleMetadata.xlsx' );

            %% Import featureSet
            consensusDataParser = workflow.getNode('ConsensusDataParser');
            consensusDataParser.getConfig().updateParamValue('NbHeaderLines', 1);

            %% Extract featureSet
            consensusDataExtractor = workflow.getNode('ConsensusDataExtractor');
            consensusDataExtractor.getConfig()...
                .updateParamValue('Polarity', iPolarity) ...
                .updateParamValue('BatchPattern', 'MSBatch:([^_]*)')...
                .updateParamValue('QcPattern', 'MSSampleType:QC')...
                .updateParamValue('SamplePattern', 'MSSampleType:Sample')...
                .updateParamValue('SequenceNumberPattern', 'MSSequenceNumber:([^_]*)');  

            %% DataRemove
            dataSelector = workflow.getNode('DataSelector');
            dataSelector.getConfig().updateParamValue(...
                'ListOfNames', ...
                {'QC_B3_pos_HCD40-60_20160926_056', ...
                'QC_B3_pos_HDC10-20_20160926_055', ...
                'StdLipids_1ppm_B3_pos_20160926_060', ...
                'QC_B4_pos_HCD40-60_20160928_064', ...
                'StdLipids_IS_0p5ppm_B4_pos_20160928_003', ...
                'StdLipids_IS_0p5ppm_B4_pos_20160928_068', ...
                'StdLipids_IS_0p5ppm_B1_neg_20160921_004', ...
                'StdLipids_1ppm_B1_neg_20160921_069', ...
                'StdLipids_1ppm_B1_neg_201609019_003', ...
                'QC-old-PGE2D2_0p1ppm_B1_neg_201609019_005',... 
                'QC-old-PGE2D2_0p1ppm_B1_neg_201609019_004',...
                'BlankSolv_B1_neg_201609019_001'});
            
            %% Annotate
            consensusDataAnnotator = workflow.getNode('ConsensusDataAnnotator');
            consensusDataAnnotator.getConfig()...
                .updateParamValue('HeadersToUse', {'Injection', 'TimePoint', 'Individual', 'AcquisitionDatetime','MSBatch','BiologicalReplicate', 'MSSequenceNumber', 'MSSampleType', 'MSPolarity'})...
                .updateParamValue('UserIdHeader', 'UserFileName');
            
            %% Plots
            viewConsensusDataAnnotator = workflow.getNode('ViewConsensusDataAnnotator');
            viewConsensusDataAnnotator.getConfig()...
                .updateParamValue('ViewParameters', {{'LabelFormat', {'SampleType:([^_]*)'}}});
            
            pcaConsensusDataAnnotator = workflow.getNode('ViewPcaConsensusDataAnnotator');
            pcaConsensusDataAnnotator.getConfig()...
                .updateParamValue('ViewParameters', {{'GroupList', {'MSSampleType'}, 'LabelFormat', {'MSSampleType:([^_]*)'}}});
            
            
            %% Plots Blank Filter
            viewBlankFilter = workflow.getNode('ViewBlankFilter');
            viewBlankFilter.getConfig()...
                .updateParamValue('ViewParameters', {{'LabelFormat', {'SampleType:([^_]*)'}}});
            
            pcaBlankFilter = workflow.getNode('ViewPcaBlankFilter');
            pcaBlankFilter.getConfig()...
                .updateParamValue('ViewParameters', {{'GroupList', {'MSSampleType'}, 'LabelFormat', {'MSSampleType:([^_]*)'}}});
            
            %% Filter by 80 %
            percentageRuleFilter = workflow.getNode('PercentageRuleFilter');          
            percentageRuleFilter.getConfig()...
                .updateParamValue('PercentageRuleThreshold', 0.8)...
                .updateParamValue('GroupList', {'Injection:Cond1', 'Injection:Cond2','Injection:CTL'});

            %% Plots 80% Perc
            viewPercentageRuleFilter = workflow.getNode('ViewPercentageRuleFilter');
            viewPercentageRuleFilter.getConfig()...
                .updateParamValue('ViewParameters', {{'LabelFormat', {'SampleType:([^_]*)'}}});
            
            pcaPercentageRuleFilter = workflow.getNode('ViewPcaPercentageRuleFilter');
            pcaPercentageRuleFilter.getConfig()...
                .updateParamValue('ViewParameters', {{'GroupList', {'MSSampleType'}, 'LabelFormat', {'MSSampleType:([^_]*)'}}});
            
            %% FilterCv 20%
            qcCvFilter = workflow.getNode('QcCvFilter');
            qcCvFilter.getConfig().updateParamValue('QcCvThreshold', 0.2);
            qcCvFilter.getConfig().updateParamValue('PercentageRuleThreshold', 0);
            qcCvFilter.getConfig().updateParamValue('LoQ', 1e4);
            
            %% Plots QcCv
   
            pcaQcCvFilter = workflow.getNode('ViewPcaQcCvFilter');
            pcaQcCvFilter.getConfig()...
                .updateParamValue('ViewParameters', {{'GroupList', {'MSSampleType'}, 'LabelFormat', {'MSSampleType:([^_]*)'}}});
            
            %%  Drift Correction Intra
            intraBatchDriftCorrector = workflow.getNode('IntraBatchDriftCorrector');
            intraBatchDriftCorrector.getConfig()...
                .updateParamValue('NbFirstQcToIgnore', 4)...
                .updateParamValue('LoQ', 1e4);
            
            %% Plots Intra
            
            pcaIntraBatchDriftCorrector = workflow.getNode('ViewPcaIntraBatchDriftCorrector');
            pcaIntraBatchDriftCorrector.getConfig()...
                .updateParamValue('ViewParameters', {{'GroupList', {'MSSampleType'}, 'LabelFormat', {'MSSampleType:([^_]*)'}}});
            
            %%  Drift Correction Inter
            interBatchDriftCorrector = workflow.getNode('InterBatchDriftCorrector');
            interBatchDriftCorrector.getConfig()...
                .updateParamValue('NbFirstQcToIgnore', 0)...
                .updateParamValue('LoQ', 1e4);

            %% Plots Inter
 
            pcaInterBatchDriftCorrector = workflow.getNode('ViewPcaInterBatchDriftCorrector');
            pcaInterBatchDriftCorrector.getConfig()...
                .updateParamValue('ViewParameters', {{'GroupList', {'MSSampleType'}, 'LabelFormat', {'MSSampleType:([^_]*)'}}});
            
        end
    end
    
end

