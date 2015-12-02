%function read_attributes()
% read attributes from files


%% read attributes
% locations
config;
if exist(clothing_attributes_file, 'file') && canSkip
    disp('Clothing attribute file already exists!!');
    load(clothing_attributes_file);
else
    N = 243637;

    clothing_attributes = cell(1,22);

    for attrID = 1:22
        attrFile = sprintf('%s/%d.txt', attrDir, attrID);
        %attrs = textread(attrFile, '%s\n');

        fd = fopen(attrFile, 'r', 'n', 'GBK');
        attrs = cell(1, N);
        ind = 1;
        while ~feof(fd)
            l = fgetl(fd);
            attrs{ind} = l;
            ind = ind+1;
        end
        fclose(fd);

        [attrNames, m, n] = unique(attrs, 'stable');
        attr = struct;
        attr.names = attrNames;
        attr.label = n;

        clothing_attributes{attrID} = attr;
    end

    save(clothing_attributes_file, 'clothing_attributes', '-v7.3');
end


%% analyze attributes
for i=1:length(clothing_attributes)
    ca = clothing_attributes{i};
    nvalue = length(ca.names);
    cahist = histc(ca.label, 1:nvalue);
    bar(cahist);
    %set(gca, 'XTickLabel', ca.names);
    ca.names
    nnotenough = sum(cahist<1000);
    fprintf('%d of %d attributes have not enough training samples\n',...
        nnotenough, nvalue);
end



%end
