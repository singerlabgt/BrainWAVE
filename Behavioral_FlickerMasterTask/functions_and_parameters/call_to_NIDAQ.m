% 1 POTENTIAL ISSUE- SEE CAPITALIZED COMMENT
%
% CALL_TO_NIDAQ(app,command,varargin)
%
% Function that is called whenever the computer needs to interact with the
% NIDAQ. The call to the NIDAQ may be: generating an (audio-visual) signal,
% or some command (such as initializing the NIDAQ, stopping the current
% signal, etc).
%
% Inputs:
% 
% app: the app that is calling this function (contains information about
% properties such as whether the NIDAQ is connected, details of the NIDAQ
% sessions, etc).
%
% command: string specifying a command to the NIDAQ- can be one of several things:
% Note: if no additional arguments are provided in varargin, function will
% assume that the command is an "operation". Otherwise, it will assume that
% the command is the start of a condition, i.e. '40Hz-AV' for example- in
% that case, varargin contains the signal to be played.
% * 'initialize': initialize the NIDAQ, for the flickerneurophys
% experiment. This will reset the NIDAQ, create an analog and digital
% sessions, as well as a trigger connection between the 2 sessions.
% * 'stop': stops what is running on the analog session and flushes any remaining data, sets voltage
% value of analog session to 0, and sends a pulse on the digital session to
% indicate that we stopped.
% * 'test': used when testing the sync pulse and visual output (at begining
% of task). Sends a short pulse in the sync pulse channel and the
% visual output channel. This is useful to test whether everything works
% (i.e. do we see a pulse on EEG?).
% * other command(s) such as 'startTask', 'end Task', 'startOccluded', etc.
% to indicate what we're doing.
% * one of the conditions (i.e. '40Hz-AV', '5.5Hz-A', etc.). In that case,
% varagin must be provided.
%
% varargin: a 2-column vector of the signal to be played (1st
% column is visual signal, 2nd column is auditory signal).
%
%
% Log info:
% First log by LB on 2020/08/10.

