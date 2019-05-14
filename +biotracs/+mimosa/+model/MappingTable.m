% BIOASTER
%> @file		MappingTable.m
%> @class		biotracs.mimosa.Model.MappingTable
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018
classdef MappingTable < biotracs.data.model.DataTable
    
    properties(Constant)
        PROCESS_TYPE_COLUMN = 'ProcessType';
    end
    
    methods
        
        function this = MappingTable( iData, varargin )
            if nargin == 0, iData = {}; end
            this@biotracs.data.model.DataTable( iData, varargin{:} );
        end
        
    end
    
end

