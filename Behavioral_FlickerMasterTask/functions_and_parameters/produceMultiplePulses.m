

function Source_Signal=produceMultiplePulses(experimentType,source_signal,inter_trial_interval,nber_trials,sample_rate)
    
    conditions=["V" "AV" "A"];
    if strcmp(experimentType,'safety_testing')
        nber_trials_perCondition=10;
        
        for c=1:length(conditions)
            if strcmp(conditions(c),'V')
                multiplication_factor=[1 0];
            elseif strcmp(conditions(c),'AV')
                multiplication_factor=[1 1];
            elseif strcmp(conditions(c),'A')
                multiplication_factor=[0 1];
            end
            
            for i=1:nber_trials_perCondition
                signal=source_signal.*multiplication_factor;
                added_interval=round(rand*inter_trial_interval*sample_rate);
                Source_Signal.(conditions(c)){i}=[signal;zeros(added_interval,2)];
            end
        end
        
    elseif strcmp(experimentType,'neurophys_experiment')
        trials_vector=pseudorandomization_singlePulses(conditions,3,nber_trials);
        
        Source_Signal.trials_vector=trials_vector;
        
        for i=1:length(Source_Signal.trials_vector)
            if strcmp(Source_Signal.trials_vector(i),'V')
                multiplication_factor=[1 0];
            elseif strcmp(Source_Signal.trials_vector(i),'AV')
                multiplication_factor=[1 1];
            elseif strcmp(Source_Signal.trials_vector(i),'A')
                multiplication_factor=[0 1];
            end
            signal=source_signal.*multiplication_factor;
            Source_Signal.added_intervals{i}=round(rand*inter_trial_interval*sample_rate); %keep record of how much we've added
            Source_Signal.signals{i}=[signal;zeros(Source_Signal.added_intervals{i},2)];
        end
    end
    
end