sound_click_freq=input('Specify Number of Sound Clicks Per Second: ');
LED_blink_freq=input('Specify Number of LED Blinks Per Second: ');
%stimuli_duty_cycle_sound=input('Specify Duty Cycle For Sound Stimulus (ex. 50 means 50%): ');
click_on_duration_sound = input('Specify Sound Click Duration (ex. 1 means 1 ms): ');
%stimuli_duty_cycle_LED=input('Specify Duty Cycle For LED Stimulus (ex. 50 means 50%): ');
click_on_duration_LED = input('Specify LED Blink Duration (ex. 1 means 1 ms): ');
sound_freq=input('Specify Sound Frequency in Hertz (Note: For White Noise, Type -1): ');
stimuli_phase_shift=input('Specify Stimuli Phase Shift in Degrees (ex. 180 means 180 degrees = half a period out of phase): ');
stimuli_duration=input('Specify Stimuli Duration in Seconds: ');

sample_rate = 1000000;

Ts=1/sample_rate:1/sample_rate:stimuli_duration;

if sound_freq > -1
    rfreq=2*pi*sound_freq;                      %Convert sound frequency to radian frequency
    
    sound_signal= 10*cos(rfreq*Ts);                       %Calculate the cosine for the entire sound duration; 10V is the max analog output
else
    % white noise desired
    
    % generate Normalized Gaussian Distributed White Noise 
    sound_signal_raw = randn(1,length(Ts));    
    
    % human hearing range from 20Hz to 20kHz.. build bandpass filter from
    % 10Hz to 40kHz
    
    % design 10001-point bandpass filter
    N = 40*sample_rate; % total number of points = N+1

    fLow=10; % low cut-off frequency
    fHigh=40e3; % high cut-off frequency
    
    % design filter with Kaiser window with beta = 6
    filter_kaiser = fir1(N, [fLow/(0.5*sample_rate) fHigh/(0.5*sample_rate)], kaiser(N+1, 6));
    
    % apply filter (use kaiser windowed filter)
    sound_signal_raw_filt = conv(sound_signal_raw, filter_kaiser, 'same');
    %sound_signal = 10*sound_signal_raw_filt/max(sound_signal_raw_filt);
    sound_signal = sound_signal_raw_filt;
end

LED_signal = 5; % LED signal will drive the TTL-responsive (5V) FET connected to the power source

period_pulse_sound = 1/sound_click_freq; % in ms
stimuli_duty_cycle_sound = click_on_duration_sound*1e-3/period_pulse_sound;  
pulse_width_sound = stimuli_duty_cycle_sound*period_pulse_sound; % pulse width

period_pulse_LED = 1/LED_blink_freq; % in ms
stimuli_duty_cycle_LED = click_on_duration_LED*1e-3/period_pulse_LED;  
pulse_width_LED = stimuli_duty_cycle_LED*period_pulse_LED; % pulse width

% % % pulse train mask for sound 
% % D_1 = pulse_width_sound/2:1/sound_click_freq:max(Ts); % 50Hz repetition freq; note: we are starting D at width/2 instead of 0 to shift the pulse train to the right by width/2 and thus start the train at 0
% % pulse_train_mask = pulstran(Ts, D_1, 'rectpuls', pulse_width_sound); 
% % 
% % % pulse train mask for LED
% % D_2 = (pulse_width_LED/2 + period_pulse_LED*stimuli_phase_shift/360):1/LED_blink_freq:max(Ts); % 50Hz repetition freq
% % pulse_train_mask_2 = pulstran(Ts, D_2, 'rectpuls', pulse_width_LED);
% % 
% % % mask the sound and LED signals with the pulse train mask
% % sound_signal_masked = sound_signal.*pulse_train_mask;
% % LED_signal_masked = LED_signal.*pulse_train_mask_2;

