%% Run Intersect (IX) simulator by creating restart files
% The first restart time must be provided by the user. The code will run
% the simulation until the end time and will create restart files at the
% specified time steps. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Behzad Hosseinzadeh                                %
%                     contact: behzadh@dtu.dk                            %
%                     version: v1.0                                      %
%                     Date: 2024-01-22                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;clc;close all;



% This code sets the variable 'main_dir' to the current working directory.
% Ensure it is run from the directory containing the '*.afi' case.
main_dir = pwd;
cd(main_dir);

% input simulation parameters
formatOut           = 'dd-mmm-yyyy';
startSimulationTime = datetime(2000,01,01,00,00,00); % The first simulation time, where the model initialized
initialRestartTime  = datetime(2001,01,01,00,00,00); % The first restart time must be run manually by user
incrementRestartTime = calmonths(1); % It can be other time steps such as days, hours, minutes, seconds, etc.
startRestartTime    = initialRestartTime + incrementRestartTime;
endRestartTime      = datetime(2002,01,01,00,00,00);
fieldManagmentStrategyFM_file = '../Examples/Brine_MultipleComponent_ECL2IX_FM.ixf';
casename_afi        = '../Examples/Brine_MultipleComponent.afi';
[folderPath, caseName, ext] = fileparts(casename_afi);
tempFolder          = [folderPath, '/', 'temp'];    % temporary folder to store the restart files

% run the simulation
i       = 1;
i_x     = 1;
isFirstTimeStep = true;
while startRestartTime <= endRestartTime

    %% updating field management strategy file (adding new timestep)
    % read field management strategy file
    fid  = fopen(fieldManagmentStrategyFM_file, 'r');
    % Check if the file is opened successfully
    if fid == -1
        error('Unable to open the field management strategy file for appending the new time step.');
    end
    f = fread(fid,'*char')';
    fclose(fid);
    % find the last time step
    f = strrep(f,'END_INPUT',['DATE  "', datestr(startRestartTime,formatOut), '"  SAVE_RESTART    "*.', sprintf( '%04i', i),'"']);
    % write the new time step
    fid  = fopen(fieldManagmentStrategyFM_file, 'w+');
    % Check if the file is opened successfully
    if fid == -1
        error('Unable to open the field management strategy file for appending the new time step.');
    end
    fprintf(fid, '%s', f);
    fprintf(fid, '\n'); 
    fprintf(fid, ['#TIME   ', num2str(days(startRestartTime-startSimulationTime))]);
    fprintf(fid, '\n');
    fprintf(fid, '\n');
    fprintf(fid, 'END_INPUT');
    fclose(fid);

    %% run the simulation
    command = sprintf('eclrun ix %s', casename_afi);
    system(command);

    %% update the afi file
    try
        movefile([folderPath, '/', caseName,'_restart_', num2str(days(startRestartTime-startSimulationTime)),'_0', ext], casename_afi, 'f');
    catch
        disp('Error copying file.');
    end
    %% reading results from the restart file
    Reactions(casename_afi, i);

    %% Keep current time step result
    try
        movefile([folderPath, '/', caseName,'.INSPEC'], [folderPath, '/', caseName,'.INSPEC.',sprintf( '%04i', i)], 'f');
        movefile([folderPath, '/', caseName,'.PRT'], [folderPath, '/', caseName,'.PRT.',sprintf( '%04i', i)], 'f');
        movefile([folderPath, '/', caseName,'.RSSPEC'], [folderPath, '/', caseName,'.RSSPEC.',sprintf( '%04i', i)], 'f');
        movefile([folderPath, '/', caseName,'.SMSPEC'], [folderPath, '/', caseName,'.SMSPEC.',sprintf( '%04i', i)], 'f');
    catch
        disp('Error renaming currect time step result.');
    end
    if isFirstTimeStep
        % Check if the folder exists
        if ~exist(tempFolder, 'dir')
            % If the folder doesn't exist, create it
            mkdir(tempFolder);
            disp(['Folder created at: ' tempFolder]);
        end
        % This line of code retrieves the names of files in the specified folder that have a file extension starting with 'X'
        fileNames = {dir(fullfile(folderPath, ['*' '.X*'])).name};
        i_x_temp = zeros(1,length(fileNames));
        for j = 1:length(fileNames)
            % This line of code extracts the number from the file name	
            i_x_temp(j) = str2double(regexp(strjoin(fileNames(j)), '\d+', 'match'));
        end
        i_x = max(i_x_temp);
        isFirstTimeStep = false;
    end
    %% move restart files to the temp folder
    movefile([folderPath, '/', caseName,'.X',sprintf( '%04i', i_x)], [tempFolder, '/', caseName,'.X',sprintf( '%04i', i_x)], 'f');
    movefile([folderPath, '/', caseName,'.S',sprintf( '%04i', i_x)], [tempFolder, '/', caseName,'.S',sprintf( '%04i', i_x)], 'f');
    % update the start time
    initialRestartTime = startRestartTime;
    startRestartTime = startRestartTime + incrementRestartTime;
    if (startRestartTime == endRestartTime)
        clc;
        disp('----Simulatoin run successfully!----');
        break;
    elseif (startRestartTime > endRestartTime)
        startRestartTime = endRestartTime;
    end
    i = i + 1;
    i_x = i_x + 1;
    clc;
end

for k = max(i_x_temp):i_x
    movefile([tempFolder, '/', caseName,'.X',sprintf( '%04i', k)], [folderPath, '/', caseName,'.X',sprintf( '%04i', k)], 'f');
    movefile([tempFolder, '/', caseName,'.S',sprintf( '%04i', k)], [folderPath, '/', caseName,'.S',sprintf( '%04i', k)], 'f');
end

disp('----All time step results are transferreds successfully!----');