    clear all;
clc;
addpath(genpath('Lib'))
config_file_path = 'config_data.csv';
[~,configFileName,~] = fileparts(config_file_path);

CSVData = importdata(config_file_path);
k = strfind(CSVData{1},'input_folder');
input_folder = extractBetween(CSVData{1},k+length('input_folder')+1,length(CSVData{1}));
input_folder = input_folder{1};
k = strfind(CSVData{2},'output_folder');
output_folder = extractBetween(CSVData{2},k+length('output_folder')+1,length(CSVData{2}));
output_folder = output_folder{1};
fprintf('The code is reading from data folder %s\n',input_folder);
fprintf('The code will write its result to folder %s\n',output_folder);


middleString = [];
files =[];

for i = 1 : 100
    files = [files;rdir(fullfile(input_folder,middleString,'*.txt'))];
    middleString = fullfile(middleString,'*');
    
end

unsuccessful_examples_counter = 0;
for indexFile = 1:length(files)
    fileName = files(indexFile).name;

    try
        [folderPath,folderName,ext]=fileparts(fileName);
        if strcmp(input_folder,folderPath) == 1
            folderPath = [];
        else
            k = strfind(folderPath,input_folder);

            folderPath = extractBetween(folderPath,k+length(input_folder)+1,length(folderPath));
            folderPath = folderPath{1};
        end
        
        
        WindowSize = 200;
        [Boundaries,nucleiImage,occupancy_image,nucleiOccupancyIndexed]=compute_nuclei_CNN_all_at_once(fileName,WindowSize);        
        outputFolderScan = fullfile(output_folder,folderPath,folderName);
        mkdir(outputFolderScan);
        outputNucleiPath = fullfile(outputFolderScan,'nuclei_multiscale.mat');
        parsave(outputNucleiPath,Boundaries,nucleiImage,occupancy_image,nucleiOccupancyIndexed);
    catch XE
        fprintf('\n--------------\n--------------\n--------------\n');        
        fprintf('example %s got an excepion\n',fileName);
        fprintf('\n--------------\n--------------\n--------------\n');
        unsuccessful_examples_counter = unsuccessful_examples_counter + 1;
        unsuccessful_examples{unsuccessful_examples_counter} = fileName;        
    end
    
end
mkdir('log');
fileID = fopen(fullfile('log',strcat(configFileName,'.txt')),'w');
if unsuccessful_examples_counter == 0   
    fprintf(fileID,'Yay, all files were successfully segmented!\n');
else
    for indexFile = 1 : length(unsuccessful_examples)
        s = unsuccessful_examples{indexFile};
        fprintf(fileID,'%s\n',s);
    end
end


fclose(fileID);