%NEED TO CHECK

function [PARAMETERS,trials]=initialize_FlickerMemoryTask()
    
    %% Establish memory task parameters
    PARAMETERS=set_PARAMETERS(); %set to day 1 parameters
    
    %% Pick and images we'll need for practice, study and test:
    num_images=PARAMETERS.num_practice_images+PARAMETERS.num_study_images+PARAMETERS.num_study_images/2; %calculate total number of images we need, including study and test phases
    imagesPath=mfilename('fullpath');
    imagesPath=[imagesPath(1:end-length(mfilename())) 'imageset_1a'];
    image_list=randomly_pick_images(imagesPath,num_images); %randomly pick that number of images from our image set:
    
    % Assign those objects and scenes to one of 3 groups: practice, study and test foils
    trials.practice=image_list(1:PARAMETERS.num_practice_images); %get practice images
    trials.study=image_list(PARAMETERS.num_practice_images+1:PARAMETERS.num_practice_images+PARAMETERS.num_study_images); %get study images
    trials.one_day_test=image_list(PARAMETERS.num_practice_images+PARAMETERS.num_study_images+1:end); %get new images that will be presented at test
    
    %% Assign stim condition to each trial, for the practice and study trials:
    stim_conditions=["Baseline" "R-AV" "5.5Hz-AV" "40Hz-AV"];
    
    %assign stim conditions to practice trials in random manner:
    temp=stim_conditions(randperm(length(stim_conditions)));
    for i=1:length(temp)
        trials.practice(i).stim_condition=temp(i);
    end
    
    %assign stim conditions to study trials in random manner:
    study_conditions=pseudorandomization_singlePulses(stim_conditions,3,42);
    for i=1:length(trials.study)
        trials.study(i).stim_condition=study_conditions(i);
    end
    
    %create randomized order of trials for test phase
    for i=1:length(trials.one_day_test)
        trials.one_day_test(i).status='new';
    end
    
    j=1;
    for i=length(trials.one_day_test)+1:length(trials.one_day_test)+length(trials.study)
        temp=trials.study(j);
        temp.status=temp.stim_condition;
        temp=rmfield(temp,'stim_condition');
        trials.one_day_test(i)=temp;
        j=j+1;
    end
    
    %NEED TO CHECK WHETHER THIS IS CORRECT:
    allConditions=["old" "new" "Baseline" "R_AV" "Hz5_5_AV" "Hz40_AV"];
    ncs=struct(allConditions(1),0,allConditions(2),0,allConditions(3),0,allConditions(4),0,allConditions(5),0,allConditions(6),0);
    conditions_iterated=[];
    ncs_condition_limit=3;
    test_trials=struct('fullname',[],'name',[],'status',[]);
    
    condition_trials=trials.one_day_test;
    i=0;
    numOfRandomizations=0;
    while i<PARAMETERS.num_study_images+PARAMETERS.num_study_images/2
        i=i+1;
        good=0;
        while (~good)
            temp_index=randperm(length(condition_trials),1);
            temp=condition_trials(temp_index).status;
            switch temp
                case "Baseline" %no stim and object
                    conditions_iterated=["old" "Baseline"];
                case "R-AV" %stim and object
                    conditions_iterated=["old" "R_AV"];
                case "5.5Hz-AV" %no stim and scene
                    conditions_iterated=["old" "Hz5_5_AV"];
                case "40Hz-AV" %stim and scene
                    conditions_iterated=["old" "Hz40_AV"];
                case "new"
                    conditions_iterated="new";
            end
            
            if (length(conditions_iterated)==1 && ~any([ncs.(conditions_iterated(1))]>ncs_condition_limit-1))...
            || (length(conditions_iterated)==2 && ~any([ncs.(conditions_iterated(1)) ncs.(conditions_iterated(2))]>ncs_condition_limit))
                good=1;
                for j=conditions_iterated
                    ncs.(j)=ncs.(j)+1;
                end
                for j=setdiff(allConditions,conditions_iterated)
                    ncs.(j)=0;
                end
            else
                num_repeats=num_repeats+1;
                if num_repeats>10 %if this is is more than the 10th time you're trying to pick trial from the remaining trials, it is likely that there are not different trials left- restart randomization
                    numOfRandomizations=numOfRandomizations+1;
                    condition_trials=trials.one_day_test;
                    test_trials=struct('fullname',[],'name',[],'status',[]);
                    i=0;
                    for j=allConditions
                        ncs.(j)=0;
                    end
                    num_repeats=0;
                    break;
                end
                good=0;
            end
        end
        if good==1
            test_trials(i)=condition_trials(temp_index);
            condition_trials(temp_index)=[];
            num_repeats=0;
        end
    end
    
    trials.one_day_test=test_trials;
    
end