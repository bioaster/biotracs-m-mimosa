classdef ConsensusExtDataTableTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs/mimosa/ConsensusExtDataTableTests');
    end
    
    
    methods (Test)
        
        function testExperiment(testCase)
            filePath = '../../../testdata/SingleModePreprocessing/BlankExtrac_B1_neg_201609019_057.csv';
            extDataTable = biotracs.mimosa.model.ConsensusExtDataTable.import( ...
                filePath, 'NbHeaderLines', 1 );
            testCase.verifyClass(extDataTable, 'biotracs.mimosa.model.ConsensusExtDataTable');
            testCase.verifyEqual(extDataTable.getElementNames(), {'MAP', 'RUN', 'PROTEIN', 'UNASSIGNEDPEPTIDE', 'CONSENSUS', 'PEPTIDE'}  )
            testCase.verifyClass(extDataTable.get('CONSENSUS'), 'biotracs.data.model.DataTable');
            testCase.verifyEqual(getSize(extDataTable.get('CONSENSUS')), [365, 646]);
            extDataTable.summary();
        end
        
        
    end
    
end


