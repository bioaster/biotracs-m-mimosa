% BIOASTER
%> @file 		FeatureUngrouper.m
%> @class 		biotracs.mimosa.model.FeatureUngrouper
%> @link			http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018

classdef FeatureUngrouper < biotracs.mimosa.model.BaseProcess
    
    properties(Constant)
    end
    
    properties(Dependent)
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = FeatureUngrouper()
            %#function biotracs.mimosa.model.FeatureUngrouperConfig biotracs.spectra.data.model.MSFeatureSet biotracs.data.model.DataTable
            
            this@biotracs.mimosa.model.BaseProcess();
            this.configType = 'biotracs.mimosa.model.FeatureUngrouperConfig';
            this.setDescription('Algorithm for extracting the Consensus table');
            
            this.setInputSpecs({...
                struct(...
                'name', 'ListFeaturesSelected',...
                'class', 'biotracs.spectra.data.model.MSFeatureSet' ...
                ),struct(...
                'name', 'GroupedTable',...
                'class', 'biotracs.data.model.DataTable' ...
                ) ...
                });
            
            this.setOutputSpecs({...
                struct(...
                'name', 'UnGroupedTable',...
                'class', 'biotracs.data.model.DataTable' ...
                ) ...
                });
        end
        
    end
    
  
    
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
   
        
        function doRun( this )

            listFeaturesSelected = this.getInputPortData('ListFeaturesSelected');
            groupedTable = this.getInputPortData('GroupedTable');
            [ ungroupedFeatureSet ] = this.doUngroupFeature( listFeaturesSelected,groupedTable);
            this.setOutputPortData('UnGroupedTable', ungroupedFeatureSet);

        end
        
        function [ ungroupedFeatureSet ] = doUngroupFeature( this, listFeaturesSelected, groupedTable )
            direction = this.config.getParamValue('Direction');
            if strcmpi(direction, 'Column')
                selectedFeatures = listFeaturesSelected.getColumnNames;
                ungroupedFeatureSet = groupedTable.selectByRowName(selectedFeatures);
            else
                selectedFeatures = listFeaturesSelected.getRowNames;
                %ungroupedFeatureSet = groupedTable.selectByRowName(selectedFeatures);
                nbFeatures = size(selectedFeatures);
                list = getSize(listFeaturesSelected);
                nbColumns = getSize(groupedTable);
       
                ff = cell((nbFeatures(2)*10),(nbColumns(2)+list(2)));
                rNames = [];
                for i=1:nbFeatures(2)
                    group = groupedTable.selectByRowName(selectedFeatures{i});
                    l = listFeaturesSelected.selectByRowName(selectedFeatures{i});
                    s = getSize(group);
                    r = repmat(l.data,s(1),1);
                    row= repmat(l.getRowNames,s(1),1);
                    if ~isempty(row)
                        
                        rNames{i} = row;
                    end
                    ff{i}= horzcat(group.data, num2cell(r));
                   
                    
                end
                ff = vertcat( ff{:} );
                rowNames = vertcat( rNames{:} );
                columnNames = [groupedTable.getColumnNames, listFeaturesSelected.getColumnNames ];
                ungroupedFeatureSet = biotracs.data.model.DataTable(ff);
                ungroupedFeatureSet = ungroupedFeatureSet.setColumnNames(columnNames);
                ungroupedFeatureSet = ungroupedFeatureSet.setRowNames(rowNames);
            
            end
        end
    
    end
end
