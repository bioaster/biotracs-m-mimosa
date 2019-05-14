classdef GapFillerTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs/mimosa/GapFillerTests');
    end
    
    
    methods (Test)
        
        function testGapFiller(testCase)
            rowNameKeyValPatterns = {...
                'BatchPattern', 'MSBatch:([^_]*)', ...
                'SamplePattern', 'MSSampleType:Sample', ...
                'QcPattern', 'MSSampleType:QC', ...
                'SequenceNumberPattern', 'SeqNb:([^_]*)'};
            featureMatrix = biotracs.spectra.data.model.MSFeatureSet.import(...
                '../../../testdata/GapFilling/FeatureSetBeforeGapFilling.csv', ...
                rowNameKeyValPatterns{:} ...
                );
            
            % Without gap filling (LoQ = 0)
            process = biotracs.mimosa.model.GapFiller();
            c = process.getConfig();
            process.setInputPortData( 'FeatureSet',  featureMatrix );
            c.updateParamValue('LoQ', 0);
            c.updateParamValue('WorkingDirectory', testCase.workingDir);
            process.run();
            gapFilledFeatureSet = process.getOutputPortData('FeatureSet');
            gapFilledFeatureSet.export([ testCase.workingDir, '/FeatureSetWithoutGapFilling.csv' ]);
            testCase.verifyTrue( featureMatrix == gapFilledFeatureSet );
            testCase.verifyTrue( process.isPhantom );
            
            % With gap filling
            process = biotracs.mimosa.model.GapFiller();
            c = process.getConfig();
            process.setInputPortData( 'FeatureSet',  featureMatrix );
            c.updateParamValue('LoQ', 1e4);
            c.updateParamValue('WorkingDirectory', testCase.workingDir);
            process.run();
            gapFilledFeatureSet = process.getOutputPortData('FeatureSet');
            gapFilledFeatureSet.export([ testCase.workingDir, '/FeatureSetWithGapFilling.csv' ]);
            testCase.verifyTrue( sum(sum(featureMatrix.data == 0)) > 0 );
            testCase.verifyFalse( sum(sum(gapFilledFeatureSet.data == 0)) > 0 );
        end
        
        
    end
    
end
