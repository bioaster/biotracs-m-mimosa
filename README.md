# BioTracs Mimosa application

Visit the official BioTracs Website at https://bioaster.github.io/biotracs/

The `biotracs-m-mimosa` application provides MATLAB libraries for the processing and analysis of mass spectrometry data.

![BioTracs framework](https://bioaster.github.io/biotracs/static/img/biotracs-m-mimosa.png)

BioTracs-MIMOSA (Mass spectrometry processIng of MetabOlomicS DatA) is a transversal computational application for _metabolomics_ based on BioTracs. It allows building simple to complex pipelines to process and analyze metabolomics data with a high reproducibility and traceability. It is ready-to-use, fast, extendable and designed to handle large metabolomics data. It also allows interfacing available external software and built-in functions for data normalization, statistical analysis and the identification of metabolites.

# Learn more about the biotracs project.

To learn more about the biotracs project, please refers to https://github.com/bioaster/biotracs

# Usage

Please refer to the documentation at https://bioaster.github.io/biotracs/documentation

## Keep in mind!

* The `autoload.m` file is available in the directory (./tests/)
* Some examples of user configuration files are available in directory (./usage/user_config_files/)
* When calling `autoload()` function, the argument `PkgPaths` refers to the list directory paths containing all the BioTracs applications. It however is recommended to keep all the applications in the same directory.

## Usage code

```matlab
% file main.m
%-------------------------------------------------

addpath('/path/to/atoload.m/');
pkgDir = fullfile('/path/to/package/dir/');
autoload( ...
	'PkgPaths', { pkgDir }, ...
	'Dependencies', {...
		'biotracs-m-mimosa', ...
	}, ...
	'Variables',  struct(...
		'OpenMSBinPath', 'C:/Program Files/OpenMS-2.3.0/bin/', ...
		'MzConvertFilePath', 'C:/Program Files/ProteoWizard/ProteoWizard 3.0.9992/msconvert.exe' ...
		...
		'RAW_DATA_DIR', '/path/to/raw/data/', ...
        'MZXML_DATA_DIR', '/path/to/mzxml/data/', ...
        'METADATA_FILE_PATH', '/path/to/metadata.csv', ...
	) ...
);

% Configure application controller
% Examples of user configuration files are available in the './usage/user_config_files/' sub-directory
ctrl = biotracs.mimosa.controller.Controller(...
	'Batches', { '1', '2', '1_2'}, ...
	'Polarities', {'Neg', 'Pos', 'NegPos'}, ...
	'UserConfigFilePath', '/path/to/usage/user_config_files/UserConfig_NoConvert.csv/' ...
);

% Override global working directory
biotracs.core.env.Env.workingDir('/path/of/the/working/directory');

%ctrl.convertAction( );			%comment this line if the .raw files are already converted to .mzXML (ensure that the appropriate user configuration file is used)
ctrl.extractionAction( );
ctrl.linkingAction( );
ctrl.preprocessingAction( );

% Unless otherwise specified, the output results will be written in %USER_HOME_DIR%/BIOASTER/BIOTRACS/Mimosa
```

# License

BIOASTER license https://github.com/bioaster/biotracs/blob/master/LICENSE