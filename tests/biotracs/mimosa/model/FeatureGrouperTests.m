classdef FeatureGrouperTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs/mimosa/FeatureGrouperTests');
    end
    
    
    methods (Test)
        
        function testExperiment(testCase)
            rowNameKeyValPatterns = {...
                'BatchPattern', 'MSBatch:([^_]*)', ...
                'SamplePattern', 'MSSampleType:Sample', ...
                'QcPattern', 'MSSampleType:QC', ...
                'SequenceNumberPattern', 'SeqNb:([^_]*)'};
            featureMatrix = biotracs.spectra.data.model.MSFeatureSet.import(...
                '../../../testdata/Grouping/FeatureSetMerged.csv', ...
                rowNameKeyValPatterns{:} ...
                );

            process = biotracs.mimosa.model.FeatureGrouper();
            process.setInputPortData('FeatureSet', featureMatrix);
            process.run();

            adductsFeatureSet = process.getOutputPortData('AdductMatrix');
            adductsFeatureSet.view('FeatureGroupingPlot');
            adductsFeatureSet.export([ testCase.workingDir, '/adductsFeatureSet.csv' ]);
            
            reducedIsoFeatureSet = process.getOutputPortData('IsoFeatureSet');
            reducedAdductsFeatureSet = process.getOutputPortData('AdductFeatureSet');
            reducedIsoFeatureSet.export([ testCase.workingDir, '/reducedIsoFeatureSet.csv' ]);
            reducedAdductsFeatureSet.export([ testCase.workingDir, '/reducedAdductsFeatureSet.csv' ]);
            expectedOutputFilePaths = {...
                fullfile([ testCase.workingDir, '/adductsFeatureSet.csv']), ...
                fullfile([ testCase.workingDir, '/reducedIsoFeatureSet.csv']),...
                fullfile([ testCase.workingDir, '/reducedAdductsFeatureSet.csv']),...
                };
            
            testCase.verifyEqual( exist(expectedOutputFilePaths{1}, 'file'), 2 );
            testCase.verifyEqual( exist(expectedOutputFilePaths{2}, 'file'), 2 );
            testCase.verifyEqual( exist(expectedOutputFilePaths{3}, 'file'), 2 );
        end
        
        
    end
    
end

