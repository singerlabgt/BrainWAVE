

function [rt,response]=in_out_response(Window,key,startrt,image_duration,in_sound,out_sound,sample_rate)
    % while loop to show stimulus for STUDY_IM_DURATION seconds
    rt =0;
    while (GetSecs - startrt) <= image_duration
      % poll for a resp
      [ ~, ~, keyCode ] = KbCheck;
      if (keyCode(key.in) && rt==0)
        rt = GetSecs - startrt;
        response='in';
        sound(in_sound, sample_rate);
        
      elseif (keyCode(key.out) && rt==0)
        rt = GetSecs - startrt;
        response='out';
        sound(out_sound, sample_rate);
        
      elseif(keyCode(key.quit))
        quitTask(Window);
      end
      WaitSecs(0.001);%slow down the while loop a bit
    end
    if rt==0
        response='n/a';
        rt=-1;
    end
end