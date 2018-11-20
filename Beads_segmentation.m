clear       %no variables
close all   %no figures
clc         %empty command window
%result_folder='/Users/pichugina/Work/Data_Analysis/Step_by_Step_Image_Processing/'
%Intensity_slice=1024;

%% read files in stack
myFolder='/Users/pichugina/Work/Data_Analysis/Beads_data_processing/Beads_chamber_control_500nm_red/Front_Up_KB_beads_500nm_442018-Image Export-04/'
filePattern = fullfile(myFolder, '*.tif');
TifFiles = dir(filePattern);
files=natsortfiles({TifFiles.name});


NumberFiles=10; %numel(files);
Image_stack=zeros(2048,2048,NumberFiles);
for k=1:NumberFiles
    fullFileName = fullfile(myFolder,files{k});  
    Image_stack(:,:,k)=imread(fullFileName);
    %plot(Image_stack(:,Intensity_slice,k));
end

[n,m]=size(Image_stack(:,:,k))
ImSequence(NumberFiles,Image_stack)

%% Gaussian smoothing and background correction
Image_stack_gauss=imgaussfilt(Image_stack,3,'Padding','symmetric');
Background=imgaussfilt(Image_stack_gauss,50,'Padding','symmetric');%
Image_corrected=Image_stack_gauss./Background;
ImSequence(NumberFiles,Image_corrected)

%%

%% Image sharpening with Laplace
%LOG-kernel
hsize=8;
sigma=10;
LOG=fspecial('log',hsize,sigma);
LOG_Image = imfilter(Image_corrected, -LOG,'symmetric');


Max_LOG_Image =max(LOG_Image(:));
LOG_Image =LOG_Image/Max_LOG_Image;
counts=imhist(LOG_Image,64);
highThresh = find(cumsum(counts)>0.1*m*n*NumberFiles,1,'first') / 64;
LOG_Image_BW=imbinarize(LOG_Image,highThresh);
LOG_Image_BW=bwareaopen(LOG_Image_BW,25); % delete region with size less than area
Image_stack_LOG=LOG_Image_BW;
ImSequence(NumberFiles,Image_stack_LOG)

%% 
%% Connected component across 3 consequtive frames
% % layer1
% Stack3=uint8(Image_stack_LOG);
% 
% hold on;
% for sl=1:NumberFiles
%     Stack3(:,:,sl)=Stack3(:,:,sl)*sl;
%     [row,col,v]=find(Stack3(:,:,sl));
%     scatter3(row,col,v,'s');
%     
% end;
% hold off;
% [row,col,v]=find(Stack3);
% scatter3(row,col,v);
% 
% 
% %%
% 
CC3=bwconncomp(Image_stack_LOG)
s = [m,m,NumberFiles];
Selected=[];
hold on
for cc=1:CC3.NumObjects
    Ind=CC3.PixelIdxList{cc};
    [I,J,K] = ind2sub(s,Ind);
    deltaFrames=max(K)-min(K);
    if deltaFrames==0
       Selected=[Selected,cc];
    end
%     if (length(K)>2)
%     scatter3(I,J,K,'s','filled');
%     end;
end;

Filtered=CC3.PixelIdxList{Selected};
FilteredStack=zeros(n,m,NumberFiles);
FilteredStack(ind2sub(s,Filtered))=1;
ImSequence(NumberFiles,FilteredStack)
% hold off
% view(40,35)
% 
% colormap(jet)
% box on
% axis tight
% camproj perspective
% camva(10)
% % campos([165 -20 65])
% % camtarget([100 40 -5])
% camlight left
% lighting gouraud
%L=labelmatrix(CC3);
% %RGB=label2rgb(L);
% N=CC3.NumObjects
% stats = regionprops3(CC3)
