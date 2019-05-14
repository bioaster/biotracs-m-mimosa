classdef FeatureMergerTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs/mimosa/FeatureMergerTests');
    end
    
    
    methods (Test)
        
        function testFeatureMerger(testCase)
%             return;
            negFeatureMatrixPath = '../../../testdata/MergingGrouping/BlankExtrac_B1_neg_201609019_057.csv';
            posFeatureMatrixPath = '../../../testdata/MergingGrouping/BlankExtrac_B3_pos_20160926_057.csv';
            posFeatureMatrix = biotracs.spectra.data.model.MSFeatureSet.import( ...
                posFeatureMatrixPath);
            negFeatureMatrix = biotracs.spectra.data.model.MSFeatureSet.import( ...
                negFeatureMatrixPath);

            process = biotracs.mimosa.model.FeatureMerger();
            process.getConfig()...
                .updateParamValue('WorkingDirectory', testCase.workingDir);
            process.setInputPortData('PosFeatureSet', posFeatureMatrix);
            process.setInputPortData('NegFeatureSet',negFeatureMatrix);
            process.getConfig()...
                .updateParamValue('AnnotationNamesForMerging', {'Injection', 'TimePoint','Individual', 'MSSampleType)'});
            process.run();
            featureMatrix = process.getOutputPortData('FeatureSet');

            [posMz, posRt, ~] = posFeatureMatrix.getMzRtPolarity();
            [negMz, negRt, ~] = negFeatureMatrix.getMzRtPolarity();
            [mz, rt, polarity] = featureMatrix.getMzRtPolarity();
            
            testCase.verifyTrue( length(posMz)+length(negMz) == length(mz) );
            testCase.verifyTrue( length(posRt)+length(negRt) == length(rt) );
            testCase.verifyTrue( all(ismember(posMz, mz)) );
            testCase.verifyTrue( all(ismember(negMz, mz)) );
            testCase.verifyTrue( all(ismember({'Neg','Pos'}, unique(polarity))) )
        end
        
          function testFeatureMergerPosPolarity(testCase)
%               return;
            posFeatureMatrixPath = '../../../testdata/MergingGrouping/BlankExtrac_B3_pos_20160926_057.csv';
            posFeatureMatrix = biotracs.spectra.data.model.MSFeatureSet.import( ...
                posFeatureMatrixPath);

            process = biotracs.mimosa.model.FeatureMerger();
            process.getConfig()...
                .updateParamValue('WorkingDirectory', testCase.workingDir);
            process.setInputPortData('PosFeatureSet', posFeatureMatrix);
             process.setInputPortData('NegFeatureSet', biotracs.spectra.data.model.MSFeatureSet());
            process.getConfig()...
                .updateParamValue('AnnotationNamesForMerging', {'Injection', 'TimePoint','Individual', 'MSSampleType)'});
            process.run();
            featureMatrix = process.getOutputPortData('FeatureSet');
            testCase.verifyEqual(posFeatureMatrix, featureMatrix);

          end
        
           function testFeatureMergerNegPolarity(testCase)
%               return;
            negFeatureMatrixPath ='../../../testdata/MergingGrouping/BlankExtrac_B1_neg_201609019_057.csv';
            negFeatureMatrix = biotracs.spectra.data.model.MSFeatureSet.import( ...
                negFeatureMatrixPath);

            process = biotracs.mimosa.model.FeatureMerger();
            process.getConfig()...
                .updateParamValue('WorkingDirectory', testCase.workingDir);
            process.setInputPortData('PosFeatureSet', biotracs.spectra.data.model.MSFeatureSet());
            process.setInputPortData('NegFeatureSet', negFeatureMatrix);

            process.getConfig()...
                .updateParamValue('AnnotationNamesForMerging', {'Injection', 'TimePoint','Individual', 'MSSampleType)'});
            process.run();
            featureMatrix = process.getOutputPortData('FeatureSet');
            
            testCase.verifyEqual(negFeatureMatrix, featureMatrix);

        end
    end
    
end


