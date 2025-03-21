
% 1. Open TIFF containing a single peak 
% 2. Threshold the image
% 3. Computue total counts in the spot around a single peak
% 4. Report Peak value (need to flag Saturated Pixels = 255_
%
function TIFF_Analysis_Counts_from_Single_Peak()
%% get data
    close all;
    clear;
    dirs.f  = '/Users/brentfisher/Documents/MATLAB/UVQ';
    start_path = '/Users/brentfisher/Documents/MATLAB/UVQ/matDat/';
    filepath = '/Users/brentfisher/Documents/MATLAB/UVQ/matDat/';
    
    %Select all files within SubFolders
    toppath = uigetdir(start_path);
    cd(toppath);
    A = dir('**/*.tiff');  %Search within sub folders
    Nf = length(A)
    for kf=1:Nf
        filenames{kf} = A(kf).name;
        paths{kf} = [A(kf).folder,'/'];
    end
    
    %Select by Hand
    if toppath==0
        [filenames,path] = uigetfile('*.tiff','Multiselect','on');
         Nf = length(filenames);
         if isstr(filenames)
             filename = filenames; clear filenames;
             filenames{1} = filename;
             Nf=1;
         end
    end
    
     
 % Loop Over Files
    for kf=1:Nf
        I0 = imread([paths{kf},filenames{kf}]);
        if size(I0,3)>1
            I0 = rgb2gray(I0(:,:,1:3));
        end
        % imshow(I0);
        
        %-------- TOTAL COUNTS ------------
        TotalImageCounts(kf,1) = sum(I0(:));
        BG_sample_region = I0(1:20,1:20);
        BG_imagecounts_estimate(kf,1)   = size(I0,1)*size(I0,2)* mean(mean(BG_sample_region));
        BG_stdev_estimate(kf,1)   =  std(double(BG_sample_region(:)));
        
        Nrows =  size(I0,1);  Ncols = size(I0,2);
        %-------- THRESHOLD IMAGE & CALCULATE COUNTS above BG------------
        %find Peak (max value)
        [maxval(kf),imax] = max(I0(:));
        [rmax,cmax] = ind2sub(size(I0),imax);
        
        %ROI IMAGE -- around the peak
                I0roi = I0(rmax-200:rmax+200,cmax-200:cmax+200);
        I0roi = I0;
        

        scale=1;  %if(kf>2) scale = 1.5;   else scale=0.9; end;
        [level,EM] = graythresh(I0roi);
        I1 = imbinarize(I0roi,level*scale);
        
        %         threshlevels = multithresh(I0roi,4);
        %         I1 = imquantize(I0,threshlevels);
        %         figure; imshow(I1);
        
        isel = find(I1(:)==1);
        SumCounts(kf,1) = sum(I0roi(isel));
        NumPix(kf,1) = length(isel);
        
     
        %SHOW FIGURE
        [rsel,csel] = ind2sub(size(I0roi),isel);
        
%         if kf==1 figure; subplot(1,Nf,1)
%         else subplot(1,Nf,kf)
%         end
        warning off
        
        hf1 = figure;
        
       	imshow(I0roi); hold all; plot(csel,rsel,'.','Color','r');
        title(replace(filenames{kf},'_',' '));
        saveas(hf1,[toppath,'/',replace(filenames{kf},'.tiff','selectedPoints.jpg')], 'jpg');
        %PRINT RESULT
        X = sprintf('%s , %d , %d, %d, %d, %d, %d, %d, %d',...
            filenames{kf},SumCounts(kf,1),NumPix(kf,1),maxval(kf),...
            TotalImageCounts(kf,1),BG_imagecounts_estimate(kf,1), BG_stdev_estimate(kf,1), Nrows, Ncols);
        disp(X);
        
        warning on
    end
    
    disp(maxval)
    
    
    
    
end