if sound_click_freq ~= 0    
    pulse_train_mask = zeros(1, length(Ts));        

    stimulus_on_length = round(pulse_width_sound*sample_rate);
    
    random_clicks = input(sprintf('Random #s of Sound Clicks/Sec That Average To %d Clicks/Sec? (1 for Yes, 0 for No): ', sound_click_freq));

    display('Audio Source Vector Is Being Generated..')
    
    if random_clicks == 1            % for 'random' stimulus
        
        % off length should have a mean of (period_pulse - pulse_width)
        % using uniform distribution, this can be achieved by varying
        % the range of random values from 0 to (period_pulse -
        % pulse_width)*2
        stimulus_off_length = round(2*sample_rate*(period_pulse_sound - pulse_width_sound)*rand);
    else
        stimulus_off_length = round(sample_rate*(period_pulse_sound - pulse_width_sound));
    end    

    pulse_train_mask_total_length = 0;
    while 1
        if (length(Ts) - pulse_train_mask_total_length) < (stimulus_on_length+stimulus_off_length)
            if length(Ts) == pulse_train_mask_total_length
                % do nothing here                        
            elseif (length(Ts) - pulse_train_mask_total_length) <= stimulus_on_length
                pulse_train_mask(pulse_train_mask_total_length+1:end) = 1;                        
            else
                pulse_train_mask(pulse_train_mask_total_length+1:pulse_train_mask_total_length+stimulus_on_length) = 1;
                pulse_train_mask(pulse_train_mask_total_length+stimulus_on_length+1:end) = 0;                        
            end

            break;
        end

        % add duty_cycle worth of stimulus to each pulse train
        pulse_train_mask(pulse_train_mask_total_length+1:pulse_train_mask_total_length+stimulus_on_length) = 1;
        pulse_train_mask(pulse_train_mask_total_length+stimulus_on_length+1:pulse_train_mask_total_length+stimulus_on_length+stimulus_off_length) = 0;

        pulse_train_mask_total_length = pulse_train_mask_total_length+stimulus_on_length+stimulus_off_length;
    end
    
    % mask the sound signal with the pulse train mask
    if sound_freq > -1
        sound_signal_masked = sound_signal.*pulse_train_mask;    
    else
        sound_signal_int = sound_signal.*pulse_train_mask;
        sound_signal_masked = 10*sound_signal_int/max(sound_signal_int);
    end
else
    display('Audio Source Vector Is Being Generated..')

    % mask the sound signal with the pulse train mask
    if sound_freq > -1
        sound_signal_masked = sound_signal;    
    else
        sound_signal_int = sound_signal;
        sound_signal_masked = 10*sound_signal_int/max(sound_signal_int);
    end
end


if LED_blink_freq ~= 0    
    pulse_train_mask_2 = zeros(1, length(Ts));        

    stimulus_on_length_2 = round(pulse_width_LED*sample_rate);
    
    random_clicks = input(sprintf('Random #s of LED Blinks/Sec That Average To %d Blinks/Sec? (1 for Yes, 0 for No): ', LED_blink_freq));

    display('LED Source Vector Is Being Generated..')
    
    if random_clicks == 1            % for 'random' stimulus
        
        % off length should have a mean of (period_pulse - pulse_width)
        % using uniform distribution, this can be achieved by varying
        % the range of random values from 0 to (period_pulse -
        % pulse_width)*2
        stimulus_off_length_2 = round(2*sample_rate*(period_pulse_LED - pulse_width_LED)*rand);
    else
        stimulus_off_length_2 = round(sample_rate*(period_pulse_LED - pulse_width_LED));
    end    

    pulse_train_mask_2_total_length = 0;
    while 1
        if (length(Ts) - pulse_train_mask_2_total_length) < (stimulus_on_length_2+stimulus_off_length_2)
            if length(Ts) == pulse_train_mask_2_total_length
                % do nothing here                        
            elseif (length(Ts) - pulse_train_mask_2_total_length) <= stimulus_on_length_2
                pulse_train_mask_2(pulse_train_mask_2_total_length+1:end) = 1;                        
            else
                pulse_train_mask_2(pulse_train_mask_2_total_length+1:pulse_train_mask_2_total_length+stimulus_on_length_2) = 1;
                pulse_train_mask_2(pulse_train_mask_2_total_length+stimulus_on_length_2+1:end) = 0;                        
            end

            break;
        end

        % add duty_cycle worth of stimulus to each pulse train
        pulse_train_mask_2(pulse_train_mask_2_total_length+1:pulse_train_mask_2_total_length+stimulus_on_length_2) = 1;
        pulse_train_mask_2(pulse_train_mask_2_total_length+stimulus_on_length_2+1:pulse_train_mask_2_total_length+stimulus_on_length_2+stimulus_off_length_2) = 0;

        pulse_train_mask_2_total_length = pulse_train_mask_2_total_length+stimulus_on_length_2+stimulus_off_length_2;
    end
    
    % add phase shift
    phase_shift_amount = round(sample_rate*period_pulse_LED*stimuli_phase_shift/360);
    pulse_train_mask_2 = circshift(pulse_train_mask_2, [0 phase_shift_amount]);
else
    display('LED Source Vector Is Being Generated..')
    
    pulse_train_mask_2 = ones(1, length(Ts));
end

% mask the sound signal with the pulse train mask
LED_signal_masked = LED_signal*pulse_train_mask_2;

filename = input('Specify Filename To Save Generated Stimuli Source Vectors In Single Quatation Marks: ');
save(filename,'sound_signal_masked', 'LED_signal_masked', 'sample_rate');