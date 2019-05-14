classdef ConsensusDataExtractorTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs/mimosa/ConsensusTableTests');
    end
    
    
    methods (Test)
        
        function testExperiment(testCase)
            iFeatureMatrix = '../../../testdata/SingleModePreprocessing/BlankExtrac_B1_neg_201609019_057.csv';
            extDataTable = biotracs.mimosa.model.ConsensusExtDataTable.import( iFeatureMatrix, 'NbHeaderLines', 1 );
            process = biotracs.mimosa.model.ConsensusDataExtractor();
            c = process.getConfig();
            c.updateParamValue('WorkingDirectory', testCase.workingDir);
            c.updateParamValue('Polarity', 'Neg');
            process.setInputPortData('ExtDataTable', extDataTable);
            process.run();
            featureMatrix = process.getOutputPortData('FeatureSet');
            featureMatrix.export([ testCase.workingDir, '/featureMatrix.csv' ]);
            %testCase.verifyEqual( getLength(featureMatrix), 1 );
        end

    end
    
end


