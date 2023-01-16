% CHECK IF CORRECT (ADDED VARARGIN TO BE ABLE TO PRODUCE 10S OF SOUND)
%
% POTENTIAL ISSUES FOR PRODUCING WHITE NOISE, BUT NOT USING WHITE NOISE FOR
% NOW.
%
% sound_signal = GENERATE_1S_SOUND(sound_frequency,sample_rate)
%
% Generates data for 1s of sound, of given sound_frequency and at a given
% sample_rate.
% 
%
% Inputs:
%
% sound_frequency: if 1 number, will create 1s of sound of that given
% tone; if a vector of 2 numbers, will create 1s of white noise sampled
% from frequencies in between those 2 numbers.
% Ex: sound_frequency = 7000 means 1s of 7000Hz tone will be made.
%     sound_frequency = [500 10000] means 1s of white noise created from
%     frequencies between 500Hz and 10000Hz will be made.
% IMPORTANT: in case of white noise, the computer will check whether such
% 1s signal has already been created in functions_and_parameters/ folder. This
% ensures that we only use 1 version of 1s of white noise between 2
% given frequencies for all of our experiments. If the computer finds such
% file, it will use that file; if it does not find such file, it will
% create the 1s of white noise and save it under an appropriate name in
% that folder.
%
% sample_rate: the sample rate of the sound signal to be made- this is
% important when actually playing the sound, for example through the NIDAQ
% (ex: sample_rate = 250000).
%
%
% Output:
%
% sound_signal: the sound signal generated based on the inputs.
%
%
% Log:
% First log by LB on 2020/08/10.

function sound_signal=generate_sound(sound_frequency,sample_rate,varargin)
    
    if isempty(varargin)
        duration=1; %in seconds
    else
        duration=varargin{1};
    end

    if length(sound_frequency)==2 % means we want white noise, generated between those 2 frequencies; NEED TO CHECK THIS PART OF IF/ELSE STATEMENT; IS WAY WE PRODUCE WHITE NOISE CORRECT HERE?
        
        currentPath=mfilename('fullpath');
        currentPath=currentPath(1:end-length(mfilename));
        temp=dir([currentPath,'1s_whiteNoise_',num2str(sound_frequency(1)),'-',num2str(sound_frequency(2)),'Hz_','sampleRate',num2str(sample_rate),'Hz_','*.mat']);
        if isempty(temp) %means we have not created such white noise yet; need to create it and save it
            
            lf = sound_frequency(1);   % lowest frequency
            hf = sound_frequency(2);   % highest frequency
            
            % set general variables
            d = 0.00625;     % duration (time)
            n = floor(sample_rate * d);  % number of samples %CORRECT TO DO FLOOR?
            
            % set variables for filter
            lp = lf * d; % ls point in frequency domain
            hp = hf * d; % hf point in frequency domain
            
            % design filter
            filter_variable = zeros(1, n);           % initializaiton by 0
            filter_variable(1, lp : hp) = 1;         % filter design in real number
            filter_variable(1, n - hp : n - lp) = 1; % filter design in imaginary numbers
            
            % make noise
            rand('state',sum(100 * clock));  % initialize random seed %CAREFUL- WE USE RNG('SHUFFLE') IN PRODUCEEEXPERIMENTSIGNALS- HOW DOES THAT PLAY INTO THIS?
            noise = randn(1, n);             % Gausian noise
            noise = noise / max(abs(noise)); % -1 to 1 normalization
            
            % do filter
            s = fft(noise);                  % FFT
            s = s .* filter_variable;        % filtering
            s = ifft(s);                     % inverse FFT
            s = real(s);
            s=s/max(abs(s)); %want to have max value be 1
            
            s=repmat(s,1,1/d);
            
            save(strcat(currentPath,'1s_whiteNoise_',num2str(sound_frequency(1)),'-',num2str(sound_frequency(2)),'Hz_','sampleRate',num2str(sample_rate),'Hz_',strjoin(string(round(clock)),'-'),'.mat'),'s');
            sound_signal=s;
            
        else
            load([currentPath,temp.name],'s');
            sound_signal=s;
        end
        
    elseif length(sound_frequency)==1 %means we want a given tone rather than white noise
        Ts=0:1/sample_rate:duration;
        Ts(end)=[];
        rfreq=2*pi*sound_frequency;
        sound_signal = cos(rfreq*Ts); %max value of sound will be 1
    end
end



