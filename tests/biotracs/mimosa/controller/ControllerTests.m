classdef ControllerTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs/mimosa/ControllerTests');
    end
    
    
    methods (Test)
        function testWorkflowConvertActionConfig(testCase)
            return;
            ctrl = biotracs.mimosa.controller.Controller(...
                'Batches', {'1','2'}, ...
                'Polarities', {'Neg', 'Pos'}, ...
                'ConfigFilePath', '../../../testdata/config5.txt' ...
                );
            
            ctrl.convertAction( );
        end
        
        function testWorkflowAllActionConfig(testCase)
            %             return;
            ctrl = biotracs.mimosa.controller.Controller(...
                'Batches', { '1', '2', '1_2'}, ...
                'Polarities', {'Neg', 'Pos', 'NegPos'}, ...
                'ConfigFilePath', '../../../testdata/config5.txt' ...
                );
            
            
            ctrl.convertAction( );
            ctrl.extractionAction( );
            ctrl.linkingAction( );
            ctrl.preprocessingAction( );
        end
        
%         function testWorkflowExtractActionConfig(testCase)
%             return;
%             ctrl = biotracs.mimosa.controller.Controller(...
%                 'Batches', {'1','2'}, ...
%                 'Polarities', {'Neg', 'Pos'}, ...
%                 'ConfigFilePath', '../../../testdata/config4.txt' ...
%                 );
%             
%             ctrl.extractionAction( );
%         end
%         
%         function testWorkflowLinkingActionConfig(testCase)
%             return;
%             ctrl = biotracs.mimosa.controller.Controller(...
%                 'Batches', {'1','2'}, ...
%                 'Polarities', {'Neg', 'Pos'}, ...
%                 'ConfigFilePath', '../../../testdata/config4.txt' ...
%                 );
%             
%             ctrl.linkingAction( );
%         end
%         
%         function testWorkflowPreProcessingActionConfig(testCase)
%             return;
%             ctrl = biotracs.mimosa.controller.Controller(...
%                 'Batches', {'1', '2', '1_2'}, ...
%                 'Polarities', {'Neg','Pos', 'NegPos'}, ...
%                 'ConfigFilePath', '../../../testdata/config4.txt' ...
%                 );
%             
%             ctrl.preprocessingAction( );
%         end
%         
%         function testWorkflowNoNameDesign(testCase)
%             return;
%             ctrl = biotracs.mimosa.controller.Controller(...
%                 'Batches', {'1', '2', '1_2'}, ...
%                 'Polarities', {'Neg','Pos', 'NegPos'}, ...
%                 'ConfigFilePath', '../../../testdata/config6.txt' ...
%                 );
%             
%             ctrl.preprocessingAction( );
%             
%         end
    end
end
