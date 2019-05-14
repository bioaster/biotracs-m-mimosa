% BIOASTER
%> @file		ConfigTable.m
%> @class		biotracs.mimosa.model.UserConfigTable
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018


classdef UserConfigTable < biotracs.data.model.ExtDataTable
    
    properties(Constant)
    end
    
    methods
        
        function this = UserConfigTable( varargin )
            this@biotracs.data.model.ExtDataTable( varargin{:} );
           
        end
        
        function dataTable = get( this, varargin )
            dataTable = this.get@biotracs.data.model.ExtDataTable(varargin{:});
            
            dataTable.setRowNames( dataTable.data(:,1) );
            dataTable = biotracs.mimosa.model.DesignTable.fromDataTable(dataTable);
        end

    end
    
    methods( Static )
        
        function this = fromExtDataTable( iExtDataTable )
            if ~isa( iExtDataTable, 'biotracs.data.model.ExtDataTable' )
                error('A ''biotracs.data.model.ExtDataTable'' is required');
            end
            this = biotracs.mimosa.model.UserConfigTable();
            this.doCopy( iExtDataTable );
        end
        
        
        function this = import( iFilePath, varargin )
            extTable = biotracs.data.model.ExtDataTable.import(iFilePath, varargin{:} );
            this = biotracs.mimosa.model.UserConfigTable.fromExtDataTable(extTable);
        end
        
    end
    
    
end

