disp('Merging image files into out.pdf');
fPath=[pwd,filesep,'tmp'];
fName=[fPath,filesep,'1.jpg'];
outFile=[fPath,filesep,'out.pdf'];

if exist(outFile,'file')
    delete(outFile);
end

if exist(fName,'file')
    system(['convert -quality 100 -density 300 ',fPath,filesep,'1.jpg -quality 100 -density 300 ',outFile]);
    disp(['Merged ',fName]);
else
    return;
end


for n=2:16
    
    fName=[fPath,filesep,int2str(n),'.jpg'];
    if exist(fName,'file')
        system(['convert -quality 100 -density 300 ',outFile,' ',fName,' -quality 100 -density 300 ',outFile]);
        disp(['Merged ',fName]);
    end
end