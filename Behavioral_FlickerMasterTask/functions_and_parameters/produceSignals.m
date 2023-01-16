%
% signal=PRODUCESIGNALS(trial_duration,flicker_frequency,flicker_random,LED_duty_cycle,sound_duty_cycle,sound_frequency,type_of_burst,sample_rate)
%
% Creates visual and audio flicker signals to be sent to the NIDAQ, with given
% parameters provided in the input.
%
%
% Inputs:
%
% trial_duration: the duration of given trial (i.e. signal to be created),
% in seconds.
%
% flicker_frequency: the frequency of flicker (for ex: 40 for 40Hz). In
% case of radom flicker, refers to the average flicker frequency.
%
% flicker_random: is this a trial with random flicker? 1=yes, 0=no. If 1=yes, the
% "flicker_frequency" above determines the mean flicker frequency of the
% random signal.
%
% LED_duty_cycle: the duty cycle of the LED signal. If <1, means we are
% talking about % duty cycle (ex: 0.5 is 50% duty cycle); if>=1, means 
% we're talking about ms of duty cycle (ex: 1.2 is 1.2ms duty cycle, i.e. 1.2ms ON, rest of cycle OFF).
%
% sound_duty_cycle: as above, for sound.
% WARNING: if LED and sound have different duty cycles, sound_duty_cycle
% must be < to LED_duty_cycle, in duration. This is because of the random condition.
%
% sound_frequency: the tone to be played for each ON burst of the flicker;
% 1 value means a pure tone of that frequency will be played, while 2 values means white
% noise from between those 2 frequencies will be played.
% Ex: 7000 means 7000Hz tone will be played.
%     [500 7000] means white noise from between 500Hz and 7000Hz will be
%     played.
%
% type_of_burst: type of burst for the sound signal; this is because having
% a square wave signal for sound tends to give a "clicking" noise at onset
% and offset of burst, when using headphones. In general, use 'ramp_round':
% the onset and offset of the sound bursts are smoothened.
% WARNING: if you choose a type_of_burst, part of the ON phase will be
% dedicated to OFF-ON and ON-OFF transitions, which means that in that case
% the sound_duty_cycle must be of a long enough duration to encompass those
% transitions (for ex, if sound_duty_cycle is 1ms, and transition is 3ms
% total, this will not work).
%
% sample_rate: the sample rate of the signal (ex: 250000).
%
%
% Output:
%
% signal: the signal produced, to be sent to the NIDAQ, based on the
% provided inputs. This signal is a 2-column vector, with first column
% refering to the visual signal and second column
% refering to the sound signal.
%
% Log:
% 2020/08/10: first log by LB.

