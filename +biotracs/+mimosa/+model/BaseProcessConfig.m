% BIOASTER
%> @file		BaseProcessConfig.m
%> @class		biotracs.mimosa.model.BaseProcessConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017


classdef (Abstract)BaseProcessConfig < biotracs.core.mvc.model.ProcessConfig
    
    
    properties(Constant)
        
    end
    
    properties(SetAccess = protected)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = BaseProcessConfig( )
            this@biotracs.core.mvc.model.ProcessConfig( );
        end

    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)
    end
    
end
