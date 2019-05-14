% BIOASTER
%> @file		BaseProcess.m
%> @class		biotracs.mimosa.model.BaseProcess
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017

classdef (Abstract)BaseProcess < biotracs.core.mvc.model.Process
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = BaseProcess()
            this@biotracs.core.mvc.model.Process();
            this.configType = 'biotracs.mimosa.model.BaseProcessConfig';
            
            % set inputs specs
            this.setInputSpecs({...
                struct(...
                'name', 'FeatureSet',...
                'class', 'biotracs.spectra.data.model.MSFeatureSet' ...
                )...
                });

            % set outputs specs
            this.setOutputSpecs({...
                struct(...
                'name', 'FeatureSet',...
                'class', 'biotracs.spectra.data.model.MSFeatureSet' ...
                )...
                });
        end

    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
    end

end
