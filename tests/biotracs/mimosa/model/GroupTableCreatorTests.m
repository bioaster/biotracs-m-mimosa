classdef GroupTableCreatorTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs/mimosa/GroupTableCreatorTests');
    end
    
    methods (Test)
        
        function testMetIdentifier(testCase)
%             dataSet = biotracs.spectra.data.model.MSFeatureSet.import( [pwd, '/../../../testdata/data.mat'] );
%             process = biotracs.metid.model.GroupTableCreator();
%             process.setInputPortData('IsoFeatureTable', dataSet);
%             c = process.getConfig();
%             c.updateParamValue('WorkingDirectory', testCase.workingDir);
%             process.run();
%             result = process.getOutputPortData('GroupTable');
%             ms1Found = result.getDataByColumnName('Ms1PrecursorMz');
%             ms1Searched = result.getDataByColumnName('MzSearchedPrecursor');
%             idxMs1Found = cellfun(@(x) ~isempty(x), ms1Found);
%             ms1SearchedResult = ms1Searched(idxMs1Found == 1);
%             ms1FoundResult = ms1Found(idxMs1Found == 1 );
%             ms1SearchedResult = cellfun(@(x) str2num(x), ms1SearchedResult);
%             ms1FoundResult = cellfun(@(x) str2num(x), ms1FoundResult);
%             testCase.verifyEqual(ms1SearchedResult,  ms1FoundResult , 'AbsTol', 1e-3 );
%             testCase.verifyEqual(result.getSize(), [10,10]);
%             expectedOutputFilePaths = fullfile([ testCase.workingDir, '/config.params.xml']);
%             testCase.verifyEqual( exist(expectedOutputFilePaths, 'file'), 2 );
%             testCase.verifyClass( result, 'biotracs.data.model.DataTable' );
        end
        
    end
    
    
end