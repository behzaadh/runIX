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

% run the simulation
i = 1;
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

    %% update the afi file
    fid     = fopen(casename_afi,'r');
    f       = fread(fid,'*char')';
    fclose(fid);
    f       = strrep(f,sprintf( '%.1f', days(initialRestartTime-startSimulationTime)),sprintf( '%.1f', days(startRestartTime-startSimulationTime)));
    fid     = fopen(casename_afi,'w+');
    fprintf(fid, f);
    fclose(fid);
    %% run the simulation
    command = sprintf('eclrun ix %s', casename_afi);
    system(command);
    
    %% reading results from the restart file
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
    clc;
end