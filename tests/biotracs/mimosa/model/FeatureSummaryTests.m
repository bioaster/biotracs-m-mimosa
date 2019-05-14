classdef FeatureSummaryTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs/mimosa/FeatureSummaryTests');
    end
    
    
    methods (Test)
        
        function testWorkflowConvertActionConfig(testCase)
            originalFeatureSetPath ='../../../testdata/Features/originalFeatureSet.csv';
            qcCV = '../../../testdata/Features/qcCvPerBatch.csv';
            listFeaturesSelected = '../../../testdata/Features/ungroupedFeatures.csv';
            originalFeatureSet = biotracs.spectra.data.model.MSFeatureSet.import(originalFeatureSetPath);
            qcCV = biotracs.data.model.DataMatrix.import(qcCV);
            listFeaturesSelected = biotracs.data.model.DataTable.import(listFeaturesSelected);
            
            ctrl = biotracs.mimosa.model.FeatureSummary();
            ctrl.setInputPortData('OriginalFeatureSet', originalFeatureSet);
            ctrl.setInputPortData('QcCVPerBatch', qcCV);
            ctrl.setInputPortData('UngroupedFeaturesSelected', listFeaturesSelected);
            ctrl.getConfig()...
                .updateParamValue('WorkingDirectory', [testCase.workingDir, '/FeatureSummary']);
            ctrl.run( );
            
            resourceSet = ctrl.getOutputPortData('ResourceSet');
            hold off
            resourceSet.view('FeatureSummaryPlot');
        end
        
        
        
        
    end
end
