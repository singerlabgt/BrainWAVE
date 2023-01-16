% NEED TO CHECK IF CORRECT (MODIFIED IT FOR THIS TASK
%
% ASK ANNABELLE IF WAY WE HAVE THIS RANDOMIZATION ORGANIZED OK
%
% study_conditions = PSEUDORANDOMIZATION(conditions,repeat_limit,number_trials_per_condition)
% 
% Randomizes trials in a way that does not repeat a trial of a given
% condition quality (for ex. modality or frequency of flicker) too many times.
%
%
% Inputs:
%
% conditions: the conditions that you want to randomize, organized by
% quality of the condition (such as frequency and modality)- maximum of 2
% qualities allowed.
% Ex:conditions = {["R" "5.5Hz" "40Hz" "80Hz"];["V" "AV" "A"]} means we
% would like the following conditions to be played: "R-V", "R-AV", "R-A",
% "5.5Hz-V", "5.5Hz-AV", "5.5Hz-A" etc...
%
% repeat_limit: the maximum number of repeats allowed for a given condition
% quality (such as frequency and modality).
% Ex: repeat_limit = [3 4] means a given frequency shown above or modality
% shown above can only be repeated 3 and 4 times in a row, respectively.
%
% number_trials_per_condition: the number of trials we would like per
% condition.
% Ex: number_trials_per_condition = 15 means we would like the condition
% "R-V" (and all other conditions specified above) to be played 15 times in
% total.
%
%
% Output: 
%
% study_conditions: a vector of strings indicating the order of trials from given
% conditions, for ex ["R-V" "80Hz-A"...].

function study_conditions=pseudorandomization_singlePulses(conditions,repeat_limit,number_trials_per_condition)
    
    number_conditions=length(conditions); %calculate the number of unique conditions
    number_trials_total=number_conditions*number_trials_per_condition; %calculate total number of trials
    
    %create a vector of all unique conditions:
    conditions_trials_original=repmat(conditions,1,number_trials_per_condition); %create an original vector of all trials (not randomized)

    ncs_quality=zeros(1,length(conditions)); %initialize the counting of consecutive trials with quality1 condition
    study_conditions=strings(1,number_trials_total); %initialize vector of trials for this experiment- this vector will progressively be filled with trials
    condition_trials=conditions_trials_original; %vector of trials from which we will randomly pick trials
    i=0;
    num_repeats=0; %for given loop iteration, corresponds to number of times we try to randomly pick a trial without it being a consecutive iteration that is not allowed (i.e. quality 1 or 2 repeated more than 3 times in a row)
    numOfRandomizations=0; %number of times we had to restart the randomization process (because there were no trials remaining available that would allow to respect the repeat_limit)
    while i<number_trials_total %each loop randomly picks a trial from conditions_trials and assigns it to study_conditions
        i=i+1; %move on to the next trial
        good=0; %start by assuming the requirement (repeat_limit) is not satisfied
        while ~good %while the requirement is not satisfied, keep trying to randomly pick a trial that would satisfy our requirement
            temp_index=randperm(length(condition_trials),1); %randomly pick the index of an element in condition_trials
            temp=condition_trials(temp_index); %get the trial corresponding to that randomly picked index
            conditions_iterated=temp; %find which conditions from quality 1 and quality 2 were used in this picked trial
            
            temp_ncs_quality=zeros(1,length(conditions)); %re-initialize temp_ncs
            temp_ncs_quality(conditions==conditions_iterated)=ncs_quality(conditions==conditions_iterated)+1; %add 1 to the condition of quality1 that is being re-iterated in this newly picked trial

            if ~any(temp_ncs_quality>repeat_limit) %check whether with this newly picked trial, we are failing the requirement
                good=1; %if not failing the requirement, this trial is good, we're keeping it
                ncs_quality=temp_ncs_quality; %update ncs_quality1
                study_conditions(i)=temp; %assign the newly picked trial into our growing vector of trials
                condition_trials(temp_index)=[]; %remove this trial from the vector from which we pick trials
                num_repeats=0; %re-initialize this variable- we're about to move on to pick the next trial
            else
                num_repeats=num_repeats+1; %when trying to pick a trial, keep track of how many times we try to pick a trial that satisfies our requirements
                if num_repeats>10 %if this is is more than the 10th time you're trying to pick a trial from the remaining trials, it is likely that there are not trials left that would satisfy our requirement- restart randomization
                    numOfRandomizations=numOfRandomizations+1; %keep track of how many times we restart the randomization
                    condition_trials=conditions_trials_original; %re-initialize the vector of trials from which we pick trials
                    study_conditions=strings(1,number_trials_total); %re-initialize the growing vector of trials
                    i=0; %re-initialize the trial at which we are
                    ncs_quality=zeros(1,length(conditions)); %re-initialize ncs_quality1
                    num_repeats=0; %re-initialize this variable
                    break; %get out of the while ~good loop
                end
            end
        end
    end
    
end

