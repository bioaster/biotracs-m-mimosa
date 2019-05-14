% BIOASTER
%> @file		SingleModePreprocessingWorkflow.m
%> @class		biotracs.mimosa.model.SingleModePreprocessingWorkflow
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		May 2017

classdef SingleModePreprocessingWorkflow < biotracs.core.mvc.model.Workflow
    
    properties(SetAccess = protected)
        workflow;
    end
    
    methods
        
        % Constructor
        function this = SingleModePreprocessingWorkflow( )
            this@biotracs.core.mvc.model.Workflow();
            this.doBuildProcessingWorkflow();
        end
        
    end
    
    methods(Access = protected)
        
        function this = doBuildProcessingWorkflow( this )
            [ sampleMetaFileImporter ]                                              = this.doAddSampleMetaFileImporter();
            [ featureFileImporter ]                                                 = this.doAddFeatureFileImporter();
            [ metaTableParser ]                                                     = this.doAddMetaTableParser();
            [ consensusParser, consensusParserDemux ]                               = this.doAddConsensusParser();
            [ consensusDataExtractor ]                                              = this.doAddConsensusDataExtractor();
            [ dataSelector ]                                                        = this.doAddDataSelector();
            [ consensusDataAnnotator, consensusDataExporter ]                       = this.doAddTableAnnotator();
            [ viewConsensusDataAnotator]                                            = this.doAddViewExporterConsensusDataAnnotator();
            [ filterConsensusDataAnnotator, pcaResultConsensusDataAnnotator ]       = this.doPcaConsenusDataAnnotator();
            [ viewPcaConsenusDataAnnotator ]                                        = this.doAddViewExporterPcaConsensusDataAnnotator();
            [ blankFilter , blankFilterFileExporter ]                               = this.doAddFilterBlank();
            [ viewerBlankFilter ]                                                   = this.doAddViewExporterBlankFilter();
            [ filterBlankFilter, pcaResultBlankFilter ]                             = this.doPcaBlankFilter();
            [ viewPcaBlankFilter ]                                                  = this.doAddViewExporterPcaBlankFilter();
            [ percentageRuleFilter, percentageRuleFilterFileExporter ]              = this.doAddPercentageRuleFilter();
            [ viewerPercentageRuleFilter ]                                          = this.doAddViewExporterPercentageRuleFilter();
            [ filterPercentageRuleFilter, pcaResultPercentageRuleFilter ]           = this.doPcaPercentageRuleFilter();
            [ viewPcaPercentageRuleFilter ]                                         = this.doAddViewExporterPcaPercentageRuleFilter();
            [ gapFiller1, gapFillerFileExporter1 ]                                  = this.doAddGapFiller();
            [ intraBatchDriftCorrector, intraBatchDriftCorrectorFileExporter ]      = this.doAddIntraBatchDriftCorrector();
            [ viewerIntraBatchDriftCorrector ]                                      = this.doAddViewExporterIntraBatchDriftCorrector();
            [ filterIntraBatchDriftCorrector, pcaResultIntraBatchDriftCorrector ]   = this.doPcaIntraBatchDriftCorrector();
            [ viewPcaIntraBatchDriftCorrector ]                                     = this.doAddViewExporterPcaIntraBatchDriftCorrector(); 
            [ gapFiller2, gapFillingFileExporter2 ]                                 = this.doAddGapFiller2();
            [ qcCvFilter, qcCvFilterFileExporter , qcCvPerBatchFileExporter ]        = this.doAddQcCvFilter();
            [ viewerQcCvFilter ]                                                    = this.doAddViewExporterQcCvFilter();
            [ filterQcCvFilter, pcaResultQcCvFilter ]                               = this.doPcaQcCvFilter();
            [ viewPcaQcCvFilter ]                                                   = this.doAddViewExporterPcaQcCvFilter();
            [ interBatchDriftCorrector, interBatchDriftCorrectorFileExporter ]      = this.doAddInterBacthDriftCorrector();
            [ filterInterBatchDriftCorrector, pcaResultInterBatchDriftCorrector ]   = this.doPcaInterBatchDriftCorrector();
            [ viewPcaInterBatchDriftCorrector ]                                     = this.doAddViewExporterPcaInterBatchDriftCorrector();
            
            % Connect i/o ports
            featureFileImporter.getOutputPort('DataFileSet').connectTo( consensusParser.getInputPort('DataFile') );
            consensusParser.getOutputPort('ResourceSet').connectTo( consensusParserDemux.getInputPort('ResourceSet') );
            consensusParserDemux.getOutputPort('Resource').connectTo( consensusDataExtractor.getInputPort('ExtDataTable') );
            consensusDataExtractor.getOutputPort('FeatureSet').connectTo(dataSelector.getInputPort('DataTable') );
            sampleMetaFileImporter.getOutputPort('DataFileSet').connectTo(metaTableParser.getInputPort('DataFile'));
            metaTableParser.getOutputPort('ResourceSet').connectTo( consensusDataAnnotator.getInputPort('MetaTable') );
            dataSelector.getOutputPort('DataTable').connectTo( consensusDataAnnotator.getInputPort('DataTable') );
            consensusDataAnnotator.getOutputPort('DataTable').connectTo( consensusDataExporter.getInputPort('Resource') );
            
            consensusDataAnnotator.getOutputPort('DataTable').connectTo( viewConsensusDataAnotator.getInputPort('Resource') );
            consensusDataAnnotator.getOutputPort('DataTable').connectTo(filterConsensusDataAnnotator.getInputPort('DataMatrix') );
            filterConsensusDataAnnotator.getOutputPort('DataMatrix').connectTo( pcaResultConsensusDataAnnotator.getInputPort('TrainingSet') );
            pcaResultConsensusDataAnnotator.getOutputPort('Result').connectTo( viewPcaConsenusDataAnnotator.getInputPort('Resource') );
            
            consensusDataAnnotator.getOutputPort('DataTable').connectTo( blankFilter.getInputPort('FeatureSet') );
            blankFilter.getOutputPort('FeatureSet').connectTo( blankFilterFileExporter.getInputPort('Resource') );
            blankFilter.getOutputPort('FeatureSet').connectTo( viewerBlankFilter.getInputPort('Resource') );
            blankFilter.getOutputPort('FeatureSet').connectTo(filterBlankFilter.getInputPort('DataMatrix') );
            filterBlankFilter.getOutputPort('DataMatrix').connectTo( pcaResultBlankFilter.getInputPort('TrainingSet') );
            pcaResultBlankFilter.getOutputPort('Result').connectTo( viewPcaBlankFilter.getInputPort('Resource') );
           
            blankFilter.getOutputPort('FeatureSet').connectTo( percentageRuleFilter.getInputPort('FeatureSet') );
            percentageRuleFilter.getOutputPort('FeatureSet').connectTo( percentageRuleFilterFileExporter.getInputPort('Resource') );
            percentageRuleFilter.getOutputPort('FeatureSet').connectTo( viewerPercentageRuleFilter.getInputPort('Resource') );
            percentageRuleFilter.getOutputPort('FeatureSet').connectTo(filterPercentageRuleFilter.getInputPort('DataMatrix') );
            filterPercentageRuleFilter.getOutputPort('DataMatrix').connectTo( pcaResultPercentageRuleFilter.getInputPort('TrainingSet') );
            pcaResultPercentageRuleFilter.getOutputPort('Result').connectTo( viewPcaPercentageRuleFilter.getInputPort('Resource') );
         
            percentageRuleFilter.getOutputPort('FeatureSet').connectTo( gapFiller1.getInputPort('FeatureSet') );
            gapFiller1.getOutputPort('FeatureSet').connectTo(gapFillerFileExporter1.getInputPort('Resource') );
            gapFiller1.getOutputPort('FeatureSet').connectTo( intraBatchDriftCorrector.getInputPort('FeatureSet') );
            intraBatchDriftCorrector.getOutputPort('FeatureSet').connectTo(intraBatchDriftCorrectorFileExporter.getInputPort('Resource') );
            intraBatchDriftCorrector.getOutputPort('FeatureSet').connectTo(viewerIntraBatchDriftCorrector.getInputPort('Resource') );
            intraBatchDriftCorrector.getOutputPort('FeatureSet').connectTo(filterIntraBatchDriftCorrector.getInputPort('DataMatrix') );
            filterIntraBatchDriftCorrector.getOutputPort('DataMatrix').connectTo( pcaResultIntraBatchDriftCorrector.getInputPort('TrainingSet') );
            pcaResultIntraBatchDriftCorrector.getOutputPort('Result').connectTo( viewPcaIntraBatchDriftCorrector.getInputPort('Resource') );
         
            
            intraBatchDriftCorrector.getOutputPort('FeatureSet').connectTo(gapFiller2.getInputPort('FeatureSet') );
            gapFiller2.getOutputPort('FeatureSet').connectTo(gapFillingFileExporter2.getInputPort('Resource') );
            gapFiller2.getOutputPort('FeatureSet').connectTo( qcCvFilter.getInputPort('FeatureSet') );
            qcCvFilter.getOutputPort('FeatureSet').connectTo(qcCvFilterFileExporter.getInputPort('Resource') );
            qcCvFilter.getOutputPort('QcCvDataMatrix').connectTo(qcCvPerBatchFileExporter.getInputPort('Resource') );
            qcCvFilter.getOutputPort('FeatureSet').connectTo( viewerQcCvFilter.getInputPort('Resource') );
            qcCvFilter.getOutputPort('FeatureSet').connectTo(filterQcCvFilter.getInputPort('DataMatrix') );
            filterQcCvFilter.getOutputPort('DataMatrix').connectTo( pcaResultQcCvFilter.getInputPort('TrainingSet') );
            pcaResultQcCvFilter.getOutputPort('Result').connectTo( viewPcaQcCvFilter.getInputPort('Resource') );
         

            qcCvFilter.getOutputPort('FeatureSet').connectTo( interBatchDriftCorrector.getInputPort('FeatureSet') );
            interBatchDriftCorrector.getOutputPort('FeatureSet').connectTo(interBatchDriftCorrectorFileExporter.getInputPort('Resource') );
            interBatchDriftCorrector.getOutputPort('FeatureSet').connectTo(filterInterBatchDriftCorrector.getInputPort('DataMatrix') );
            filterInterBatchDriftCorrector.getOutputPort('DataMatrix').connectTo( pcaResultInterBatchDriftCorrector.getInputPort('TrainingSet') );
            pcaResultInterBatchDriftCorrector.getOutputPort('Result').connectTo( viewPcaInterBatchDriftCorrector.getInputPort('Resource') );
         
        
        end
        
    end
    
    
    methods(Access = protected)
        
        function [ sampleMetaFileImporter ] = doAddSampleMetaFileImporter( this )
            sampleMetaFileImporter = biotracs.core.adapter.model.FileImporter();
            this.addNode( sampleMetaFileImporter, 'SampleMetaDataFileImporter' );
        end
        
        function [ featureFileImporter ] = doAddFeatureFileImporter( this )
            featureFileImporter = biotracs.core.adapter.model.FileImporter();
            featureFileImporter.getConfig()...
                .updateParamValue('FileExtensionFilter', '.csv');
            this.addNode( featureFileImporter, 'FeatureSetFileImporter' );
        end
        
        function [ metaTableParser ] = doAddMetaTableParser( this )
            metaTableParser = biotracs.parser.model.TableParser();
            this.addNode( metaTableParser, 'MetaTableParser' );
            
        end
        
        function [ consensusParser, consensusParserDemux ] = doAddConsensusParser( this )
            consensusParser = biotracs.parser.model.TableParser();
            consensusParser.getConfig()...
                .updateParamValue('TableClass', 'biotracs.mimosa.model.ConsensusExtDataTable')...
                .updateParamValue('Mode', 'extended')...
                .updateParamValue('NbHeaderLines', 1);
            this.addNode( consensusParser, 'ConsensusDataParser');
            
            consensusParserDemux = biotracs.core.adapter.model.Demux();
            consensusParserDemux.getOutput()...
                .resize(1)...
                .setIsResizable(false);
            this.addNode(consensusParserDemux, 'ConsensusDemux');
        end
        
        function [ consensusDataExtractor ] = doAddConsensusDataExtractor( this )
            consensusDataExtractor = biotracs.mimosa.model.ConsensusDataExtractor();
            consensusDataExtractor.getConfig()...
                .updateParamValue('BatchPattern', 'Batch:([^_]*)')...
                .updateParamValue('QcPattern', 'SampleType:QC')...
                .updateParamValue('SamplePattern', 'SampleType:Sample')...
                .updateParamValue('SequenceNumberPattern', 'SequenceNumber:([^_]*)');
            this.addNode( consensusDataExtractor, 'ConsensusDataExtractor');
        end
        
        
        function [ dataSelector ] = doAddDataSelector( this )
            dataSelector = biotracs.dataproc.model.DataSelector();
            c = dataSelector.getConfig();
            c.updateParamValue('SelectOrRemove', 'remove');
            c.updateParamValue('Direction', 'row');
            this.addNode( dataSelector, 'DataSelector');
        end
        
        function [ consensusDataAnnotator, consensusDataExporter ] = doAddTableAnnotator( this )
            consensusDataAnnotator = biotracs.metadata.model.TableAnnotator();
            this.addNode( consensusDataAnnotator, 'ConsensusDataAnnotator');
            
            consensusDataExporter = biotracs.core.adapter.model.FileExporter();
            c = consensusDataExporter.getConfig();
            c.updateParamValue('FileExtension', '.csv');
            this.addNode(consensusDataExporter, 'ConsensusDataExporter');
        end
        
        function [ filter, pcaExp ] = doPcaConsenusDataAnnotator( this )
            filter = biotracs.dataproc.model.DataFilter();
            filter.getConfig()...
                .updateParamValue('MinStandardDeviation', 1e-9);
            this.addNode(filter, 'FilterConsensusDataAnnotator');
            
            pcaExp = biotracs.atlas.model.PCALearner();
            pcaExp.getConfig()...
                .updateParamValue('NbComponents', 2)...
                .updateParamValue('Scale', 'uv')...
                .updateParamValue('Center', true);
            this.addNode(pcaExp, 'PcaConsenusDataAnnotator');
        end
        
        function [ viewPca ] = doAddViewExporterPcaConsensusDataAnnotator( this )
            viewPca = biotracs.core.adapter.model.ViewExporter();
            viewPca.getConfig()...
                .updateParamValue('ViewNames', {'ScorePlot'});
            this.addNode(viewPca, 'ViewPcaConsensusDataAnnotator');
        end

        function [ viewExporter ] = doAddViewExporterConsensusDataAnnotator( this )
            viewExporter = biotracs.core.adapter.model.ViewExporter();
            viewExporter.getConfig()...
                .updateParamValue('ViewNames', {'FeatureCountPlot', 'QcCvPlot'});                
            this.addNode(viewExporter, 'ViewConsensusDataAnnotator');
        end
        
        
        function [ blankFilter , blankFilterFileExporter ] = doAddFilterBlank( this )
            blankFilter = biotracs.mimosa.model.Filter();
            c = blankFilter.getConfig();
            c.updateParamValue('QcCvThreshold',[]);
            c.updateParamValue('PercentageRuleThreshold',0);
            c.updateParamValue('BlankIntensityRatio', 3);
            this.addNode( blankFilter, 'BlankFilter' );
            
            blankFilterFileExporter = biotracs.core.adapter.model.FileExporter();
            c = blankFilterFileExporter.getConfig();
            c.updateParamValue('FileExtension', '.csv');
            this.addNode(blankFilterFileExporter, 'BlankFilterFileExporter');
        end
        
        function [ viewExporter ] = doAddViewExporterBlankFilter( this )
            viewExporter = biotracs.core.adapter.model.ViewExporter();
            viewExporter.getConfig()...
                .updateParamValue('ViewNames', {'FeatureCountPlot', 'QcCvPlot'});
