%% MKA edit 1/22/20
% load variables

% opens browser, lets you click file 
%[FileName,PathName] = uigetfile({'*.mat'; '*.*'});

% or Hard code file name
FileName = '40HzAV50DC2Hr.mat';
PathName = 'C:\Users\matto\Box\Project_FlickerBloodFlow\Stimuli\MRI Stim\';
load([PathName, FileName]);



session_synched_stimuli = daq.createSession('ni');  %creates new sessions
% devices = daq.getDevices  % see what devices are available to this PC
addAnalogOutputChannel(session_synched_stimuli,'Dev1', [0 1], 'Voltage'); % AO.0 for sound, AO.1 for LED    

session_synched_stimuli.Rate = sample_rate;

%sound_signal_masked=sound_signal_masked*0.0001;

queueOutputData(session_synched_stimuli,[(sound_signal_masked)' (LED_signal_masked)']);

session_synched_stimuli.startForeground();

session_synched_stimuli.release()