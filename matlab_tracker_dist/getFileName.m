%
% fname = getFileName(index,fmt,stub,ext)
%
% Construct formated file name.
%
% inputs:   index      index of image
%           fmt        numbering format in file name (integer giving the
%                      number of fixed digit positions or 'free' for
%                      floating length numbering)
%           stub       file name stub
%           ext        the file extension (without dot)
%
% outputs:  fname      the formated file name as a string
%
% Ivo Sbalzarini, July 29, 2003
%

function fname = getFileName(index,fmt,stub,ext)
    if length(ext) > 0,
	ext = ['.', ext];
    end;
    if fmt=='free',
	if index < 10,
	    fname = sprintf('%s%1.1d%s',stub,index,ext);
        elseif index < 100,
	    fname = sprintf('%s%2.2d%s',stub,index,ext);
	elseif index < 1000,
	    fname = sprintf('%s%3.3d%s',stub,index,ext);
	elseif index < 10000,
	    fname = sprintf('%s%4.4d%s',stub,index,ext);
	elseif index < 100000,
	    fname = sprintf('%s%5.5d%s',stub,index,ext);
	else
	    fname = sprintf('%s%6.6d%s',stub,index,ext);
        end;
    else
	fname = sprintf(strcat('%s%',sprintf('%d',fmt),'.',sprintf('%d',fmt),'d%s'),stub,index,ext);
    end;
    return;
% end;   function getFileName

