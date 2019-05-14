% BIOASTER
%> @file		PreprocessingWorkflow.m
%> @class		biotracs.mimosa.model.PreprocessingWorkflow
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017

classdef PreprocessingWorkflow < biotracs.core.mvc.model.Workflow
    
    properties(SetAccess = protected)
        %workflow;
    end
    
    methods
        % Constructor
        function this = PreprocessingWorkflow( )
            this@biotracs.core.mvc.model.Workflow();
            this.doBuildPreprocessingWorkflow();
            this.bindView( biotracs.spectra.data.view.MSFeatureSet() );
        end
        
    end
    
    methods(Access = protected)
        
        function doBeforeRun ( this )
            this.doBeforeRun@biotracs.core.mvc.model.Workflow( ) ;
            
            posConsensusFileImporter = this.getNode('PosConsensusFileImporter');
            negConsensusFileImporter = this.getNode('NegConsensusFileImporter');
            
            if  ~posConsensusFileImporter.hasInputFilePath() 
                merger = this.getNode('FeatureSetMerger');
                posFeatureSet = merger.getInputPort('PosFeatureSet');
                posFeatureSet.setIsRequired(false);
                
            end
             if  ~negConsensusFileImporter.hasInputFilePath()
                merger = this.getNode('FeatureSetMerger');
                negFeatureSet = merger.getInputPort('NegFeatureSet');
                negFeatureSet.setIsRequired(false);
                
            end

        end

        function this = doBuildPreprocessingWorkflow(this)
            [ sampleMetaFileImporter ] = this.doAddSampleMetaFileImporter();
            [ posConsensusFileImporter, ] = this.doAddPosConsensuFileImporter();
            [ negConsensusFileImporter ] = this.doAddNegConsensuFileImporter();
            [ posModeProcessing ] = this.doBuildPosModeProcessing();
            [ negModeProcessing ] = this.doBuildNegModeProcessing();
            [ featureSetMerger, fileExporterMerging ]                       = this.doAddFeatureMerger();
            [ filterFeatureMerger, pcaResultFeatureMerger ]   = this.doPcaFeatureMerger();
            [ viewPcaFeatureMerger ]                                     = this.doAddViewExporterPcaFeatureMerger();
            
            [ featureGrouper, adductMatrixFileExporter, ...
                isofeatureSetFileExporter, adductFeatureSetFileExporter,...
                isofeatureSetMatFileExporter, adductFeatureSetMatFileExporter]	= this.doAddFeatureGrouper();
            [ viewAdductMatrix ]                                     = this.doAddViewExporterAdductMatrix();
           
            [ groupTableCreator, groupTableCreatorFileExporter]                 = this.doAddGroupTableCreator();
                
            
            posConsensusFileImporter.getOutputPort('DataFileSet').connectTo( posModeProcessing.getInputPort('ConsensusDataParser:DataFile') );
            sampleMetaFileImporter.getOutputPort('DataFileSet').connectTo( posModeProcessing.getInputPort('MetaTableParser:DataFile') );
            
            negConsensusFileImporter.getOutputPort('DataFileSet').connectTo( negModeProcessing.getInputPort('ConsensusDataParser:DataFile') );
            sampleMetaFileImporter.getOutputPort('DataFileSet').connectTo( negModeProcessing.getInputPort('MetaTableParser:DataFile') );
            
            negModeProcessing.getOutputPort('InterBatchDriftCorrector:FeatureSet').connectTo(featureSetMerger.getInputPort('NegFeatureSet') );
            posModeProcessing.getOutputPort('InterBatchDriftCorrector:FeatureSet').connectTo(featureSetMerger.getInputPort('PosFeatureSet') );
            featureSetMerger.getOutputPort('FeatureSet').connectTo( fileExporterMerging.getInputPort('Resource') );
            featureSetMerger.getOutputPort('FeatureSet').connectTo(filterFeatureMerger.getInputPort('DataMatrix') );
            filterFeatureMerger.getOutputPort('DataMatrix').connectTo( pcaResultFeatureMerger.getInputPort('TrainingSet') );
            pcaResultFeatureMerger.getOutputPort('Result').connectTo( viewPcaFeatureMerger.getInputPort('Resource') );

            featureSetMerger.getOutputPort('FeatureSet').connectTo(featureGrouper.getInputPort('FeatureSet') );
            featureGrouper.getOutputPort('AdductMatrix').connectTo( adductMatrixFileExporter.getInputPort('Resource') );
            featureGrouper.getOutputPort('AdductMatrix').connectTo( viewAdductMatrix.getInputPort('Resource') );
            featureGrouper.getOutputPort('AdductFeatureSet').connectTo( adductFeatureSetFileExporter.getInputPort('Resource') );
            featureGrouper.getOutputPort('AdductFeatureSet').connectTo( adductFeatureSetMatFileExporter.getInputPort('Resource') );
            featureGrouper.getOutputPort('IsoFeatureSet').connectTo( isofeatureSetFileExporter.getInputPort('Resource') );
            featureGrouper.getOutputPort('IsoFeatureSet').connectTo( isofeatureSetMatFileExporter.getInputPort('Resource') );
            featureGrouper.getOutputPort('IsoFeatureSet').connectTo( groupTableCreator.getInputPort('IsoFeatureTable') );
            groupTableCreator.getOutputPort('GroupTable').connectTo( groupTableCreatorFileExporter.getInputPort('Resource') );
                       
            
        end
        
    end
    
    
    methods(Access = protected)
        
        function [ sampleMetaFileImporter ] = doAddSampleMetaFileImporter( this )
            sampleMetaFileImporter = biotracs.core.adapter.model.FileImporter();
            this.addNode( sampleMetaFileImporter, 'SampleMetaDataFileImporter' );
        end
        
        function [ posConsensusFileImporter ] = doAddPosConsensuFileImporter( this )
            posConsensusFileImporter = biotracs.core.adapter.model.FileImporter();
            this.addNode( posConsensusFileImporter, 'PosConsensusFileImporter' );
        end
        
        function [ negConsensusFileImporter ] = doAddNegConsensuFileImporter( this )
            negConsensusFileImporter = biotracs.core.adapter.model.FileImporter();
            this.addNode( negConsensusFileImporter, 'NegConsensusFileImporter' );
        end
        
        function [ posModeProcessing ] = doBuildPosModeProcessing(this)
            posModeProcessing = biotracs.mimosa.model.SingleModePreprocessingWorkflow();
            this.addNode(posModeProcessing,'PosModePreprocessingWorkflow');
            posModeProcessing.createInputPortInterface('ConsensusDataParser','DataFile');
            posModeProcessing.createInputPortInterface('MetaTableParser','DataFile');
            posModeProcessing.createOutputPortInterface('InterBatchDriftCorrector','FeatureSet');
        end
        
        function [ negModeProcessing ] = doBuildNegModeProcessing(this)
            negModeProcessing = biotracs.mimosa.model.SingleModePreprocessingWorkflow();
            this.addNode(negModeProcessing,'NegModePreprocessingWorkflow');
            negModeProcessing.createInputPortInterface('ConsensusDataParser','DataFile');
            negModeProcessing.createInputPortInterface('MetaTableParser','DataFile');
            negModeProcessing.createOutputPortInterface('InterBatchDriftCorrector','FeatureSet');
        end
        
        
        function [ featureSetMerger, fileExporterMerging ] = doAddFeatureMerger( this )
            featureSetMerger = biotracs.mimosa.model.FeatureMerger();
            this.addNode( featureSetMerger, 'FeatureSetMerger');
            
            fileExporterMerging = biotracs.core.adapter.model.FileExporter();
            c = fileExporterMerging.getConfig();
            c.updateParamValue('FileExtension', '.csv');
            this.addNode(fileExporterMerging, 'FeatureSetMergerFileExporter');
        end
        
           function [ filter, pcaExp ] = doPcaFeatureMerger( this )
            filter = biotracs.dataproc.model.DataFilter();
            filter.getConfig()...
                .updateParamValue('MinStandardDeviation', 1e-9);
            this.addNode(filter, 'FilterFeatureMerger');
            
            pcaExp = biotracs.atlas.model.PCALearner();
            pcaExp.getConfig()...
                .updateParamValue('NbComponents', 2)...
                .updateParamValue('Scale', 'uv')...
                .updateParamValue('Center', true);
            this.addNode(pcaExp, 'PcaFeatureMerger');
        end
        
        function [ viewPca ] = doAddViewExporterPcaFeatureMerger( this )
            viewPca = biotracs.core.adapter.model.ViewExporter();
            viewPca.getConfig()...
                .updateParamValue('ViewNames', {'ScorePlot'});
            this.addNode(viewPca, 'ViewPcaFeatureMerger');
        end

        
        function [ featureGrouper, adductMatrixFileExporter, isofeatureSetFileExporter, adductFeatureSetFileExporter,  isofeatureSetMatFileExporter, adductFeatureSetMatFileExporter ] = doAddFeatureGrouper( this )
            featureGrouper = biotracs.mimosa.model.FeatureGrouper();
            this.addNode( featureGrouper, 'FeatureGrouper');
            
            adductMatrixFileExporter = biotracs.core.adapter.model.FileExporter();
            c = adductMatrixFileExporter.getConfig();
            c.updateParamValue('FileExtension', '.csv');
            this.addNode(adductMatrixFileExporter, 'AdductMatrixFileExporter');
            
            isofeatureSetFileExporter = biotracs.core.adapter.model.FileExporter();
            c = isofeatureSetFileExporter.getConfig();
            c.updateParamValue('FileExtension', '.csv');
            this.addNode(isofeatureSetFileExporter, 'IsoFeatureSetFileExporter');
            
            isofeatureSetMatFileExporter = biotracs.core.adapter.model.FileExporter();
            c = isofeatureSetMatFileExporter.getConfig();
            c.updateParamValue('FileExtension', '.mat');
            this.addNode(isofeatureSetMatFileExporter, 'IsoFeatureSetMatFileExporter');
            
            adductFeatureSetFileExporter = biotracs.core.adapter.model.FileExporter();
            c = adductFeatureSetFileExporter.getConfig();
            c.updateParamValue('FileExtension', '.csv');
            this.addNode(adductFeatureSetFileExporter, 'AdductFeatureSetFileExporter');
            
            adductFeatureSetMatFileExporter = biotracs.core.adapter.model.FileExporter();
            c = adductFeatureSetMatFileExporter.getConfig();
            c.updateParamValue('FileExtension', '.mat');
            this.addNode(adductFeatureSetMatFileExporter, 'AdductFeatureSetMatFileExporter');
            
        end
        
        function [ viewAdductMatrix ] = doAddViewExporterAdductMatrix( this )
            viewAdductMatrix = biotracs.core.adapter.model.ViewExporter();
            viewAdductMatrix.getConfig()...
                .updateParamValue('ViewNames', {'FeatureGroupingPlot'});
            this.addNode(viewAdductMatrix, 'ViewAdductMatrix');
        end

        
        function [ groupTableCreator, groupTableCreatorFileExporter] = doAddGroupTableCreator (this)
            groupTableCreator = biotracs.spectra.data.model.MSGroupTableCreator(); %biotracs.mimosa.model.GroupTableCreator();
            this.addNode(groupTableCreator, 'GroupTableCreator');
            groupTableCreatorFileExporter = biotracs.core.adapter.model.FileExporter();
            c = groupTableCreatorFileExporter.getConfig();
            c.updateParamValue('FileExtension', '.csv');
            this.addNode(groupTableCreatorFileExporter, 'GroupTableCreatorFileExporter');
            
        end
    end
end

