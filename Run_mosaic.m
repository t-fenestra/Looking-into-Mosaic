filestub='/Users/pichugina/Work/Data_Analysis/Beads_data_processing/Beads_chamber_control_500nm_red/Front_Up_KB_beads_500nm_442018-Image Export-04/renamed/frame'
init=1;
final=50;
ext='.tif';
tracker(filestub,ext,init,final)

%%
filename=sprintf('%s%d%s',filestub,50,ext);
A=imread(filename);
imtool(A,[])