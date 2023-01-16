%NEED TO CHECK
%
% sourceSignal=PRODUCEEXPERIMENTSIGNALS_FLICKERFREQUENCY(experimentType,duty_cycle_LED,duty_cycle_sound,sound_frequency,type_of_burst,sample_rate)
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

function sourceSignal=produceExperimentSignals_FlickerFrequency(safetyTesting,duty_cycle_LED,duty_cycle_sound,sound_frequency,type_of_burst,sample_rate,frequencies_tested,modalities_tested,repeat_limit,stimPeriod_duration,postStimPeriod,numberOfTrials_perCondition,nber_sessions,trial_random)
    
    %% Set parameters of randomization
    randomFlicker_frequency=40; %picking average of 40Hz for random flicker
    jittered_interval=0.5; %maximum of 0.5s added to the postStimPeriod
    
    %% Produce all signals:
    %create a structure that will store all 
    sourceSignal=struct();
    sourceSignal.sample_rate=sample_rate;
    sourceSignal.added_intervals={}; %this will store how long of a 0.5s jittered interval should we add at the end of a trial
    for i=1:length(frequencies_tested)
        if frequencies_tested(i)==-1 %means random
            if ~safetyTesting
                for j=1:numberOfTrials_perCondition
                    sourceSignal.Rand{j}=produceSignals(stimPeriod_duration,randomFlicker_frequency,1,duty_cycle_LED,duty_cycle_sound,sound_frequency,type_of_burst,sourceSignal.sample_rate);
                    sourceSignal.Rand{j}=[sourceSignal.Rand{j};zeros(sourceSignal.sample_rate*postStimPeriod,2)];
                end
            elseif safetyTesting %only need to create 1 random frequency trial
                sourceSignal.Rand{1}=produceSignals(stimPeriod_duration,randomFlicker_frequency,1,duty_cycle_LED,duty_cycle_sound,sound_frequency,type_of_burst,sourceSignal.sample_rate);
                sourceSignal.Rand{1}=[sourceSignal.Rand{1};zeros(sourceSignal.sample_rate*postStimPeriod,2)];
            end
        elseif frequencies_tested(i)==0 %means baseline
            sourceSignal.Baseline=zeros(sourceSignal.sample_rate*(stimPeriod_duration+postStimPeriod),2);
        else
            sourceSignal.(['Hz' regexprep(num2str(frequencies_tested(i)),'\.','_')])=[produceSignals(stimPeriod_duration,frequencies_tested(i),0,duty_cycle_LED,duty_cycle_sound,sound_frequency,type_of_burst,sourceSignal.sample_rate);zeros(sourceSignal.sample_rate*postStimPeriod,2)];
        end
    end
    
    %% Set order of trials (in case we are running experiment, i.e. not necessary for safetyTesting):
    if safetyTesting
        for i=1:sum(frequencies_tested~=0) %for all frequencies tested except baseline condition
            sourceSignal.added_intervals{i}=round(rand*jittered_interval*sample_rate); %add jittered interval to postStimPeriod
        end
    elseif ~safetyTesting
        %set correct names of conditions:
        temp_frequencies_tested=frequencies_tested;
        temp_frequencies_tested=strtrim(string(num2str(temp_frequencies_tested')));
        temp_frequencies_tested(~ismember(temp_frequencies_tested,'-1'))=strcat(temp_frequencies_tested(~ismember(temp_frequencies_tested,'-1')),'Hz');
        temp_frequencies_tested(ismember(temp_frequencies_tested,'-1'))='R';
        if any(ismember(temp_frequencies_tested,'0Hz'))
            baseline_present=1;
            temp_frequencies_tested(ismember(temp_frequencies_tested,'0Hz'))=[];
        end

        if strcmp(trial_random,'pseudorandom')
            %create a random vector of trials for the experiment (with no more than x repetitions of the same modality or frequency):
            temp=pseudorandomization({temp_frequencies_tested;modalities_tested},repeat_limit,numberOfTrials_perCondition);

            %add randomly interspersed baseline trials if needed:
            if baseline_present
                satisfied=0;
                while ~satisfied
                    baseline_rand=sort(randsample(length(temp),numberOfTrials_perCondition)); %randomize indices where baseline trials will be inserted
                    if ~any(baseline_rand(end:-1:1)-[baseline_rand(end-1:-1:1);0]<round(length(temp)/numberOfTrials_perCondition/2)) %we want baseline trials to be separated by reasonable amount of trials
                        satisfied=1;
                    end
                end
                for i=1:length(baseline_rand) %insert baseline trials
                    temp=[temp(1:baseline_rand(i)-1) "Baseline" temp(baseline_rand(i):end)];
                    baseline_rand=baseline_rand+1;
                end
            end

        elseif strcmp(trial_random,'distributed_random')
            nber_stimconditions=length(temp_frequencies_tested)*length(modalities_tested);
            temp=strings(1,numberOfTrials_perCondition*nber_stimconditions);

            for i=0:numberOfTrials_perCondition-1
                temp(nber_stimconditions*i+1:nber_stimconditions*i+nber_stimconditions)=pseudorandomization({temp_frequencies_tested;modalities_tested},repeat_limit,1);
            end

            if baseline_present
                baseline_rand=sort(datasample(1:nber_stimconditions,numberOfTrials_perCondition)); %randomly sample from 1 to number of stim conditions, with replacement, a numberOfTrials_perCondition times
                for i=1:length(baseline_rand) %insert baseline trials
                    temp=[temp(1:(i-1)*(nber_stimconditions+1)+baseline_rand(i)-1) "Baseline" temp((i-1)*(nber_stimconditions+1)+baseline_rand(i):end)];
                end
            end
        end

        %divide trials up into x sessions:
        trials_vector=strings(ceil(length(temp)/nber_sessions),nber_sessions); %initialize vector of trials: 6 columns, each corresponding to a session in this experiment (total of 6 sessions, ideally 10min each, per experiment)
        for i=1:nber_sessions
            if i~=nber_sessions
                trials_vector(1:ceil(length(temp)/nber_sessions),i)=temp((i-1)*ceil(length(temp)/nber_sessions)+1:i*ceil(length(temp)/nber_sessions));
            elseif i==nber_sessions
                trials_vector(1:length(temp((i-1)*ceil(length(temp)/nber_sessions)+1:end)),i)=temp((i-1)*ceil(length(temp)/nber_sessions)+1:end);
            end
        end

        sourceSignal.trials_vector=trials_vector; %add information about trials into the main structure
        
        for i=1:length(frequencies_tested)*numberOfTrials_perCondition %for total number of trials, add a specific jittered interval to postStimPeriod
            sourceSignal.added_intervals{i}=round(rand*jittered_interval*sample_rate); %add jittered interval to postStimPeriod
        end
    end

end