%                 .updateParamValue('ViewParameters', {{'LabelFormat', {'SampleType:([^_]*)'}}});
            this.addNode(viewExporter, 'ViewBlankFilter');
        end
        
        function [ filter, pcaExp ] = doPcaBlankFilter( this )
            filter = biotracs.dataproc.model.DataFilter();
            filter.getConfig()...
                .updateParamValue('MinStandardDeviation', 1e-9);
            this.addNode(filter, 'FilterBlankFilter');
            
            pcaExp = biotracs.atlas.model.PCALearner();
            pcaExp.getConfig()...
                .updateParamValue('NbComponents', 2)...
                .updateParamValue('Scale', 'uv')...
                .updateParamValue('Center', true);
            this.addNode(pcaExp, 'PcaBlankFilter');
        end
        
        function [ viewPca ] = doAddViewExporterPcaBlankFilter( this )
            viewPca = biotracs.core.adapter.model.ViewExporter();
            viewPca.getConfig()...
                .updateParamValue('ViewNames', {'ScorePlot'});
%                 .updateParamValue('ViewParameters', {{'GroupList', {'MSSampleType'}, 'LabelFormat', {'MSSampleType:([^_]*)'}}});
            this.addNode(viewPca, 'ViewPcaBlankFilter');
        end
        
        function [ percentageRuleFilter, percentageRuleFilterFileExporter ] = doAddPercentageRuleFilter( this )
            percentageRuleFilter = biotracs.mimosa.model.Filter();
            c = percentageRuleFilter.getConfig();
            c.updateParamValue('QcCvThreshold',[]);
            c.updateParamValue('PercentageRuleThreshold',0.8);
            c.updateParamValue('LoQ',1e4);
            this.addNode( percentageRuleFilter, 'PercentageRuleFilter' );
            
            percentageRuleFilterFileExporter = biotracs.core.adapter.model.FileExporter();
            c = percentageRuleFilterFileExporter.getConfig();
            c.updateParamValue('FileExtension', '.csv');
            this.addNode(percentageRuleFilterFileExporter, 'PercentageRuleFilterFileExporter');
        end
        
        function [ viewExporter ] = doAddViewExporterPercentageRuleFilter( this )
            viewExporter = biotracs.core.adapter.model.ViewExporter();
            viewExporter.getConfig()...
                .updateParamValue('ViewNames', {'FeatureCountPlot', 'QcCvPlot'});
