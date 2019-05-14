% BIOASTER
%> @file		MergingGroupingWorkflow.m
%> @class		biotracs.mimosa.model.MergingGroupingWorkflow
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017

classdef MergingGroupingWorkflow < biotracs.core.mvc.model.Workflow
    
    properties(SetAccess = protected)
        workflow;
    end
    
    methods
        
        % Constructor
        function this = MergingGroupingWorkflow( )
            this@biotracs.core.mvc.model.Workflow();
            this.doBuildProcessingWorkflow();
        end

        
    end
    
    methods(Access = protected)
        
        function [ posFeatureSetFileImporter ] = doAddPosFeatureFileImporter( this )
            posFeatureSetFileImporter = biotracs.core.adapter.model.FileImporter();
            this.addNode( posFeatureSetFileImporter, 'PosFeatureSetFileImporter' );
        end
        
        function [ negFeatureSetFileImporter ] = doAddNegFeatureFileImporter( this )
            negFeatureSetFileImporter = biotracs.core.adapter.model.FileImporter();
            this.addNode( negFeatureSetFileImporter, 'NegFeatureSetFileImporter' );
        end
        
        function [ posFeatureSetParser, posFeatureSetParserDemux ] = doAddPosDataParser( this )
            
            posFeatureSetParser = biotracs.parser.model.TableParser();
            posFeatureSetParser.getConfig()...
                .updateParamValue('TableClass', 'biotracs.spectra.data.model.MSFeatureSet');
            this.addNode( posFeatureSetParser, 'PosFeatureSetParser' );
            
            posFeatureSetParserDemux = biotracs.core.adapter.model.Demux();
            posFeatureSetParserDemux.getOutput()...
                .resize(1)...
                .setIsResizable(false);
            this.addNode(posFeatureSetParserDemux, 'PosFeatureSetParserDemux');
        end
        
        function [ negFeatureSetParser, negFeatureSetParserDemux ] = doAddNegDataParser( this )
            
            negFeatureSetParser = biotracs.parser.model.TableParser();
            negFeatureSetParser.getConfig()...
                .updateParamValue('TableClass', 'biotracs.spectra.data.model.MSFeatureSet');
            this.addNode( negFeatureSetParser, 'NegFeatureSetParser' );
            
            negFeatureSetParserDemux = biotracs.core.adapter.model.Demux();
            negFeatureSetParserDemux.getOutput()...
                .resize(1)...
                .setIsResizable(false);
            this.addNode(negFeatureSetParserDemux, 'NegFeatureSetParserDemux');
        end
        
        function [ featureSetMerger, fileExporterMerging ] = doAddFeatureMerger( this )
            featureSetMerger = biotracs.mimosa.model.FeatureMerger();
            this.addNode( featureSetMerger, 'FeatureSetMerger');
            
            fileExporterMerging = biotracs.core.adapter.model.FileExporter();
            c = fileExporterMerging.getConfig();
            c.updateParamValue('FileExtension', '.csv');
            this.addNode(fileExporterMerging, 'FeatureSetMergerFileExporter');
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
        
        function [ groupTableCreator, groupTableCreatorFileExporter] = doAddGroupTableCreator (this)
            groupTableCreator = biotracs.spectra.data.model.MSGroupTableCreator(); %biotracs.mimosa.model.GroupTableCreator();
            this.addNode(groupTableCreator, 'GroupTableCreator');
            groupTableCreatorFileExporter = biotracs.core.adapter.model.FileExporter();
            c = groupTableCreatorFileExporter.getConfig();
            c.updateParamValue('FileExtension', '.csv');
            this.addNode(groupTableCreatorFileExporter, 'GroupTableCreatorFileExporter');
        
        end
        
        
        function this = doBuildProcessingWorkflow( this ) 
            [ posFeatureSetFileImporter ]                                   = this.doAddPosFeatureFileImporter();
            [ negFeatureSetFileImporter ]                                   = this.doAddNegFeatureFileImporter();
            [ posFeatureSetParser, posFeatureSetParserDemux ]               = this.doAddPosDataParser();
            [ negFeatureSetParser, negFeatureSetParserDemux ]               = this.doAddNegDataParser();
            [ featureSetMerger, fileExporterMerging ]                       = this.doAddFeatureMerger();
            [ featureGrouper, adductMatrixFileExporter, ...
                isofeatureSetFileExporter, adductFeatureSetFileExporter,...
                isofeatureSetMatFileExporter, adductFeatureSetMatFileExporter]	= this.doAddFeatureGrouper();
            [ groupTableCreator, groupTableCreatorFileExporter]                 = this.doAddGroupTableCreator();
            
        
            % Connect i/o ports
            posFeatureSetFileImporter.getOutputPort('DataFileSet').connectTo( posFeatureSetParser.getInputPort('DataFile') );
            posFeatureSetParser.getOutputPort('ResourceSet').connectTo( posFeatureSetParserDemux.getInputPort('ResourceSet') );
            posFeatureSetParserDemux.getOutputPort('Resource').connectTo( featureSetMerger.getInputPort('PosFeatureSet') );
           
            negFeatureSetFileImporter.getOutputPort('DataFileSet').connectTo( negFeatureSetParser.getInputPort('DataFile') );
            negFeatureSetParser.getOutputPort('ResourceSet').connectTo( negFeatureSetParserDemux.getInputPort('ResourceSet') );
            negFeatureSetParserDemux.getOutputPort('Resource').connectTo( featureSetMerger.getInputPort('NegFeatureSet') );
            
            featureSetMerger.getOutputPort('FeatureSet').connectTo( fileExporterMerging.getInputPort('Resource') );
            featureSetMerger.getOutputPort('FeatureSet').connectTo(featureGrouper.getInputPort('FeatureSet') );
            featureGrouper.getOutputPort('AdductMatrix').connectTo( adductMatrixFileExporter.getInputPort('Resource') );
            featureGrouper.getOutputPort('AdductFeatureSet').connectTo( adductFeatureSetFileExporter.getInputPort('Resource') );
            featureGrouper.getOutputPort('AdductFeatureSet').connectTo( adductFeatureSetMatFileExporter.getInputPort('Resource') );
            featureGrouper.getOutputPort('IsoFeatureSet').connectTo( isofeatureSetFileExporter.getInputPort('Resource') );
            featureGrouper.getOutputPort('IsoFeatureSet').connectTo( isofeatureSetMatFileExporter.getInputPort('Resource') );
            featureGrouper.getOutputPort('IsoFeatureSet').connectTo( groupTableCreator.getInputPort('IsoFeatureTable') );
            groupTableCreator.getOutputPort('GroupTable').connectTo( groupTableCreatorFileExporter.getInputPort('Resource') );
       
       
        end
        
        function doBeforeRun ( this )
            this.doBeforeRun@biotracs.core.mvc.model.Workflow( ) ;
            
            posFeatureSetFileImporter = this.getNode('PosFeatureSetFileImporter');
            
            if ~posFeatureSetFileImporter.hasInputFilePath()
                negFeatureSetParserDemux = this.getNode('NegFeatureSetParserDemux');
                posFeatureSetParserDemux = this.getNode('PosFeatureSetParserDemux');
                
                featureSetMerger = this.getNode('FeatureSetMerger');
                fileExporterMerging = this.getNode('FeatureSetMergerFileExporter');
                fileExporterMerging.setIsPhantom(true);
                featureGrouper = this.getNode('FeatureGrouper');
                
                posFeatureSetParserDemux.getOutputPort('Resource').disconnectFrom( featureSetMerger.getInputPort('NegFeatureSet') );
                featureSetMerger.getOutputPort('FeatureSet').disconnectFrom( fileExporterMerging.getInputPort('Resource') );
                negFeatureSetParserDemux.getOutputPort('Resource').connectTo(featureGrouper.getInputPort('FeatureSet'), 'ReplaceConnection', true );

            end
            
            negFeatureSetFileImporter = this.getNode('NegFeatureSetFileImporter');
            
            if ~negFeatureSetFileImporter.hasInputFilePath()
                negFeatureSetParserDemux = this.getNode('NegFeatureSetParserDemux');
                posFeatureSetParserDemux = this.getNode('PosFeatureSetParserDemux');

                featureSetMerger = this.getNode('FeatureSetMerger');
                fileExporterMerging = this.getNode('FeatureSetMergerFileExporter');
                fileExporterMerging.setIsPhantom(true);
                featureGrouper = this.getNode('FeatureGrouper');

                negFeatureSetParserDemux.getOutputPort('Resource').disconnectFrom( featureSetMerger.getInputPort('NegFeatureSet') );
                featureSetMerger.getOutputPort('FeatureSet').disconnectFrom( fileExporterMerging.getInputPort('Resource') );
                posFeatureSetParserDemux.getOutputPort('Resource').connectTo(featureGrouper.getInputPort('FeatureSet'), 'ReplaceConnection', true );
    
       
            end
        end

    end
end

