% BIOASTER
%> @file		FeatureSummaryResult.m
%> @class		biotracs.mimosa.model.FeatureSummaryResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date        2019

classdef FeatureSummaryResult < biotracs.core.mvc.model.ResourceSet
    
    properties(SetAccess = protected)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = FeatureSummaryResult( varargin )
            %#function biotracs.mimosa.view.FeatureSummaryResult
            
            this@biotracs.core.mvc.model.ResourceSet( varargin{:} );
            this.bindView( biotracs.mimosa.view.FeatureSummaryResult() );
        end

        function this = setLabel( this, iLabel )
            this.setLabel@biotracs.core.mvc.model.ResourceSet(iLabel);
            this.setLabelsOfElements(iLabel);
        end
        
    end
    
    % -------------------------------------------------------
    % Static
    % -------------------------------------------------------
    
    methods(Static)
        
        function this = fromResourceSet( iResourceSet )
            if ~isa( iResourceSet, 'biotracs.core.mvc.model.ResourceSet' )
                error('A ''biotracs.core.mvc.model.ResourceSet'' is required');
            end
            this = biotracs.mimosa.model.FeatureSummaryResult();
            this.doCopy( iResourceSet );
        end
        
    end
    
end
