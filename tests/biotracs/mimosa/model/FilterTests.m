classdef FilterTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs/mimosa/FilterTests');
    end
    
    
    methods (Test)
        function testQcCvFilter(testCase)
            rowNameKeyValPatterns = {...
                'BatchPattern', 'Batch:([^_]*)', ...
                'SamplePattern', 'SampleType:Sample', ...
                'QcPattern', 'SampleType:QC', ...
                'SequenceNumberPattern', 'SeqNb:([^_]*)'};
            
            featureMatrix = biotracs.spectra.data.model.MSFeatureSet.import(...
                '../../../testdata/Filtering/FeatureSetInputQcCvFilter.csv', ...
                rowNameKeyValPatterns{:} ...
                );
            
           
            process = biotracs.mimosa.model.Filter();
            c = process.getConfig();
            process.setInputPortData('FeatureSet', featureMatrix);
            c.updateParamValue('WorkingDirectory', testCase.workingDir);
            c.updateParamValue('LoQ', 1e4);
            c.updateParamValue('PercentageRuleThreshold', 0);
            c.updateParamValue('QcCvThreshold', 0.2);
            c.updateParamValue('GroupList', {'SampleType:QC'});
            c.updateParamValue('NameQcToIgnore', ...
                {'QC_B3_pos_20160926_004',...
                'QC_B3_pos_20160926_005', ...
                'QC_B3_pos_20160926_006', ...
                'QC_B3_pos_20160926_007', ...
                'QC_B3_pos_20160926_008', ...
                'QC_B3_pos_HCD10-20_20160926_055', ...
                'QC_B3_pos_HCD_40-60_20160926_056', ...
                'QC_B4_pos_20160928_004', ...
                'QC_B4_pos_20160928_005', ...
                'QC_B4_pos_20160928_006', ...
                'QC_B4_pos_20160928_007', ...
                'QC_B4_pos_HCD10-20_20160928_063', ...
                'QC_B4_pos_HDC_40-60_20160928_064'});
            process.run();
            filteredFeatureSet = process.getOutputPortData('FeatureSet');            
            qcCvDm = process.getOutputPortData('QcCvDataMatrix');            
            qcCvDm.export([testCase.workingDir, '/qcCV2Batches.csv']);
            expectedFilteredFeatureSet  = biotracs.spectra.data.model.MSFeatureSet.import(...
                '../../../testdata/Filtering/FeatureSetOutputQcCvFilter.csv');
            testCase.verifyEqual(filteredFeatureSet.data, expectedFilteredFeatureSet.data, 'RelTol', 1e-6 );
            
        end
        
        function testQcCvFilter3Batches(testCase)
            rowNameKeyValPatterns = {...
                'BatchPattern', 'Batch:([^_]*)', ...
                'SamplePattern', 'SampleType:Sample', ...
                'QcPattern', 'SampleType:QC', ...
                'SequenceNumberPattern', 'SeqNb:([^_]*)'};
         
            featureMatrix = biotracs.spectra.data.model.MSFeatureSet.import(...
                '../../../testdata/Filtering/FeatureSetInputQcCvFilter3Batches.csv', ...
                rowNameKeyValPatterns{:} ...
                );
            
            process = biotracs.mimosa.model.Filter();
            c = process.getConfig();
            process.setInputPortData('FeatureSet', featureMatrix);
            c.updateParamValue('WorkingDirectory', testCase.workingDir);
            c.updateParamValue('LoQ', 1e4);
            c.updateParamValue('PercentageRuleThreshold', 0);
            c.updateParamValue('QcCvThreshold', 0.2);
            c.updateParamValue('GroupList', {'SampleType:QC'});
            c.updateParamValue('NameQcToIgnore', ...
                {'QC_B3_pos_20160926_004',...
                'QC_B3_pos_20160926_005', ...
                'QC_B3_pos_20160926_006', ...
                'QC_B3_pos_20160926_007', ...
                'QC_B3_pos_20160926_008', ...
                'QC_B3_pos_HCD10-20_20160926_055', ...
                'QC_B3_pos_HCD_40-60_20160926_056', ...
                'QC_B4_pos_20160928_004', ...
                'QC_B4_pos_20160928_005', ...
                'QC_B4_pos_20160928_006', ...
                'QC_B4_pos_20160928_007', ...
                'QC_B4_pos_HCD10-20_20160928_063', ...
                'QC_B4_pos_HDC_40-60_20160928_064'});
            process.run();
            filteredFeatureSet = process.getOutputPortData('FeatureSet');
            qcCvDm = process.getOutputPortData('QcCvDataMatrix');
            qcCvDm.export([testCase.workingDir, '/qcCV3Batches.csv']);
           
            expectedFilteredFeatureSet  = biotracs.spectra.data.model.MSFeatureSet.import(...
                '../../../testdata/Filtering/FeatureSetOutputQcCvFilter3Batches.csv');
            testCase.verifyEqual(filteredFeatureSet.data, expectedFilteredFeatureSet.data, 'RelTol', 1e-6 );
            
        end
        
        function testPercRuleFilter(testCase)
