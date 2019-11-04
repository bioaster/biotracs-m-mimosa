%"""
%Unit tests for biotracs.mimosa.*
%* License: BIOASTER License
%* Created: 2018
%Bioinformatics team, Omics Hub, BIOASTER Technology Research Institute (http://www.bioaster.org)
%"""

function testMimosa( cleanAll )
    if nargin == 0 || cleanAll
        clc; close all force; clear classes;
        restoredefaultpath();
    end
    
    addpath('../../')
    autoload( ...
        'PkgPaths', {fullfile(pwd, '../../../../')}, ...
        'Dependencies', {...
        'biotracs-m-mimosa', ...
        }, ...
        'Variables',  struct(...
        'OpenMSBinPath', 'C:/Program Files/OpenMS-2.3.0/bin/', ...
        'MzConvertFilePath', 'C:\Program Files\ProteoWizard\ProteoWizard 3.0.9992\msconvert.exe' ...
        ) ...
        );

    %% Tests
    import matlab.unittest.TestSuite;    
%     Tests = TestSuite.fromFolder('./', 'IncludingSubfolders', true);

%     Tests = TestSuite.fromFile('./controller/ControllerTests.m');
%     Tests = TestSuite.fromFile('./model/GapFillerTests.m');
    Tests = TestSuite.fromFile('./model/FilterTests.m');
%     Tests = TestSuite.fromFile('./model/DriftCorrectorTests.m');
%     Tests = TestSuite.fromFile('./model/FeatureGrouperTests.m');
%     Tests = TestSuite.fromFile('./model/ConsensusDataExtractorTests.m');
%     Tests = TestSuite.fromFile('./model/ConsensusExtDataTableTests.m');
%     Tests = TestSuite.fromFile('./model/MultiplicationFactorTests.m');
%     Tests = TestSuite.fromFile('./model/SingleModePreprocessingWorkflowTests.m');
%     Tests = TestSuite.fromFile('./model/MergingGroupingWorkflowTests.m');
%     Tests = TestSuite.fromFile('./model/PreprocessingWorkflowTests.m');
%     Tests = TestSuite.fromFile('./model/FeatureSummaryTests.m');
%     Tests = TestSuite.fromFile('./model/FeatureUngrouperTests.m');
%     Tests = TestSuite.fromFile('./model/FeatureMergerTests.m');
%     Tests = TestSuite.fromFile('./model/DesignTableTests.m');
%     Tests = TestSuite.fromFile('./model/UserConfigTableTests.m');

    Tests.run;
end