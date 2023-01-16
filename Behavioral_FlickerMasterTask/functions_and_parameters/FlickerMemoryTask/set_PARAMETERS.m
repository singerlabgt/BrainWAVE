

function PARAMETERS=set_PARAMETERS()
    %parameters that apply to both study and test phases:
    PARAMETERS.fix_cross_duration.averageTime=1;
    PARAMETERS.fix_cross_duration.randomVariation=0.5;
    PARAMETERS.font_size=40;
    PARAMETERS.end_instruct = 'Task finished! Please press any key to exit.';
    
    

    PARAMETERS.image_duration=3;
    PARAMETERS.stim_duration=3;
    PARAMETERS.ISI=5;
    PARAMETERS.num_practice_images=4;
    PARAMETERS.num_study_images=168;
    PARAMETERS.sample_rate=44100;
    PARAMETERS.in_sound=repmat(sin(2*pi*800*(1:PARAMETERS.sample_rate*0.25)/PARAMETERS.sample_rate),2,1);
    PARAMETERS.out_sound=repmat(sin(2*pi*1200*(1:PARAMETERS.sample_rate*0.25)/PARAMETERS.sample_rate),2,1);
    PARAMETERS.initial_instruct='You will be presented with a set of pictures.\n\nPlease indicate for each item\n\nwhether you would typically encounter\n\nthat item INDOORS (left arrow) or OUTDOORS (right arrow).\n\n\n\nPress any key to continue...';
    PARAMETERS.practice_instruct='We will first do a few practice trials.\n\n\n\nPress any key to continue.';
    PARAMETERS.study_instruct='That''s the end of the practice.\n\nNow for the real thing ...\n\n\n\nPress any key to continue.';
    PARAMETERS.block_instruct = 'You have reached the end of a block.\n\nPress any key when\n\nyou are ready to continue the experiment.';
    
    
    PARAMETERS.test_image_duration=1;
    PARAMETERS.test_initial_instruct='You will be presented with a set of pictures you saw before, mixed with new pictures.\n\nPlease indicate for each item\n\nYES (left arrow) or NO (right arrow)\n\nif you remember seeing the image from\n\nany of those you saw previously.\n\n\n\nPress any key to continue...\n\n\n\nPress any key to continue.';
    PARAMETERS.test_trial_instruction='OLD, SURE          OLD, MAYBE          NEW, MAYBE          NEW, SURE\n\nC                         V                             B                          N';

    
end