function signal=produceSignals(trial_duration,flicker_frequency,flicker_random,LED_duty_cycle,sound_duty_cycle,sound_frequency,type_of_burst,sample_rate)
    
    %% get the base LED and sound signals:
    LED_signal=5; %value of LED signal ON
    sound_multiplication_factor=0.01; %this indicates by what factor user wants to multiply sound signal values- LEPY amplifier needs 0.01 to allow use of full range of volume knob
    sound_signal=sound_multiplication_factor.*generate_sound(sound_frequency,sample_rate); % 1s of sound_signal at appropriate range; the generate_sound function provides a max value of 1

    %% create base vectors of ON and OFF phases for the whole trial duration:
    nber_samples_total=sample_rate*trial_duration; %calculate total number of samples for this trial
    nber_samples_cycle=round(sample_rate/flicker_frequency); %calculates number of samples per ON/OFF cycle. Note: because we're rounding, if division doesn't give an integer, the signal will technically not be exactly at flicker frequency (but close enough)
    
    if LED_duty_cycle<1 %means we're talking about percent duty cycle
        nber_samples_ON_LED=round(nber_samples_cycle*LED_duty_cycle); %calculate the number of samples per ON phase of cycle. Note: again because we're rounding, if the number_samples_ON_LED was not an integer, the ON or the OFF phase will be longer or shorter than it should be, but close enough
    elseif LED_duty_cycle>=1 %means we're talking about number of ms ON
        nber_samples_ON_LED=round(sample_rate*0.001*LED_duty_cycle); %calculate the number of samples per ON phase of cycle
    end
        pulse_train_mask_LED=create_signal_vector(nber_samples_ON_LED,nber_samples_cycle,nber_samples_total,flicker_random); %create vector of 0s and 1s indicating when signal should be ON or OFF, per sample.
        
    if LED_duty_cycle==sound_duty_cycle
        nber_samples_ON_sound=nber_samples_ON_LED;
        pulse_train_mask_sound=pulse_train_mask_LED;
    else
        %if sound duty cycle is different from LED duty cycle, we still
        %want the start of ON phases of sound to be aligned with the start
        %of ON phases of LED. In the case of random condition, the sound
        %flicker needs to have a duty cycle that is equal or inferior in
        %duration to the LED duty cycle
        if sound_duty_cycle<1 %means we're talking about percent duty cycle
            nber_samples_ON_sound=round(nber_samples_cycle*sound_duty_cycle);
        elseif sound_duty_cycle>=1 %means we're talking about number of ms ON
            nber_samples_ON_sound=round(sample_rate*0.001*sound_duty_cycle);
        end
        
        pulse_train_mask_sound=zeros(1,nber_samples_total); %initialize vector
        temp=contiguous(pulse_train_mask_LED); %get start and end indices of 0s and 1s
        temp=temp{2,2}(:,1); %get start indices of 1s
        for i=1:length(temp)
            pulse_train_mask_sound(temp(i):temp(i)+nber_samples_ON_sound-1)=1;
        end
        
        if length(pulse_train_mask_sound) > nber_samples_total %if went over the actual planned length of the trial, correct it by removing whatever's extra
            pulse_train_mask_sound = pulse_train_mask_sound(1:nber_samples_total);
        end
    end
    
    
    %% add LED and sound signals to the vector of 1s and 0s:
    LED_signal_masked = LED_signal*pulse_train_mask_LED; %incorporate the LED signal for each ON period
    
    %incorporate sound signal for each ON period:
    Ts_ON_sound=1:nber_samples_ON_sound;
    sound_signal_ON=sound_signal(Ts_ON_sound);

    if ~isempty(type_of_burst) %if user specified a type of burst (to smooth the ON and OFF transitions in the sound signal)
        nber_samples_transition=round(0.25*((1/80)/2)*sample_rate); %number of samples that will be dedicated to transition (from OFF-ON or ON-OFF); here, we pick 25% of the ON phase of 80Hz flicker, i.e. about 1.5625ms
        if strcmp(type_of_burst,'ramp') %transition from OFF-ON and ON-OFF is characterized by simple exponential ramp
            temp=0:nber_samples_transition-1;
            y_transition=temp.^2; %draw the ramping part of the ON phase using x^2 as the equation
            y_transition=y_transition/max(y_transition); %have the max value be 1
            nber_samples_fullyON=length(sound_signal_ON)-2*nber_samples_transition; %calculate number of samples which are not part of transition, within the phase ON
            y_fullyON=ones(1,nber_samples_fullyON); %draw part of ON phase that is fully ON
            
            signal_burst=[y_transition y_fullyON y_transition(end:-1:1)]; %draw the full shape of the ON phase
            
        elseif strcmp(type_of_burst,'ramp_round') %transition from OFF-ON and ON-OFF is characterized by exponential ramp and rounding (asymptote)
            temp=0:round(nber_samples_transition/2)-1; %set x values for exponential part of the transition
            y_transition1=temp.^2; %first half of the OFF-ON transition is x^2 curve
            y_transition1=y_transition1/max(y_transition1)/2; %max value of this first half of transition is 0.5

            y_transition2=-y_transition1; 
            y_transition2=y_transition2(end-1:-1:1); %want 2nd half of the OFF-ON transition to be a horizontal asymptote; removed 1 data point so that overall sigmoid curve is smooth
            y_transition2=y_transition2+1; %second part of OFF-ON transition must start around 0.5, end at 1.
            
            nber_samples_fullyON=length(sound_signal_ON)-2*length([y_transition1 y_transition2]); %calculate the length of the ON phase that does have transition in it
            y_fullyON=ones(1,nber_samples_fullyON);

            signal_burst=[y_transition1 y_transition2 y_fullyON y_transition2(end:-1:1) y_transition1(end:-1:1)]; %concatenate the components of ON phase.

        end
        sound_signal_ON=signal_burst.*sound_signal_ON; %apply the sound signal to the ON part of the cycle.
    end
    
    sound_signal_masked = zeros(1,nber_samples_total); %initialize sound vector for this trial
    sound_signal_inds = contiguous(pulse_train_mask_sound); %gives you the start and end indices of periods of 0s and 1s
    sound_signal_inds = sound_signal_inds{2,2}(:,1); %get all the start indices of periods of 1s
    for j = 1:length(sound_signal_inds)
        sound_signal_masked(sound_signal_inds(j):sound_signal_inds(j)+length(sound_signal_ON)-1) = sound_signal_ON; %incorporate the sound signal for each ON period
    end
    
    if length(sound_signal_masked) > nber_samples_total %if went over the actual planned length of stim on period, correct it
        sound_signal_masked = sound_signal_masked(1:nber_samples_total);
    end
    
    signal=[LED_signal_masked;sound_signal_masked]';
        
