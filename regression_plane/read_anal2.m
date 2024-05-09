function data = read_anal2(fpath)
%READ_ANAL2 Summary of this function goes here
%   Detailed explanation goes here
fid = fopen(fpath);
data = textscan(fid, '%f %f %f');
fclose(fid);
end

