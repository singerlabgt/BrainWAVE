

function exitSubApp(app)
    quitAnswer = uiconfirm(app.MainWindow,'Are you sure you want to quit?','Confirm close','Options',{'Yes','No'}); %ask user if sure they want to quit
    if strcmp(quitAnswer,'Yes') %if user answer was 'Yes', do the following:
        call_to_NIDAQ(app.CallingApp,'end'); %indicate in recording that we finished running this sub-app
        changeMainAppState(app.CallingApp,1);
        fprintf(app.CallingApp.FileID,'\n%s\t%s',char(strjoin(string(clock),'-')),'Exiting from sub-app');
        figure(app.CallingApp.MainWindow); %select main window again
        delete(app) %WAY TO CLEANLY STOP ALL PROCESSES AND EXIT APP?
    end
end