%"""
%biotracs.mimosa.controller.Controller class
%Controller of the biotracs application MIMOSA
%* Date: 2018
%* License: BIOASTER software license
%* Keywords: *biotracs, mimosa, controller, mass spectrometry, preprocessing*
%
%Omics Hub, Bioinformatics team
%BIOASTER Technology Research Institute (http://www.bioaster.org)
%"""

classdef Controller < biotracs.core.mvc.controller.Controller
    
    properties(Constant)
    end
    
    properties(Access = protected)
        listOfBatches = {};
        listOfPolarities = {};
        configTable;
    end
    
    methods
        % Constructor
        function this = Controller( varargin )
            this@biotracs.core.mvc.controller.Controller ();
            this.doInit( varargin{:} );
        end
        
        
        
        %-- C --
        
        function  convertAction( this )
            convertDesign = this.configTable.get('CONVERT');
            nbDesigns = convertDesign.getNbDesigns();
            names = convertDesign.getNamesOfDesigns();
            for i=1:nbDesigns
                currentBatch = convertDesign.getFieldByDesignName('Batch', names{i});
                currentBatch = currentBatch{:};
                currentPolarity = convertDesign.getFieldByDesignName('Polarity', names{i});
                currentPolarity= currentPolarity{:};
                dataDirectory = convertDesign.getFieldByDesignName('DataDirectory',  names{i});
                dataDirectory = dataDirectory{:};
                workingDirectory = convertDesign.getFieldByDesignName('WorkingDirectory', names{i});
                workingDirectory= workingDirectory{:};
                processParams = convertDesign.getFieldByDesignName('ProcessParam', names{i});
                
                workflowName = strcat('MzConvertWorkflow_', currentBatch, '_', currentPolarity);
                w = this.get(workflowName);
                
                w.getConfig()...
                    .updateParamValue('WorkingDirectory', workingDirectory);
                
                try
                    w.writeParamValues( processParams{:} );
                catch exception
                    if strcmp(exception.identifier, 'BIOCODE:Parameter:InvalidArgument')
                        
                    else
                        
                    end
                end
                
                %configuration
                mzFileImporter = w.getNode('MzFileImporter');
                mzFileImporter.addInputFilePath(dataDirectory);
                mzFileImporter.getConfig()...
                    .updateParamValue('FileExtensionFilter', '.raw');
                w.run();
                
            end
            
        end
        
        %-- E --
        
        function extractionAction( this )
            convertDesign = this.configTable.get('EXTRACT');
            
            nbDesigns = convertDesign.getNbDesigns();
            names = convertDesign.getNamesOfDesigns();
            
            for i=1:nbDesigns
                currentBatch = convertDesign.getFieldByDesignName('Batch', names{i});
                currentBatch= currentBatch{:};
                currentPolarity = convertDesign.getFieldByDesignName('Polarity', names{i});
                currentPolarity= currentPolarity{:};
                %                 dataDirectory = convertDesign.getFieldByDesignName('DataDirectory',  names{i});
                %                 dataDirectory = dataDirectory{:};
                workingDirectory = convertDesign.getFieldByDesignName('WorkingDirectory', names{i});
                workingDirectory= workingDirectory{:};
                processParams = convertDesign.getFieldByDesignName('ProcessParam', names{i});
                
                workflowName = strcat('MetaboExtractionWorkflow_', currentBatch, '_', currentPolarity);
                %configuration
                mzConvertWorkflowName = strcat('MzConvertWorkflow_', currentBatch, '_', currentPolarity);
                
                mzConvertWorkflow = this.get(mzConvertWorkflowName);
                if mzConvertWorkflow.isEnded()
                    dataDirectory = mzConvertWorkflow.getNode('MzConverter').getConfig().getParamValue('WorkingDirectory');
                    
                else
                    dataDirectory = convertDesign.getFieldByDesignName('DataDirectory',  names{i});
                    dataDirectory = dataDirectory{:};
                end
                
                w = this.get(workflowName);
                
                w.getConfig()...
                    .updateParamValue('WorkingDirectory', workingDirectory);
                w.writeParamValues( processParams{:} );
                
                mzFileImporter = w.getNode('MzFileImporter');
                mzFileImporter.addInputFilePath(dataDirectory);
                mzFileImporter.getConfig()...
                    .updateParamValue('FileExtensionFilter', '.mzXML');
                
                w.run();
                
            end
            
        end
        
        %-- I --
        
        function importUserConfigFilePath( this, iFilePath )
            if ~isempty(iFilePath)
                this.configTable = biotracs.mimosa.model.UserConfigTable.import(iFilePath, 'NbHeaderLines', 1);
            end
        end
        
        %-- L --

        function linkingAction( this )
            convertDesign = this.configTable.get('LINK');
            
            nbDesigns = convertDesign.getNbDesigns();
            names = convertDesign.getNamesOfDesigns();
            
            for i=1:nbDesigns
                
                currentBatch = convertDesign.getFieldByDesignName('Batch', names{i});
                currentBatch = currentBatch{:};
                currentPolarity = convertDesign.getFieldByDesignName('Polarity', names{i});
                currentPolarity= currentPolarity{:};
                %                 dataDirectory = convertDesign.getFieldByDesignName('DataDirectory',  names{i});
                workingDirectory = convertDesign.getFieldByDesignName('WorkingDirectory', names{i});
                workingDirectory = workingDirectory{:};
                processParams = convertDesign.getFieldByDesignName('ProcessParam', names{i});
                
                workflowName = strcat('MetaboLinkingWorkflow_', currentBatch, '_', currentPolarity);
                %configuration
                extractWorkflowName = strcat('MetaboExtractionWorkflow_', currentBatch, '_', currentPolarity);
                % if this.hasElement(extractWorkflowName)
                
                extractWorkflow = this.get(extractWorkflowName);
                if extractWorkflow.isEnded()
                    dataDirectory = cell(1,1);
                    dataDirectory{1} = extractWorkflow.getNode('FileFilter').getConfig().getParamValue('WorkingDirectory');
                else
                    dataDirectory = convertDesign.getFieldByDesignName('DataDirectory',  names{i});
                end
                
                w = this.get(workflowName);
                w.getConfig()...
                    .updateParamValue('WorkingDirectory', workingDirectory);
                w.writeParamValues( processParams{:} );
                
                mzFileImporter = w.getNode('MzFileImporter');
                for j= 1:length(dataDirectory)
                    
                    mzFileImporter.addInputFilePath(dataDirectory{j});
                end
                mzFileImporter.getConfig()...
                    .updateParamValue('FileExtensionFilter', '.featureXML');
                
                w.run();
                
            end
            
        end
        
        %--P--
        
        function preprocessingAction( this )
            convertDesign = this.configTable.get('PREPROCESS');
            
            nbDesigns = convertDesign.getNbDesigns();
            names = convertDesign.getNamesOfDesigns();
            for i=1:nbDesigns
                currentBatch = convertDesign.getFieldByDesignName('Batch', names{i});
                currentBatch = currentBatch{:};
                currentPolarity = convertDesign.getFieldByDesignName('Polarity', names{i});
                currentPolarity= currentPolarity{:};
                %                 dataDirectory = convertDesign.getFieldByDesignName('DataDirectory',  names{i});
                workingDirectory = convertDesign.getFieldByDesignName('WorkingDirectory', names{i});
                workingDirectory = workingDirectory{:};
                metaDataPath = convertDesign.getFieldByDesignName('SampleMetaData', names{i});
                
                %                 metaDataPath = metaDataPath{:}
                posProcessParams = convertDesign.getFieldByDesignName('^PosProcessParam', names{i});
                negProcessParams = convertDesign.getFieldByDesignName('^NegProcessParam', names{i});
                mergeProcessParams = convertDesign.getFieldByDesignName('^NegPosProcessParam', names{i});
                workflowName = strcat('PreprocessingWorkflow_', currentBatch, '_', currentPolarity);
                %configuration
                %                 linkingWorkflowName = strcat('MetaboLinkingWorkflow_', currentBatch, '_', currentPolarity);
                %                 linkingWorkflow = this.getNode(linkingWorkflowName);
                
                if strcmpi(currentPolarity, 'pos')
                    linkingWorkflowName = strcat('MetaboLinkingWorkflow_', currentBatch, '_', currentPolarity);
                    linkingWorkflow = this.get(linkingWorkflowName);
                    if linkingWorkflow.isEnded()
                        posDataDirectory =  linkingWorkflow.getNode('TextExporter').getConfig().getParamValue('WorkingDirectory');
                        negDataDirectory = '';
                    else
                        
                        posDataDirectory = convertDesign.getFieldByDesignName('PosDataDirectory',  names{i});
                        posDataDirectory= posDataDirectory{:};
                        negDataDirectory = convertDesign.getFieldByDesignName('NegDataDirectory',  names{i});
                        negDataDirectory = negDataDirectory{:};
                        
                    end
                    processParams = posProcessParams;
                elseif strcmpi(currentPolarity, 'neg')
                    linkingWorkflowName = strcat('MetaboLinkingWorkflow_', currentBatch, '_', currentPolarity);
                    linkingWorkflow = this.get(linkingWorkflowName);
                    if linkingWorkflow.isEnded()
                        negDataDirectory =  linkingWorkflow.getNode('TextExporter').getConfig().getParamValue('WorkingDirectory');
                        posDataDirectory = '';
                    else
                        posDataDirectory = convertDesign.getFieldByDesignName('PosDataDirectory',  names{i});
                        posDataDirectory= posDataDirectory{:};
                        negDataDirectory = convertDesign.getFieldByDesignName('NegDataDirectory',  names{i});
                        negDataDirectory = negDataDirectory{:};
                    end
                    processParams = negProcessParams;
                elseif strcmpi(currentPolarity, 'NegPos')
                    linkingWorkflowNamePos = strcat('MetaboLinkingWorkflow_', currentBatch,'_Pos');
                    linkingWorkflowPos = this.get(linkingWorkflowNamePos);
                    linkingWorkflowNameNeg = strcat('MetaboLinkingWorkflow_', currentBatch,'_Neg');
                    linkingWorkflowNeg = this.get(linkingWorkflowNameNeg);
                    if linkingWorkflowPos.isEnded() && linkingWorkflowNeg.isEnded()
                        posDataDirectory =  linkingWorkflowPos.getNode('TextExporter').getConfig().getParamValue('WorkingDirectory');
                        negDataDirectory =  linkingWorkflowNeg.getNode('TextExporter').getConfig().getParamValue('WorkingDirectory');
                        processParams = [posProcessParams, negProcessParams, mergeProcessParams];
                    else
                        posDataDirectory = convertDesign.getFieldByDesignName('PosDataDirectory',  names{i});
                        posDataDirectory= posDataDirectory{:};
                        
                        negDataDirectory = convertDesign.getFieldByDesignName('NegDataDirectory',  names{i});
                        negDataDirectory = negDataDirectory{:};
                        processParams = [posProcessParams, negProcessParams, mergeProcessParams];
                    end
                end
                
                w = this.get(workflowName);
                w.getConfig()...
                    .updateParamValue('WorkingDirectory', workingDirectory);
                w.writeParamValues( processParams{:} );
                
                metaDataImporter = w.getNode('SampleMetaDataFileImporter');
                for j= 1:length(metaDataPath)
                    
                    metaDataImporter.addInputFilePath(metaDataPath{j});
                end
                
                metaDataImporter.getConfig()...
                    .updateParamValue('FileExtensionFilter', '.xlsx');
                if ~isempty(posDataDirectory)
                    posConsenususFileImporter = w.getNode('PosConsensusFileImporter');
                    posConsenususFileImporter.addInputFilePath(posDataDirectory);
                    posConsenususFileImporter.getConfig()...
                        .updateParamValue('FileExtensionFilter', '.csv');
                end
                
                if ~isempty(negDataDirectory)
                    negConsenususFileImporter = w.getNode('NegConsensusFileImporter');
                    negConsenususFileImporter.addInputFilePath(negDataDirectory);
                    negConsenususFileImporter.getConfig()...
                        .updateParamValue('FileExtensionFilter', '.csv');
                end
                
                w.run();
                
            end
            
        end
        
    end
    
    methods(Access = protected)
        
        %-- C --
        
        function doCreateMzConvertWorkflow( this, iBatch, iPolarity )
            if nargin < 3
                error('The batch name and polarity name are required');
            end
            
            if ~ischar(iBatch) || ~ischar(iPolarity)
                error('The batch name and polarity name must be char');
            end
            
            %Create the workflow
            workflow = biotracs.core.mvc.model.Workflow();
            
            workflowName = strcat('MzConvertWorkflow_', iBatch, '_', iPolarity);
            workflow.setLabel(workflowName);
            
            workflow.setDescription('Workflow to convert mass spectrometry data');
            
            %Add FileImporter
            mzFileImporter = biotracs.core.adapter.model.FileImporter();
            workflow.addNode( mzFileImporter, 'MzFileImporter' );
            
            %Add MzConvert Experiment
            mzConverter = biotracs.mzconvert.model.Converter();
            workflow.addNode( mzConverter, 'MzConverter' );
            
            %Connect i/o ports
            mzFileImporter.getOutputPort('DataFileSet').connectTo( mzConverter.getInputPort('DataFileSet') );
            
            this.add(workflow, workflowName);
        end
        
        function doCreateMetaboExtractionWorkflow( this, iBatch, iPolarity )
            workflow = biotracs.openms.model.MetaboExtractionWorkflow();
            
            workflowName = strcat('MetaboExtractionWorkflow_', iBatch, '_', iPolarity);
            this.add(workflow, workflowName);
            
        end
        
        function doCreateMetaboLinkingWorkflow( this, iBatch, iPolarity )
            workflow = biotracs.openms.model.MetaboLinkingWorkflow();
            
            workflowName = strcat('MetaboLinkingWorkflow_', iBatch, '_', iPolarity);
            this.add(workflow, workflowName);
            
        end
        
        function doCreatePreprocessingWorkflow( this, iBatch, iPolarity )
            workflow = biotracs.mimosa.model.PreprocessingWorkflow();
            
            workflowName = strcat('PreprocessingWorkflow_', iBatch, '_', iPolarity);
            this.add(workflow, workflowName);
            
        end
        
        %-- I --
        
        function doInit( this, varargin )
            p = inputParser();
            p.addParameter('Batches', {}, @iscellstr);
            p.addParameter('Polarities', {}, @iscellstr);
            p.addParameter('UserConfigFilePath', '', @ischar);
            p.KeepUnmatched = true;
            p.parse( varargin{:} );
            
            this.listOfBatches = p.Results.Batches;
            this.listOfPolarities = p.Results.Polarities;
            this.importUserConfigFilePath(p.Results.UserConfigFilePath)
            %... create processes
            for i = 1:length(this.listOfBatches)
                currentBatch = this.listOfBatches{i};
                for j = 1:length(this.listOfPolarities)
                    currentPolarity = this.listOfPolarities{j};
                    this.doCreateMzConvertWorkflow( currentBatch, currentPolarity );
                    this.doCreateMetaboExtractionWorkflow( currentBatch, currentPolarity );
                    this.doCreateMetaboLinkingWorkflow( currentBatch, currentPolarity );
                    this.doCreatePreprocessingWorkflow( currentBatch, currentPolarity );
                end
            end
            
        end
        
    end
end