function call_to_NIDAQ(app,command,varargin)
    if app.NIDAQDeviceConnected %only use NIDAQ if it is connected
        if isempty(varargin) %means no signal is provided (to be played on the analog session), and thus this must be an "operation" command
            if strcmp(command,'initialize') %call to initialize the NIDAQ
                daqreset; %in case there is a session that was already created or is running, reset the Data Acquisition Toolbox, delete all data acquisition sessions and objects.
                
                %set 2 analog channels (for visual and auditory outputs, respectively):
                app.NI_session_analog = daq.createSession('ni'); %create an analog daq session
                addAnalogOutputChannel(app.NI_session_analog,'Dev1',[0 1], 'Voltage'); %add 2 analog output channels; AO0 (0) is used for visual signal, AO1 (1) is used for sound signal
                app.NI_session_analog.Rate = app.NIDAQSampleRate; %specify the sample rate to be used in this session
                
                %set digital channel (which will indicate start of each trial, and code various commands):
                app.NI_session_digital=daq.createSession('ni'); %create a digital daq session
                app.NI_session_digital.Rate=10000;
                app.NI_session_digital.NumberOfScans=round(app.NI_session_digital.Rate/2); %maximum duration of digital session is half of a second, which means that can only have up to about 50 different sync pulse codes
                app.digital_channel=addCounterOutputChannel(app.NI_session_digital,'Dev1','ctr0','PulseGeneration'); %create a digital channel at PFI12; this is used for the coding sync pulse, and to trigger start of data queued in the analog session %CHECK IF CAN CHANGE OUTPUT COUNTER TO PFI1 (FOR PRACTICALITY OF CONNETING BNC CABLES)
                app.digital_channel.InitialDelay=0;
                app.digital_channel.Frequency=1; %means that for 100% duty cycle, pulse will be 1sec long; for pulse_duration*duty cycle, pulse will be pulse_duration long
                
                %add connection between the digital and analog sessions:
                addTriggerConnection(app.NI_session_analog,'External','Dev1/PFI12','StartTrigger'); %add a start trigger connection for the analog session, from the digital channel- whenever there is a rising edge recorded in the digital channel, data queued in the analog session will start
                app.NI_session_analog.ExternalTriggerTimeout=Inf; %there is no timeout when waiting for the start trigger
                
                %set values of all involved channels to 0 (in case previous
                %use of the NIDAQ left some of the channels at non-zero
                %value):
                outputSingleScan(app.NI_session_analog,[0 0]);
            elseif ismember(command,{'stop','end'}) %call to stop NIDAQ from doing whatever it is currently doing, and set values of channels involved back to 0; the same procedure needs to happen when want to stop NIDAQ, or when end a task (in case NIDAQ still running)
                stop(app.NI_session_analog); %stops the analog session, and flushes remaining data that was queued
                outputSingleScan(app.NI_session_analog,[0 0]); %assigns value 0 to analog session channels (i.e. turns off LED and sound), in case we stopped the session on a non-zero value
                pulse_duration=find(strcmp(app.SyncPulseCode,command))/100; %in seconds
                app.digital_channel.DutyCycle=pulse_duration;
                startForeground(app.NI_session_digital); %send a sync pulse to the recording system to notify that we've stopped the NIDAQ
            elseif strcmp(command,'test') %call to NIDAQ to test sync pulse, and visual and auditory outputs
                durationOfAnalogPulse=find(strcmp(app.SyncPulseCode,command))/100; %have the duration of analog pulse be the same as that of the digital pulse
                queueOutputData(app.NI_session_analog,[repmat(5,round(app.NIDAQSampleRate*durationOfAnalogPulse),2);[0 0]]); %queue analog data to be played
                app.NI_session_analog.startBackground(); %need to use in background mode so that we can lauch the startTrigger
                pulse_duration=find(strcmp(app.SyncPulseCode,command))/100;
                app.digital_channel.DutyCycle=pulse_duration;
                startForeground(app.NI_session_digital); %send a sync pulse to the recording system to notify that we've stopped the NIDAQ
            else %output a digital pulse which duration corresponds to given "operation"
                pulse_duration=find(strcmp(app.SyncPulseCode,command))/100;
                app.digital_channel.DutyCycle=pulse_duration;
                startForeground(app.NI_session_digital); %send a sync pulse to the recording system to notify that we've stopped the NIDAQ
            end
        elseif ~isempty(varargin) && length(varargin)==1 %if something is specified in varargin, means we're playing a signal from a given condition
            queueOutputData(app.NI_session_analog,[varargin{1};0 0]); %queue data to be played; in case signal ends on nonzero number, we add 0s at end of signal
            app.NI_session_analog.startBackground(); %need to use in background mode so that we can lauch the startTrigger
            pulse_duration=find(strcmp(app.SyncPulseCode,command))/100;
            app.digital_channel.DutyCycle=pulse_duration;
            startForeground(app.NI_session_digital); %send a sync pulse to the recording system to notify that we've stopped the NIDAQ
            wait(app.NI_session_analog); %blocks MATLAB until the background operation completes; Lou: my understanding is that because we're using a MATLAB app, we can still use the "stop" function, even though we placed a "wait"
        elseif ~isempty(varargin) && length(varargin)==2 %if there are 2 varargin, means that we want to play a condition for many minutes- requires slightly different code because can't output too big analog signal to NIDAQ at once
            app.NI_session_analog.IsContinuous=true; %NEED TO CHECK IF THIS INTERFERES WITH ANYTHING- ARE THERE BAD CONSEQUENCES FROM USING THIS?
            queueOutputData(app.NI_session_analog,[varargin{1}]); %queue the first minute of the signal
            app.NI_session_analog.startBackground(); %need to use in background mode so that we can lauch the startTrigger
            pulse_duration=find(strcmp(app.SyncPulseCode,command))/100;
            app.digital_channel.DutyCycle=pulse_duration;
            startForeground(app.NI_session_digital); %send a sync pulse to the recording system to notify that we've stopped the NIDAQ
            for min=2:varargin{2} %for whatever range of minutes we still need to play
                continue_flicker=0; %initialize continue_flicker as false
                queueOutputData(app.NI_session_analog,[varargin{1}]); %output 1 more minute worth of signal
                try wait(app.NI_session_analog,60)
                catch %error will be thrown if timeout reached before end of running queued data- means the NIDAQ was not stopped (there is still data cued); continue...
                    continue_flicker=1;
                end
                if continue_flicker~=1
                    break;
                end
            end
            app.NI_session_analog.IsContinuous=false; %set back to original setting
        end
    end
end