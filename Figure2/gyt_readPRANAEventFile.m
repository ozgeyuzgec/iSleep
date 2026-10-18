function [X,Header] = gyt_readPRANAEventFile(file,type)

[~,fname,ext] = fileparts(file);

fid = fopen(file,'r');

pretest = textscan(fid,'%s%s%s%s%s%s','Delimiter','\t');

fclose(fid);


if type==1 %~isempty(strfind(fname,'artefact')) || ~isempty(strfind(fname,'arousal'))
    fid = fopen(file,'r');

    Header = fgets(fid);
    X = textscan(fid,'%f%f%s%f%s%s','Delimiter','\t');

    fclose(fid);
elseif type==0
    fid = fopen(file,'r');

    Header = cell(5,1);
    for iL=1:5
        Header{iL} = fgets(fid);
    end
    tabInd = find(Header{2}==sprintf('\t'));
    X = textscan(fid,['%s',repmat('%f',[1,numel(tabInd)])],'Delimiter','\t');

    fclose(fid);
end


