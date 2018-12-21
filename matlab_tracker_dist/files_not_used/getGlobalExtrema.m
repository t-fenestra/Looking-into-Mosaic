%
% [imin,imax] = getGlobalExtrema(instub,first,last,infmt,ext)
%
% determines the global intensity extrema in a series of images.
% For multichannel images (color) the extrema are taken over all
% channels.
%
% inputs:   instub     file stub for the input files
%           first      first file index to be read
%           last       last file index to be read
%           infmt      numbering format of input files (an integer giving
%                      the number of fixed digits or 'free' for floating length
%                      numbering)
%           ext        the file extension (without dot)
%
% outputs:  [l,u]      with l being the lowest intensity value found and u
%                      the highest
%
% Ivo Sbalzarini, February 10, 2004
%

function [imin,imax] = getGlobalExtrema(instub,first,last,infmt,ext)

    imax = 0;
    imin = Inf;
    disp('Scaning images for global extrema. Please wait...');
    for img=round(first):round(last),
	file = getFileName(img,infmt,instub,ext);
	a = double(imread(file));
	u = max(max(max(a)));
	l = min(min(min(a)));
	if u>imax, imax=u; end;
	if l<imin, imin=l; end;
    end;

return;
