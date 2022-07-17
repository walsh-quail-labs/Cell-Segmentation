uiwait(msgbox('Hello, welcome to cell segmentation toolbox, please select the input data folder for cell segmentation'));
input_folder = uigetdir();
uiwait(msgbox('Thank you, now please select the output folder for cell segmentation'));
output_folder = uigetdir();
fig = uifigure;
msg = 'Run the segmentation';
title = 'Run?';
selection = uiconfirm(fig,msg,title,...
           'Options',{'Run now','Save the config file','Do nothing!'},...
           'DefaultOption',2,'CancelOption',3);
close(fig)
if strcmp(selection,'Run now') || strcmp(selection,'Save the config file')
    uiwait(msgbox('Please select where you want to save your configuration file'));
    filter = {'*.csv'};
    [csvfile, csvpath] = uiputfile(filter);
    fileID = fopen(fullfile(csvpath,csvfile),'w');
    fprintf(fileID,'input_folder,%s\n',input_folder);
    fprintf(fileID,'output_folder,%s\n',output_folder);
    
end
if strcmp(selection,'Run now')
    config_file_path = fullfile(csvpath,csvfile);
    run_with_gui(config_file_path);
end
if strcmp(selection,'Do nothing!')
    uiwait(msgbox('You selected to do nothing'));
end

