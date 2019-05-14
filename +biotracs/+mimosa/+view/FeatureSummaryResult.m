% BIOASTER
%> @file		FeatureSummaryResult.m
%> @class		biotracs.mimosa.view.FeatureSummaryResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018


classdef FeatureSummaryResult < biotracs.core.mvc.view.ResourceSet
    

    
    
    methods
        
        function [h1, h2] = viewFeatureSummaryPlot( this, varargin )  
            model = this.getModel();
            
            intensities = model.getElementByName('intensities');
                    
            h1 = intensities.view(...
                'HeatMap', ...
                varargin{:} ...
                );
        
            qcCv = model.getElementByName('qcCvValues');
            h2 = qcCv.view(...
                'HeatMap', ...
                varargin{:} ...
                );
        
            
        end
        
    end
    

end
