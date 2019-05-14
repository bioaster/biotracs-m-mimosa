% BIOASTER
%> @file		AdductMatrix.m
%> @class		biotracs.mimosa.view.AdductMatrix
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017


classdef AdductMatrix < biotracs.data.view.DataMatrix
    
    properties(SetAccess = protected)
    end
    
    methods
        
        function h = viewFeatureGroupingPlot( this, varargin )  
            model = this.getModel();
            nbRedundant =  sum( sum(model.data) >= 1 );
            nbIsoFeatures=  sum( sum(model.data == 1) >= 1 );
            nbAdductsFeatures= sum( sum(model.data == 2) >= 1 );
            levelNames = {...
                ['redundants = ', num2str(nbRedundant)], ...
                ['isofeatures = ', num2str(nbIsoFeatures)],...
                ['Putative Adducts = ', num2str(nbAdductsFeatures)]...
                };
  
            h = this.model.view(...
                'SparsityPlot', ...
                'SparsityLevels', [1,2,3], ...
                'SparsityLevelNames', levelNames, ...
                varargin{:} ...
                );

            xlabel('Features');
            ylabel('Features'); 
        end
        
    end
    
    methods(Access = protected)
        
        
    end
end
