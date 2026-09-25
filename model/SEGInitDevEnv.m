function SEGInitDevEnv
%SEGInitDevEnv Function to set up the path for the development environment.
% DO NOT MODIFY THIS SCRIPT!
% This is just a wrapper for the centrally stored an maintained script in
% "\SW\sw_core_tools\matlab\scripts". 
% 
% 
% (c) 2018 SEG-Automotive Germany GmbH
%       Zaiser Stefan (SG/EEB2) <Stefan.Zaiser@SEG-automotive.com>
%       Hoffmann Andreas (SG/EEB2) <Andreas.Hoffmann5@SEG-automotive.com>
%
% 07.09.2018  v1.0: Initial Version 

baseDir = char(regexp(pwd, '.*P\d{3}_SW\', 'match')); % assumption: the developement stream startes with BRM2_8
% Matlab/Simulink settings and the modeling guidelines
settings_dir = fullfile(baseDir, 'sw_core_tools\matlab');

% ***** settings *****
fprintf(' ... adding the matlab settings & scripts directories to the path ... ');
if (0 == exist(settings_dir, 'dir'))
    error('The settings directory doesn''t exist. Correct the directory in the script!');
else
    addpath(genpath(settings_dir));
    fprintf(' done! \n');
end

% Run the centrally maintained init script
SEGInitDevEnvBackend(baseDir);

end