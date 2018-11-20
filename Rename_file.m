myFolder='/Users/pichugina/Work/Data_Analysis/Beads_data_processing/Beads_chamber_control_500nm_red/Front_Up_KB_beads_500nm_442018-Image Export-04/'
Path='/Users/pichugina/Work/Data_Analysis/Beads_data_processing/Beads_chamber_control_500nm_red/Front_Up_KB_beads_500nm_442018-Image Export-04/renamed/'
filePattern = fullfile(myFolder, '*.tif');
TifFiles = dir(filePattern);
files=natsortfiles({TifFiles.name});


NumberFiles=numel(files);
%Image_stack=zeros(2048,2048,NumberFiles);
for k=1:NumberFiles
    fullFileName = fullfile(myFolder,files{k});
    temp= strsplit(fullFileName,'_')
    t=temp{19}
    NewFileName=fullfile(myFolder,sprintf('%s.tif',t))
    imwrite(imread(fullFileName),NewFileName)
end

%[n,m]=size(Image_stack(:,:,k))
%ImSequence(NumberFiles,Image_stack)