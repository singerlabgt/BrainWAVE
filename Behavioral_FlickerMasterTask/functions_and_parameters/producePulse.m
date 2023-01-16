

function signal=producePulse(pulse_duration,sound_frequency,sample_rate)
    
    LED_signal=5; %value of LED signal ON
    sound_multiplication_factor=0.01; %this indicates by what factor user wants to multiply sound signal values- LEPY amplifier needs 0.01 to allow use of full range of volume knob
    sound_signal=sound_multiplication_factor.*generate_sound(sound_frequency,sample_rate); % 1s of sound_signal at appropriate range; the generate_1s_sound function provides a max value of 1

    nber_samples_ON=round(pulse_duration*sample_rate);
    nber_samples_total=sample_rate;
    
    signal=zeros(nber_samples_total,2);
    signal(1:nber_samples_ON,:)=[repmat(LED_signal,nber_samples_ON,1) sound_signal(1:nber_samples_ON)'];
    
end