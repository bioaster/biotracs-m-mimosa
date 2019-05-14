classdef MergingGroupingWorkflowTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs/mimosa/MergingGroupingWorkflowTests');
    end
    
    
    methods (Test)
        
        function testWorkflow(testCase)
            
            workflow = biotracs.mimosa.model.MergingGroupingWorkflow();
            workflow.getConfig().updateParamValue( 'WorkingDirectory', [testCase.workingDir] );
            
            %% Input Mode Pos
            posFeatureSetFileImporter = workflow.getNode('PosFeatureSetFileImporter');
            posFeatureSetFileImporter.addInputFilePath( '../../../testdata/MergingGrouping/BlankExtrac_B3_pos_20160926_057.csv' );

            %% Input Mode Neg
            negFeatureSetFileImporter = workflow.getNode('NegFeatureSetFileImporter');
            negFeatureSetFileImporter.addInputFilePath( '../../../testdata/MergingGrouping/BlankExtrac_B1_neg_201609019_057.csv' );
            
            merger = workflow.getNode('FeatureSetMerger');
            merger.getConfig()...
                .updateParamValue('AnnotationNamesForMerging', {'Injection:Cond2','TimePoint:D0','Individual:2','BiologicalReplicate','MSSampleType'});
            
            workflow.run();
            
            % FeatureGrouping view
            featureGrouping = workflow.getNode('FeatureGrouper' );
            results = featureGrouping.getOutputPortData('AdductMatrix');
            results.view('FeatureGroupingPlot');
            resultsAdductsReducedMatrix = featureGrouping.getOutputPortData('AdductFeatureSet');

            expectedOutData = biotracs.data.model.DataMatrix.import('../../../testdata/MergingGrouping/AdductsReducedMatrix.csv');
            idx = (results.data > 1e4); %do not test random numbers (gap filling)
            testCase.verifyEqual(resultsAdductsReducedMatrix.data(idx), expectedOutData.data(idx), 'RelTol', 1e-3);
        end
        
        function testWorkflowPosPolarity(testCase)
            
            workflow = biotracs.mimosa.model.MergingGroupingWorkflow();
            workflow.getConfig().updateParamValue( 'WorkingDirectory', [testCase.workingDir, '/PosPolarity'] );
            
            %% Input Mode Pos
            posFeatureSetFileImporter = workflow.getNode('PosFeatureSetFileImporter');
            posFeatureSetFileImporter.addInputFilePath( '../../../testdata/MergingGrouping/BlankExtrac_B3_pos_20160926_057.csv' );

            %% Input Mode Neg
%             negFeatureSetFileImporter = workflow.getNode('NegFeatureSetFileImporter');
%             negFeatureSetFileImporter.addInputFilePath( '../../../testdata/MergingGrouping/BlankExtrac_B1_neg_201609019_057.csv' );
            
            workflow.run();
            
            % FeatureGrouping view
            featureGrouping = workflow.getNode('FeatureGrouper' );
            results = featureGrouping.getOutputPortData('AdductMatrix');
            results.view('FeatureGroupingPlot');
%             resultsAdductsReducedMatrix = featureGrouping.getOutputPortData('AdductFeatureSetFileExporter');

%             expectedOutData = biotracs.data.model.DataMatrix.import('../../../testdata/MergingGrouping/AdductsReducedMatrix.csv');
%             idx = (results.data > 1e4); %do not test random numbers (gap filling)
%             testCase.verifyEqual(resultsAdductsReducedMatrix.data(idx), expectedOutData.data(idx), 'RelTol', 1e-3);
        end
        
         function testWorkflowNegPolarity(testCase)
            
            workflow = biotracs.mimosa.model.MergingGroupingWorkflow();
            workflow.getConfig().updateParamValue( 'WorkingDirectory', [testCase.workingDir, '/NegPolarity'] );
            
            %% Input Mode Pos
%             posFeatureSetFileImporter = workflow.getNode('PosFeatureSetFileImporter');
%             posFeatureSetFileImporter.addInputFilePath( '../../../testdata/MergingGrouping/BlankExtrac_B3_pos_20160926_057.csv' );

            %% Input Mode Neg
            negFeatureSetFileImporter = workflow.getNode('NegFeatureSetFileImporter');
            negFeatureSetFileImporter.addInputFilePath( '../../../testdata/MergingGrouping/BlankExtrac_B1_neg_201609019_057.csv' );
            
            workflow.run();
            
            % FeatureGrouping view
            featureGrouping = workflow.getNode('FeatureGrouper' );
            results = featureGrouping.getOutputPortData('AdductMatrix');
            results.view('FeatureGroupingPlot');
%             resultsAdductsReducedMatrix = featureGrouping.getOutputPortData('AdductFeatureSetFileExporter');

%             expectedOutData = biotracs.data.model.DataMatrix.import('../../../testdata/MergingGrouping/AdductsReducedMatrix.csv');
%             idx = (results.data > 1e4); %do not test random numbers (gap filling)
%             testCase.verifyEqual(resultsAdductsReducedMatrix.data(idx), expectedOutData.data(idx), 'RelTol', 1e-3);
        end
    end
    
end

