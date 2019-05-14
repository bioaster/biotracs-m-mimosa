classdef MultiplicationFactorTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs/mimosa/MultiplicationFactorTests');
    end
    
    
    methods (Test)
        
        function testMultiplicativeFactor(testCase)
             featureMatrix = biotracs.spectra.data.model.MSFeatureSet.import(...
                '../../../testdata/Filtering/FeatureSetInputBlankFilter.csv' );
            
            % Without multiplicative factor
            process = biotracs.mimosa.model.MultiplicationFactor();
            c = process.getConfig();
            process.setInputPortData( 'FeatureSet',  featureMatrix );
            c.updateParamValue('ColumnName', '');
            c.updateParamValue('WorkingDirectory', testCase.workingDir);
            process.run();
            normalizedFeatureSet = process.getOutputPortData('FeatureSet');
            
            normalizedFeatureSet.export([ testCase.workingDir, '/FeatureSetWithoutMultiplicativeFactor.csv' ]);
            testCase.verifyTrue( featureMatrix == normalizedFeatureSet );
            testCase.verifyTrue( process.isPhantom );
            
            % With gap filling
            process = biotracs.mimosa.model.MultiplicationFactor();
            c = process.getConfig();
            process.setInputPortData( 'FeatureSet',  featureMatrix );
            c.updateParamValue('ColumnName', 'SeqNb');
            c.updateParamValue('WorkingDirectory', testCase.workingDir);
            process.run();
            normalizedFeatureSet = process.getOutputPortData('FeatureSet');
            
            normalizedFeatureSet.export([ testCase.workingDir, '/FeatureSetWithMultiplicativeFactor.csv' ], 'WriteColumnNames', true);
%             testCase.verifyTrue( sum(sum(featureMatrix.data == 0)) > 0 );
%             testCase.verifyFalse( sum(sum(gapFilledFeatureSet.data == 0)) > 0 );
        end
        
        
    end
    
end
