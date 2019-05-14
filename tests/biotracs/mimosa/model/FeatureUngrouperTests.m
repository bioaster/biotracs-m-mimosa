classdef FeatureUngrouperTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs/mimosa/FeatureUngrouperTests');
    end
    
    
    methods (Test)
        
        function testFeatureUngrouper(testCase)
            return;
            selectedfeatures = biotracs.spectra.data.model.MSFeatureSet.import(...
                '../../../testdata/Features\selectedFeatures.csv');
            groupedTable =biotracs.data.model.DataTable.import(...
                '../../../testdata/Features\groupedFeatures.csv');
            
            
            ctrl = biotracs.mimosa.model.FeatureUngrouper();
            ctrl.setInputPortData('GroupedTable', groupedTable);
            ctrl.setInputPortData('ListFeaturesSelected', selectedfeatures);
            ctrl.getConfig()...
                .updateParamValue('Direction', 'Column') ...
                .updateParamValue('WorkingDirectory', [testCase.workingDir, '/FeatureUngrouper']);
            ctrl.run( );
            ungroupedTable = ctrl.getOutputPortData('UnGroupedTable');
            ungroupedTable.export([testCase.workingDir, '/FeatureUngrouper/ungroupedFeatures.csv']);
        end
        
                
        function testFeatureUngrouperByRow(testCase)

            selectedfeatures = biotracs.spectra.data.model.MSFeatureSet.import(...
                '../../../testdata/Features\selectedFeatures_ByRow.csv');
            groupedTable =biotracs.data.model.DataTable.import(...
                '../../../testdata/Features\groupedFeatures.csv');
        
            ctrl = biotracs.mimosa.model.FeatureUngrouper();
            ctrl.setInputPortData('GroupedTable', groupedTable);
            ctrl.setInputPortData('ListFeaturesSelected', selectedfeatures);
            ctrl.getConfig()...
                .updateParamValue('Direction', 'Row') ...
                .updateParamValue('WorkingDirectory', [testCase.workingDir, '/FeatureUngrouper']);
            ctrl.run( );
            ungroupedTable = ctrl.getOutputPortData('UnGroupedTable');
            ungroupedTable.export([testCase.workingDir, '/FeatureUngrouper/ungroupedFeatures.csv']);
        end
        
        
        
        
    end
end