end

%
% pulse_train_mask=CREATE_SIGNAL_VECTOR(nber_samples_ON,nber_samples_cycle,nber_samples_total,flicker_random)
%
% Creates a vector of 1s and 0s corresponding to samples when signal
% should be ON (1) or OFF (0), for a given trial.
%
% Inputs:
%
% nber_samples_ON: the number of samples that are ON within a single cycle.
%
% nber_samples_cycle: the number of samples per cycle.
%
% nber_samples_total: total number of samples in a given trial.
%
% flicker_random: whether this is a random flicker trial (1) or not (0).
%
%
% Output:
%
% pulse_train_mask: the vector of 1s and 0s.
%

function pulse_train_mask=create_signal_vector(nber_samples_ON,nber_samples_cycle,nber_samples_total,flicker_random)

    pulse_train_mask=zeros(1,nber_samples_total); %initialize the vector of samples for the trial duration
    train_mask_total_length=0; %to keep track of length of vector in the loop below
    while train_mask_total_length<nber_samples_total %this loop advances cycle by cycle, as long as we have not completed the whole trial duration
        %first, calculate the number of samples that are going to be OFF for this given cycle:
        if flicker_random %if this is a random flicker trial; in this case we want the ON phase of cycle to be kept constant, and the OFF phase to vary in duration between 0 and 2x the OFF phase duration
            randval=rand; %pick random value between 0 and 1.
            temp=2*(nber_samples_cycle-nber_samples_ON); %the maximum length of the OFF part of the cycle should be 2x the duration of the OFF cycle if this were not random flicker
            nber_samples_OFF=round(temp*randval); %randomly pick an OFF duration for this trial, between 0 and max length calculated above
        else %if this is not a random flicker trial
            nber_samples_OFF=nber_samples_cycle-nber_samples_ON;
        end
        
        %then, assign 1s and 0s for this given cycle:
        pulse_train_mask(train_mask_total_length+1:train_mask_total_length+nber_samples_ON)=1; %label the samples that should be ON as 1
        train_mask_total_length=train_mask_total_length+nber_samples_ON+nber_samples_OFF; %increment by 1 cycle
    end
    
    if length(pulse_train_mask) > nber_samples_total %if went over the actual planned length of the trial, correct it by removing whatever's extra
        pulse_train_mask = pulse_train_mask(1:nber_samples_total);
    end
    
end

