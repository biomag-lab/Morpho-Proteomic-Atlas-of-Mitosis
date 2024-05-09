function newName = convertFileNames_BIAS2Operetta(BIASname)

if size(BIASname,1) == 1
    BIASname = {BIASname};
end
newName = cell(size(BIASname,1),1);

for i = 1:size(BIASname,1)
    splitName = strsplit(BIASname{i},{'p','_w','_t','_m','_c','_z','_l','_o'});
    % plate = sprintf('%02d',str2double(splitName{2}));
    row = sprintf('%02d',strfind('A':'Z',splitName{3}(1)));
    col = sprintf('%02d',str2double(splitName{3}(2)));
    time = splitName{4};
    field = sprintf('%02d',str2double(splitName{5}));
    channel = splitName{6};
    z = sprintf('%02d',str2double(splitName{7}));
    % l = splitName{8};
    % o = splitName{9};
    
    newName{i,1} = ['r',row,'c',col,'f',field,'p',z,'-ch',channel,'sk',time,'fk1fl1'];
    
end