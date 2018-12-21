%======================================================================% 
% Mosaik setup 

%-------------------------%
% Images folder
filestub='/Users/pichugina/Work/Data_Analysis/Beads_data_processing/Beads_chamber_control_500nm_red/Front_Up_KB_beads_500nm_442018-Image Export-04/renamed/frame';
%images type
ext='.tif';
%start frame
init=1;
%end frame
final=20;
% File prefix for results writing
Prefix_file_writing='Front_Up_KB_beads_500nm_';

%----------------------------%
% Images properties
%pixel size mkm
dx=0.107;  
%time frame s
dt=0.001;

%----------------------------%
% Mosaik parameters
w =3;          % radius of neighborhood: > particle radius, 
               % < interparticle distance
pth =0.5;      % upper intensity percentile for particles
cutoff = 0.5;  % probability cutoff for non-particle
               % discrimination
L = 10;        % maximum displacement between frames
trajLen=5;      % minimum trajectory length 
viz=0;         % visualization mode

%======================================================================% 
%% Step 1: Image preparation
% Image restoration Boxfilter with Gaussianfilter
BoxFilter=7;
GaussFilter_lambda=3;
images=imagespreparation(filestub,ext,init,final,viz,BoxFilter,GaussFilter_lambda);
NumberFiles=final-init+1;

%images=images(216:512,216:512,:);
%viz_image_stack(NumberFiles,images);

%% Step2: Peaks segmentation (define peaks on image)
peaks=tracker(images,w,pth,cutoff,L);


%% Step2: Peacks linking into trajectories across frames
% descard trajectory less than trajLen 

trajectories =ll2matrix(peaks,trajLen);
file_name=strcat(Prefix_file_writing,'Trajectories.txt');
%write2file_trajectory(file_name,trajectories);

%% Analyze trajectories
% calculate diffusion coefficient and MSS
alysis_matrix = moments(trajectories,dx,dt);
file_name=strcat(Prefix_file_writing,'Analysis.txt');
write2file_analysis(file_name,alysis_matrix);

%% Visualize trajectories
viz_trajectories(NumberFiles,images,trajectories);