%                 .updateParamValue('ViewParameters', {{'LabelFormat', {'SampleType:([^_]*)'}}});
            this.addNode(viewExporter, 'ViewPercentageRuleFilter');
        end

        function [ filter, pcaExp ] = doPcaPercentageRuleFilter( this ) 
            filter = biotracs.dataproc.model.DataFilter();
            filter.getConfig()...
                .updateParamValue('MinStandardDeviation', 1e-9);
            this.addNode(filter, 'FilterPercentageRuleFilter');
            
            pcaExp = biotracs.atlas.model.PCALearner();
            pcaExp.getConfig()...
                .updateParamValue('NbComponents', 2)...
                .updateParamValue('Scale', 'uv')...
                .updateParamValue('Center', true);
            this.addNode(pcaExp, 'PcaPercentageRuleFilter');
        end
        
        function [ viewPca] = doAddViewExporterPcaPercentageRuleFilter( this )
            viewPca = biotracs.core.adapter.model.ViewExporter();
            viewPca.getConfig()...
                .updateParamValue('ViewNames', {'ScorePlot'});
%                 .updateParamValue('ViewParameters', {{'GroupList', {'MSSampleType'}, 'LabelFormat', {'MSSampleType:([^_]*)'}}});
            this.addNode(viewPca, 'ViewPcaPercentageRuleFilter');
        end
        

        function [ gapFiller1, gapFillerFileExporter1 ] = doAddGapFiller( this )
            gapFiller1 = biotracs.mimosa.model.GapFiller();
            c = gapFiller1.getConfig();
            c.updateParamValue('LoQ',1e4);
            this.addNode( gapFiller1, 'GapFiller1' );
            
            gapFillerFileExporter1 = biotracs.core.adapter.model.FileExporter();
            c = gapFillerFileExporter1.getConfig();
            c.updateParamValue('FileExtension', '.csv');
            this.addNode(gapFillerFileExporter1, 'GapFillerFileExporter1');
        end
        
        function [ intraBatchDriftCorrector, intraBatchDriftCorrectorFileExporter ] = doAddIntraBatchDriftCorrector( this )
            intraBatchDriftCorrector = biotracs.mimosa.model.DriftCorrector();
            c = intraBatchDriftCorrector.getConfig();
            c.updateParamValue('IntraBatchCorrection', true);
            c.updateParamValue('InterBatchCorrection', false);
            c.updateParamValue('NbFirstQcToIgnore',0);
            c.updateParamValue('LoQ',1e4);
            this.addNode( intraBatchDriftCorrector, 'IntraBatchDriftCorrector' );
            
            intraBatchDriftCorrectorFileExporter = biotracs.core.adapter.model.FileExporter();
            c = intraBatchDriftCorrectorFileExporter.getConfig();
            c.updateParamValue('FileExtension', '.csv');
            this.addNode(intraBatchDriftCorrectorFileExporter, 'IntraBatchDriftCorrectorFileExporter');
        end

        function [ viewExporter ] = doAddViewExporterIntraBatchDriftCorrector( this )
            viewExporter = biotracs.core.adapter.model.ViewExporter();
            viewExporter.getConfig()...
                .updateParamValue('ViewNames', { 'QcCvPlot','QcDriftPlot'});
            this.addNode(viewExporter, 'ViewIntraBatchDriftCorrector');
        end

        function [ filter, pcaExp ] = doPcaIntraBatchDriftCorrector( this ) 
            filter = biotracs.dataproc.model.DataFilter();
            filter.getConfig()...
                .updateParamValue('MinStandardDeviation', 1e-9);
            this.addNode(filter, 'FilterIntraBatchDriftCorrector');
            
            pcaExp = biotracs.atlas.model.PCALearner();
            pcaExp.getConfig()...
                .updateParamValue('NbComponents', 2)...
                .updateParamValue('Scale', 'uv')...
                .updateParamValue('Center', true);
            this.addNode(pcaExp, 'PcaIntraBatchDriftCorrector');   
        end
        
        function [ viewPca] = doAddViewExporterPcaIntraBatchDriftCorrector( this )
            viewPca = biotracs.core.adapter.model.ViewExporter();
            viewPca.getConfig()...
                .updateParamValue('ViewNames', {'ScorePlot'});
