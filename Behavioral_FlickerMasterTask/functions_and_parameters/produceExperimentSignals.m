%
% sourceSignal=PRODUCEEXPERIMENTSIGNALS(experimentType,duty_cycle_LED,duty_cycle_sound,sound_frequency,type_of_burst,sample_rate)
%
% Produces a structure that provides information about trials of sensory
% flicker stimulation, to be eventually run on the NIDAQ. This is the
% data that the apps "SafetyTesting" and "RunTask" use.
%
%
% Inputs:
% 
% experimentType: either 'safety_testing' to create a structure for the
% SafetyTesting app, or 'neurophys_experiment' to create a structure for an actual
% experiment (i.e. for RunTask app).
%
% duty_cycle_LED: 0.5 would correspond to a 50% duty cycle for visual
% stimulus... see function produceSignals for more details.
%
% duty_cycle_sound: 0.5 would correspond to a 50% duty cycle for auditory
% stimulus...
%
% sound_frequency: the frequency of the tone that will be played for the
% auditory flicker; for ex., 7000 would correspond to 7000Hz, [500 7000]
% would correspond to white noise between 500 and 7000Hz.
%
% type_of_burst: describes the shape of the burst of sound; 'ramp_round'
% corresponds to bursts of sound with a quick but smoothed ON and OFF
% slopes.
%
% sample_rate: the sample rate to be used to create the signal that will
% be sent to the NIDAQ.
%
%
% Output:
%
% sourceSignal: a structure containing the following fields
% * 1 field for each periodic flicker frequency that will be played, providing the signal to
% be sent to the NIDAQ (both visual and auditory signals, in 2-column vector).
% * 1 field, 'Rand', containing x cells, each cell containing visual and auditory
% data for the random flicker signal to be played. There are as many of
% these cells as there are random trials in the experiment. For
% 'safety_testing' experimentType, there's only 1 cell.
% * 1 field, called 'trials_vector', corresponding to the vector of trials to be played (in 6
% sessions)
% * 1 field, 'sample_rate' indicating the sample rate of the signal, to be used on the NIDAQ.
%
%
% Log:
% 2020/08/10: first log by LB.

function sourceSignal=produceExperimentSignals(experimentType,duty_cycle_LED,duty_cycle_sound,sound_frequency,type_of_burst,sample_rate)
    
    %% Set parameters of experiment
    frequencies_tested=["R" "5.5Hz" "40Hz" "80Hz"];
    modalities_tested=["V" "AV" "A"];
    stimPeriod_duration=10; %in seconds
    numberOfTrials_perCondition=15;
    repeat_limit=[3 3]; %for experiment, maximum allowed number of consecutive trials of given frequency or modality
    randomFlicker_frequency=40; %picking average of 40Hz for random flicker
    
    %% Produce random trials' signals:
    sourceSignal=struct('Rand',[],'Hz5_5',[],'Hz40',[],'Hz80',[],'sample_rate',[]); % initialize sourceSignal structure
    sourceSignal.sample_rate=sample_rate;
    
    if strcmp(experimentType,'safety_testing') %if want to create signal for safety testing, only need to create 1 10s trial of random flicker
        sourceSignal.Rand=produceSignals(stimPeriod_duration,randomFlicker_frequency,1,duty_cycle_LED,duty_cycle_sound,sound_frequency,type_of_burst,sourceSignal.sample_rate); %create random AV flicker signal lasting 10s
    elseif strcmp(experimentType,'neurophys_experiment') % if want to create signals for an actual experiment
        
        %create a random vector of trials for the experiment (with no more than 3 repetitions of the same modality or frequency:
        temp=pseudorandomization({frequencies_tested;modalities_tested},repeat_limit,numberOfTrials_perCondition);
        
        trials_vector=strings(length(temp)/6,6); %initialize vector of trials: 6 columns, each corresponding to a session in this experiment (total of 6 sessions, ideally 10min each, per experiment)
        for i=1:6
            trials_vector(1:30,i)=temp((i-1)*30+1:i*30);
        end
        
        sourceSignal.trials_vector=trials_vector; %add information about trials into the main structure
        
        %produce the random signals:
        for i=1:sum(sum(contains(sourceSignal.trials_vector,'R'))) %need to create as many random flicker signals as there are random flicker trials in this experiment
            sourceSignal.Rand{i}=produceSignals(stimPeriod_duration,randomFlicker_frequency,1,duty_cycle_LED,duty_cycle_sound,sound_frequency,type_of_burst,sourceSignal.sample_rate);
        end
    else
        error('experimentType provided does not exist; please choose either safety_testing or neurophys_experiment');
    end
    
    %% Create periodic (non-random) signals:
    for frequency=[5.5 40 80]
        if frequency==5.5
            subfieldName='Hz5_5';
        elseif frequency==40
            subfieldName='Hz40';
        elseif frequency==80
            subfieldName='Hz80';
        end

        sourceSignal.(subfieldName)=produceSignals(stimPeriod_duration,frequency,0,duty_cycle_LED,duty_cycle_sound,sound_frequency,type_of_burst,sourceSignal.sample_rate);
    end

end

