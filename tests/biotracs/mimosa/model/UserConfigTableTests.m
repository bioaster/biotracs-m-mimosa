classdef UserConfigTableTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs/mimosa/UserConfigTableTests');
    end
    
    
    methods (Test)
        
        function testWorkflowConvertAction(testCase)   
            extDt = biotracs.mimosa.model.UserConfigTable.import('../../../testdata/config5.csv', ...
                'NbHeaderLines', 1);
  
            testCase.assertEqual( extDt.get('CONVERT').getNbDesigns(), 4 );
            testCase.assertEqual( extDt.get('EXTRACT').getNbDesigns(), 4 );
            testCase.assertEqual( extDt.get('LINK').getNbDesigns(), 6 );
            testCase.assertEqual( extDt.get('PREPROCESS').getNbDesigns(), 5 );
        end
         
    end
end
