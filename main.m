function main( varargin )
    % Environment variables
    rootDir = fullfile(pwd, '../');

    % Parse inputs
    options.long = {'--help', '--params', '--gui', '--mcc', '--out'};
    options.short = {'-h', '-p', '-g', '-m', '-o'};
    options.value = { 'none', 'string', 'none', 'none', 'string'};
    options.description = { ...
        'Display help', ...
        'Define parameters as used by the Controller of the App. Format: valide {key, value} string evaluable using eval() function', ...
        'Show graphical user interface mode', ...
        'Compilation mode [not available for deployed apps]', ...
        'Define output directory' ...
    };

    try
        optionMap = parserShellOptions(options, varargin{:});
    catch err
        fprintf('%s\nPlease read manual or display help (--help) for more information.\n', err.message);
        %output = 0;
        return;
    end
  
    hasToCompile = ~isdeployed && isKey(optionMap, 'm');
    if hasToCompile  
        addpath( './tests' );
        addpath( './gui' );
        addpath( './gui/img' );
        autoload( ...
            'PkgPaths', { rootDir }, ...
            'Dependencies', {...
            'biotracs-m-mimosa', ...
            } ...
        );
        
        % compile application using mcc
        depPaths = biotracs.core.env.Env.depPaths();
        n = length(depPaths);
        arg = cell(1,2*n);
        arg(1:2:end) = {'-a'};
        arg(2:2:end) = depPaths;
        
        if ~isKey(optionMap, 'o') || ~ischar(optionMap('o')) || isempty(optionMap('o'))
            optionMap('o') = pwd();
        else
            optionMap('o') = fullfile(optionMap('o'));
        end
        
        arg(end+1:end+2) = {'-a', fullfile(pwd, './gui')};
        arg(end+1:end+2) = {'-a', fullfile(pwd, './gui/img')};

        fprintf('Compilation in progress ...\n');
        fprintf( 'mcc %s %s %s %s %s %s %s\n', '-m', 'main.m', '-v', '-w', 'enable',  strjoin(arg, ' '), ['-d ', optionMap('o')] );
        %return;
        
        if ~isfolder(optionMap('o'))
            mkdir(optionMap('o'))
        end
        
        mcc( '-m', 'main.m', '-v', '-w', 'enable', '-d', optionMap('o'), arg{:} );
        return;
    else
        % execute commands
        if isdeployed
            if ~isKey(optionMap, 'o')
                optionMap('o') = '';
            end
            biotracs.core.env.Env.workingDir(optionMap('o'));
        else
            addpath( './tests' );
            addpath( './gui' );
            addpath( './gui/img' );
            autoload( ...
                'PkgPaths', { rootDir }, ...
                'Dependencies', {...
                'biotracs-m-mimosa', ...
                } ...
            );
        end
        
        try
            if isKey(optionMap, 'h')
                displayHelp( options );
            elseif isKey(optionMap, 'g')
                showGui();
            elseif isKey(optionMap, 'p')
                run( optionMap('p')  )
            else
                %show gui by default
                showGui();
            end
        catch err
            fprintf('%s\nPlease read manual or display help (--help) for more information.\n', err.message);
        end
    end
end

function displayHelp( options )
    disp(' ');
    disp('+ Help for Biotracs-Mimosa App');
    disp('--------------------------------------------------------------');
    for i=1:length(options.short)
        fprintf(...
            '%s \n\tOptions:\t%s (%s) \n\tValue:\t\t%s\n\n', ...
            options.description{i}, ...
            options.short{i}, ...
            options.long{i}, ...
            options.value{i} ...
            );
    end
    
    disp(' ');
    disp('+ Dependency variables');
    disp('--------------------------------------------------------------');
    disp(biotracs.core.env.Env.vars());
end


function optionMap = parserShellOptions( validOptionKeys, varargin )
    optionMap = containers.Map();
    n = length(varargin); i = 1;

    if ~isfield(validOptionKeys, 'short')
        error('At least short option keys must be given');
    elseif ~isfield(validOptionKeys, 'long')
        validOptionKeys.long = validOptionKeys.short;
    elseif length(validOptionKeys.long) ~= length(validOptionKeys.short)
        error('The lengths of the valid long and short option keys must be the same');
    end

    while i <= n
        if isOptionKey( varargin{i} )
            idx = strcmpi( validOptionKeys.long, varargin{i} ) | strcmpi( validOptionKeys.short, varargin{i} );

            isValidKey = any(idx);
            if ~isValidKey
                error('Invalid option key ''%s''', varargin{i});
            end

            key = validOptionKeys.short( idx );
            key = regexprep(key, '^\-+(.*)','$1');

            if i+1 > n
                value = true; 
                i = i+1;
            else
                nextOptionIsAKey = isOptionKey( varargin{i+1} );
                if nextOptionIsAKey
                    value = ''; 
                    i = i+1;
                else
                    value = regexprep(varargin{i+1}, '^"?(.*)"$?', '$1');
                    i = i+2;
                end
            end
        else
            error('Invalid option key ''%s''', varargin{i});
        end
        optionMap(key{1}) = value;
    end

    function tf = isOptionKey( optionKey )
        tf = isShortOptionKey(optionKey) || isLongOptionKey(optionKey);
    end

    function tf = isShortOptionKey( optionKey )
        tf = ischar(optionKey) && ...
            length(optionKey) >= 2 && ...
            strcmp(optionKey(1), '-');
    end

    function tf = isLongOptionKey( optionKey )
        tf = ischar(optionKey) && ...
            length(optionKey) >= 4 && ...
            strcmp(optionKey(1:2), '--');
    end
end


%% Run console
function run( varargin )
    try
        var = eval(varargin{1});
    catch err
        error('BIOTRACS:Main', 'Invalid parameters\n%s', err.message);
    end
    ctrl = biotracs.mimosa.controller.Controller( var{:} );
    ctrl.run();
end


function showGui()
    popup_App;
end