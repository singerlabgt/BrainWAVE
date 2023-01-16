

function display_instructions(window,fontSize,instructions)
    Screen('TextSize', window, fontSize);%use a big font size
    Screen('TextStyle', window,0);%normal
    DrawFormattedText(window, instructions, 'center', 'center',  [0, 0, 0]);
    Screen('Flip', window);
    KbStrokeWait;
end