%                 .updateParamValue('ViewParameters', {{'GroupList', {'MSSampleType'}, 'LabelFormat', {'MSSampleType:([^_]*)'}}});
            this.addNode(viewPca, 'ViewPcaIntraBatchDriftCorrector');
        end
        
        function [ gapFiller2, gapFillingFileExporter2 ] = doAddGapFiller2( this )
            gapFiller2 = biotracs.mimosa.model.GapFiller();
            c = gapFiller2.getConfig();
            c.updateParamValue('LoQ',1e4);
            this.addNode( gapFiller2, 'GapFiller2' );
            
            gapFillingFileExporter2 = biotracs.core.adapter.model.FileExporter();
            c = gapFillingFileExporter2.getConfig();
            c.updateParamValue('FileExtension', '.csv');
            this.addNode(gapFillingFileExporter2, 'GapFillerFileExporter2');
        end
        
        function [ qcCvFilter,  qcCvFilterFileExporter , qcCvPerBatchFileExporter] = doAddQcCvFilter( this )
            qcCvFilter = biotracs.mimosa.model.Filter();
            c = qcCvFilter.getConfig();
            c.updateParamValue('QcCvThreshold', 0.2);
            c.updateParamValue('PercentageRuleThreshold',[]);
            
            this.addNode( qcCvFilter, 'QcCvFilter' );
            
            qcCvFilterFileExporter = biotracs.core.adapter.model.FileExporter();
            c = qcCvFilterFileExporter.getConfig();
            c.updateParamValue('FileExtension', '.csv');
            this.addNode(qcCvFilterFileExporter, 'QcCvFilterFileExporter');
             
            qcCvPerBatchFileExporter = biotracs.core.adapter.model.FileExporter();
            c = qcCvPerBatchFileExporter.getConfig();
            c.updateParamValue('FileExtension', '.csv');
            this.addNode(qcCvPerBatchFileExporter, 'QcCvPerBatchFileExporter');
        end
        
        function [ viewExporter ] = doAddViewExporterQcCvFilter( this )
            viewExporter = biotracs.core.adapter.model.ViewExporter();
            viewExporter.getConfig()...
                .updateParamValue('ViewNames', { 'QcCvPlot'});
            this.addNode(viewExporter, 'ViewQcCvFilter');
        end
        
        
        function [ filter, pcaExp ] = doPcaQcCvFilter( this )   
            filter = biotracs.dataproc.model.DataFilter();
            filter.getConfig()...
                .updateParamValue('MinStandardDeviation', 1e-9);
            this.addNode(filter, 'FilterQcCvFilter');
            
            pcaExp = biotracs.atlas.model.PCALearner();
            pcaExp.getConfig()...
                .updateParamValue('NbComponents', 2)...
                .updateParamValue('Scale', 'uv')...
                .updateParamValue('Center', true);
            this.addNode(pcaExp, 'PcaQcCvFilter');  
        end
        
        function [ viewPca] = doAddViewExporterPcaQcCvFilter( this )
            viewPca = biotracs.core.adapter.model.ViewExporter();
            viewPca.getConfig()...
                .updateParamValue('ViewNames', {'ScorePlot'});
