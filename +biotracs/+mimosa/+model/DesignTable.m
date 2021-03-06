% BIOASTER
%> @file		DesignTable.m
%> @class		biotracs.mimosa.model.DesignTable
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018


classdef DesignTable < biotracs.data.model.DataTable
    
    properties(Constant)
        FIELD_COLUMN_NAME = 'Field';
        PARAMETER_COLUMN_NAME = 'Parameter';
        NB_METADATA_COLUMNS = 2; %{'Field', 'Parameter'}
    end
    
    methods
        
        function this = DesignTable( varargin )
            this@biotracs.data.model.DataTable( varargin{:} );
        end
        
        
        %-- G --
%         function dataTable = get( this, varargin )
%             dataTable = this.get@biotracs.data.model.ExtDataTable();
%             data.setRowNames( dataTable.data(:,1) );
%         end
        
        function fieldValues = getFieldByDesignName( this, iFieldName, iDesignName )
            fieldTable = this.selectByRowName(iFieldName);
            if hasEmptyData(fieldTable)
                fieldValues = '';
                %                 error('Invalid iFieldName')
            end
            nbRows = getSize(fieldTable, 1);
            paramNames = fieldTable.getDataByColumnName( this.PARAMETER_COLUMN_NAME );

                if nbRows == 1
                    fieldValues = '';
                    if isempty(paramNames{1})
                        fieldValues = fieldTable.getDataByColumnName(iDesignName);
                        oValue = strsplit(fieldValues{:}, ',');
                        if length(oValue) > 1
                            fieldValues = oValue;
                        end
                    else
                        % concatenate ...
                        paramValue = fieldTable.getDataByColumnName(iDesignName);
                        oValue = parseValue(paramValue{1});
                        fieldValues = {paramNames{1}, oValue};
                    end
                else
                    fieldValues = cell(1,2*nbRows);
                    nb = 1:2:length(fieldValues);
                    for i=1:nbRows
                        k = nb(i);
                        paramName = paramNames{i};
                         fieldValues{k} = paramName;
                         paramValue = fieldTable.getDataByColumnName(iDesignName);

                        if contains(paramName, 'ViewParameters')
                            paramValue = strsplit(paramValue{i}, ',');
                            if length(paramValue) == 1
                                paramValueLabelFormat = regexprep(paramValue, '\s+', '');
                                fieldValues{k+1} = strcat('LabelFormat', {strcat(paramValueLabelFormat, ':([^_]*)')});
                            else
                                paramValueGroupList = regexprep(paramValue{1}, '\s+', '');
                                paramValueLabelFormat = regexprep(paramValue{2}, '\s+', '');
                                fieldValues{k+1} = {{'GroupList',{paramValueGroupList}, 'LabelFormat', {strcat(paramValueLabelFormat, ':([^_]*)')}}};
                            end
                        else
                            fieldValues{k+1} = parseValue(paramValue{i});
                        end
                    end
                end
            
            function oValue = parseValue( iValue )
                num = str2double(iValue);
                if ~any(isnan(num))
                    oValue = num;
                elseif ischar(iValue)
                    tab = strsplit(iValue, ',');
                    if length(tab) == 1
                        oValue = regexprep(iValue, '\s+', '');
                    else
                        numTab = str2double(tab);
                        hasNonNumericValues = any(isnan(numTab));
                        if hasNonNumericValues
                            oValue = regexprep(tab, '\s+', '');
                        else
                            oValue = numTab;
                        end
                    end
                end
            end
        end
        
        function nbDesign = getNbDesigns( this )
            names = this.getNamesOfDesigns();
            isEmptyDesingName = ~cellfun(@isempty, names);
            nbDesign = sum(isEmptyDesingName);
            
%             nbColumns = this.getNbColumns;
%             nbDesign = nbColumns - this.NB_METADATA_COLUMNS;
        end
        
        function nameOfDesign = getNamesOfDesigns( this)
            nameOfColumns = this.getColumnNames();
            nameOfDesign = nameOfColumns((this.NB_METADATA_COLUMNS+1) :end);
        end
        
    end
    
    methods( Static )
        
        function this = fromDataTable( iDataTable )
            if ~isa( iDataTable, 'biotracs.data.model.DataTable' )
                error('A ''biotracs.data.model.DataTable'' is required');
            end
            this = biotracs.mimosa.model.DesignTable();
            this.doCopy( iDataTable );
        end
        
        
        function this = import( iFilePath, varargin )
            dataTable = biotracs.data.model.DataTable.import(iFilePath, varargin{:} );
            this = biotracs.mimosa.model.DesignTable.fromDataTable(dataTable);
        end
        
    end
    
    
end

