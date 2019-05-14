% BIOASTER
%> @file 		ConsensusExtDataTable.m
%> @class 		biotracs.mimosa.model.ConsensusExtDataTable
%> @link			http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date	    2017

classdef ConsensusExtDataTable <  biotracs.data.model.ExtDataTable
    
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
        function this = ConsensusExtDataTable()
            this@ biotracs.data.model.ExtDataTable();
            this.setDescription('Importing the Consensus table');
        end
        
    end
    
    methods(Static)
        
        function this = fromExtDataTable( iExtDataTable )
            if ~isa( iExtDataTable, 'biotracs.data.model.ExtDataTable' )
                error('A ''biotracs.data.model.ExtDataTable'' is required');
            end
            this = biotracs.mimosa.model.ConsensusExtDataTable();
            this.doCopy( iExtDataTable );
        end
        
        function this = import( iFilePath, varargin )
            idx = strcmpi(varargin, 'TableClass');
            isTableClassDefined = any(idx);
            if ~isTableClassDefined
                varargin = [varargin, {'TableClass', 'biotracs.mimosa.model.ConsensusExtDataTable'}];
            else
                varargin{ find(idx)+1 } = 'biotracs.mimosa.model.ConsensusExtDataTable';
            end
            this = biotracs.data.model.ExtDataTable.import( iFilePath, varargin{:} );
        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
    end
    
    
end