%             return;
            rowNameKeyValPatterns = {...
                'BatchPattern', 'Batch:([^_]*)', ...
                'SamplePattern', 'SampleType:Sample', ...
                'QcPattern', 'SampleType:QC', ...
                'SequenceNumberPattern', 'SeqNb:([^_]*)'};
            
            featureMatrix = biotracs.spectra.data.model.MSFeatureSet.import(...
                '../../../testdata/Filtering/FeatureSetInputPercRuleFilter.csv', ...
                rowNameKeyValPatterns{:} ...
                );
            %QcOnly
            process = biotracs.mimosa.model.Filter();
            c = process.getConfig();
            process.setInputPortData('FeatureSet', featureMatrix);
            c.updateParamValue('WorkingDirectory', testCase.workingDir);
            c.updateParamValue('LoQ', 1e4);
            c.updateParamValue('PercentageRuleThreshold', 0.8);
            c.updateParamValue('QcCvThreshold', []);
            %             c.updateParamValue('GroupList', {'Injection:Cond1', 'Injection:Cond2','Injection:CTL'});
            c.updateParamValue('MethodOfFiltering', 'QcOnly');
            process.run();
            filteredFeatureSetQcOnly = process.getOutputPortData('FeatureSet');
            filteredFeatureSetQcOnly.export([ testCase.workingDir, '/filteredFeatureSet_PercRule_QcOnly.csv' ]);
            expectedFilteredFeatureSetQcOnly  = biotracs.spectra.data.model.MSFeatureSet.import(...
                '../../../testdata/Filtering/FilteredFeatureSet_PercRule_QcOnly.csv');
            
            testCase.verifyEqual(filteredFeatureSetQcOnly.data, expectedFilteredFeatureSetQcOnly.data, 'RelTol', 1e-6 );
            
            
            %QcAndSample
            process = biotracs.mimosa.model.Filter();
            c = process.getConfig();
            process.setInputPortData('FeatureSet', featureMatrix);
            c.updateParamValue('WorkingDirectory', testCase.workingDir);
            c.updateParamValue('LoQ', 1e4);
            c.updateParamValue('PercentageRuleThreshold', 0.8);
            c.updateParamValue('QcCvThreshold', []);
            c.updateParamValue('GroupList', {'Injection:Cond1', 'Injection:Cond2','Injection:CTL'});
            c.updateParamValue('MethodOfFiltering', 'QcAndSample');
            process.run();
            filteredFeatureSetQcAndSample = process.getOutputPortData('FeatureSet');
            filteredFeatureSetQcAndSample.export([ testCase.workingDir, '/filteredFeatureSet_PercRule_QcAndSample.csv' ]);
            expectedFilteredFeatureSetQcAndSample  = biotracs.spectra.data.model.MSFeatureSet.import(...
                '../../../testdata/Filtering/FilteredFeatureSet_PercRule_QcAndSample.csv');
            
            testCase.verifyEqual(filteredFeatureSetQcAndSample.data, expectedFilteredFeatureSetQcAndSample.data, 'RelTol', 1e-6 );
            
            
            %QcOrSample
            process = biotracs.mimosa.model.Filter();
            c = process.getConfig();
            process.setInputPortData('FeatureSet', featureMatrix);
            c.updateParamValue('WorkingDirectory', testCase.workingDir);
            c.updateParamValue('LoQ', 1e4);
            c.updateParamValue('PercentageRuleThreshold', 0.8);
            c.updateParamValue('QcCvThreshold', []);
            c.updateParamValue('GroupList', {'Injection:Cond1', 'Injection:Cond2','Injection:CTL'});
            c.updateParamValue('MethodOfFiltering', 'QcOrSample');
            process.run();
            filteredFeatureSetQcOrSample = process.getOutputPortData('FeatureSet');
            filteredFeatureSetQcOrSample.export([ testCase.workingDir, '/filteredFeatureSet_PercRule_QcOrSample.csv' ]);
            
            expectedFilteredFeatureSetQcOrSample  = biotracs.spectra.data.model.MSFeatureSet.import(...
                '../../../testdata/Filtering/FilteredFeatureSet_PercRule_QcOrSample.csv');
            
            testCase.verifyEqual(filteredFeatureSetQcOrSample.data, expectedFilteredFeatureSetQcOrSample.data, 'RelTol', 1e-6 );
        end
        
        function testRemoveFeaturesInBlank(testCase)
%             return;
            featureMatrix = biotracs.spectra.data.model.MSFeatureSet.import(...
                '../../../testdata/Filtering/FeatureSetInputBlankFilter.csv');
            
            process = biotracs.mimosa.model.Filter();
            c = process.getConfig();
            process.setInputPortData('FeatureSet', featureMatrix);
            c.updateParamValue('WorkingDirectory', testCase.workingDir);
            c.updateParamValue('LoQ', 1e4);
            c.updateParamValue('PercentageRuleThreshold', 0);
            c.updateParamValue('QcCvThreshold', []);
            c.updateParamValue('BlankIntensityRatio', 3);
            process.run();
            
            filteredFeatureSet = process.getOutputPortData('FeatureSet');
            filteredFeatureSet.export([ testCase.workingDir, '/filteredFeatureInBlank.csv' ]);
            expectedFilteredFeatureSet  = biotracs.spectra.data.model.MSFeatureSet.import(...
                '../../../testdata/Filtering/FilteredFeatureInBlank.csv');
            
            testCase.verifyEqual(filteredFeatureSet.data, expectedFilteredFeatureSet.data, 'RelTol', 1e-6 );
        end
    end
    
end