%                 .updateParamValue('ViewParameters', {{'GroupList', {'MSSampleType'}, 'LabelFormat', {'MSSampleType:([^_]*)'}}});
            this.addNode(viewPca, 'ViewPcaQcCvFilter');
        end
        
        function [ interBatchDriftCorrector, interBatchDriftCorrectorFileExporter ] = doAddInterBacthDriftCorrector( this )
            interBatchDriftCorrector = biotracs.mimosa.model.DriftCorrector();
            c = interBatchDriftCorrector.getConfig();
            c.updateParamValue('IntraBatchCorrection', false);
            c.updateParamValue('InterBatchCorrection', true);
            this.addNode(interBatchDriftCorrector, 'InterBatchDriftCorrector');
            
            interBatchDriftCorrectorFileExporter = biotracs.core.adapter.model.FileExporter();
            c = interBatchDriftCorrectorFileExporter.getConfig();
            c.updateParamValue('FileExtension', '.csv');
            this.addNode(interBatchDriftCorrectorFileExporter, 'InterBatchDriftCorrectorFileExporter');
        end
        
        function [ filter, pcaExp ] = doPcaInterBatchDriftCorrector( this )    
            filter = biotracs.dataproc.model.DataFilter();
            filter.getConfig()...
                .updateParamValue('MinStandardDeviation', 1e-9);
            this.addNode(filter, 'FilterInterBatchDriftCorrector');
            
            pcaExp = biotracs.atlas.model.PCALearner();
            pcaExp.getConfig()...
                .updateParamValue('NbComponents', 2)...
                .updateParamValue('Scale', 'uv')...
                .updateParamValue('Center', true);
            this.addNode(pcaExp, 'PcaInterBatchDriftCorrector');
        end
        
        function [ viewPca] = doAddViewExporterPcaInterBatchDriftCorrector( this )      
            viewPca = biotracs.core.adapter.model.ViewExporter();
            viewPca.getConfig()...
                .updateParamValue('ViewNames', {'ScorePlot'});
%                 .updateParamValue('ViewParameters', {{'GroupList', {'MSSampleType'}, 'LabelFormat', {'MSSampleType:([^_]*)'}}});
            this.addNode(viewPca, 'ViewPcaInterBatchDriftCorrector');
        end
        
    end
    
end

