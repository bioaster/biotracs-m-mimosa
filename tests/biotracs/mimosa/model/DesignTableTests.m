classdef DesignTableTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs/mimosa/DesignTableTests');
    end
    
    
    methods (Test)
        
        function testDesignTable(testCase)
            extDt = biotracs.mimosa.model.UserConfigTable.import('../../../testdata/config5.txt', ...
                'NbHeaderLines', 1);
            
            extDt.get('CONVERT').summary();
            extDt.get('EXTRACT').summary();
            extDt.get('LINK').summary();
            extDt.get('PREPROCESS').summary();
            
            testCase.assertEqual( extDt.get('CONVERT').getNbDesigns(), 4 );
            testCase.assertEqual( extDt.get('EXTRACT').getNbDesigns(), 4 );
            testCase.assertEqual( extDt.get('LINK').getNbDesigns(), 6 );
            testCase.assertEqual( extDt.get('PREPROCESS').getNbDesigns(), 5 );
        end
        
    
    end
end
