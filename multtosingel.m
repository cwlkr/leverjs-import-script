infolder = '/home/cewa/Desktop/2018-07-26_MCF10AmutInhib_H2B-miRFP_ERKKTR-Turq_FoxO-NeonGreen_40xAir_T5min_Stim15min-1ngmlEGF_6h-starving+CO2/TIFFs';
outfolder = strcat(infolder, '/lever');
pps = [0.3328,0.3328,1]
AddSQLiteToPath()

tifftohyperstack(infolder, outfolder,pps)


function tifftohyperstack(infolder,outfolder,pps)
path(path,'/home/cewa/leverUtilities/src/MATLAB/');
path(path,'/home/cewa/leverjs/matlab/');
path(path, '/home/cewa/leverjs/leverjs/');
%add utils to path

flist=dir(strcat(infolder, '/*.tif'));

if ~exist(outfolder)
    mkdir(outfolder)
end

datasets={};
    for ff=1:length(flist)
        fname = fullfile(flist(ff).folder,flist(ff).name);
        [cStart]=regexp(flist(ff).name,'_C\d+');
        % Name according to C* at the end.
        expName=flist(ff).name(1:(cStart-1));
        outname = strcat(expName,'.tif');
        if any(strcmp(datasets,expName))
            continue
        end
        % we remember this experiment in the datasets struct so that we
        % don't reimport for every individual c,t,z image
        im=[];
        if ~isempty(cStart)
            tifflist = dir(strcat(flist(ff).folder, '/', expName,'*.tif'));
            for i=1:length(tifflist)
                imx = MicroscopeData.Original.ReadImages(tifflist(i).folder, tifflist(i).name);
                [cStr]=regexp(tifflist(i).name,'_C\d+','match');
                if isempty(cStr{1}(3:end))
                    c=1;
                else
                    c=str2double(cStr{1}(3:end));
                end
                im = cat(4,im,imx);
            end
        else
            [tiffstart]=regexp(flist(ff).name,'.tif+');
            expName=flist(ff).name(1:(tiffstart-1));
            im = MicroscopeData.Original.ReadImages(flist(ff).folder,flist(ff).name);
        end
        datasets=[datasets expName];
        imd=MicroscopeData.MakeMetadataFromImage(im);
        imd.PixelPhysicalSize= pps;
        imd.DatasetName=expName;
        if (size(imd.Dimensions,2)~=3)
            imd.Dimensions=[imd.Dimensions 1];
        end
    
        MicroscopeData.WriterH5(im,'imageData',imd,'path',outfolder);
        %MicroscopeData.Original.BioFormats.bfsave(im,strcat(outfolder, '/', outname))
    end
    Import.leverImport('',outfolder)
end
