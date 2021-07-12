function Counter_return = ls_analyseSpeckleFolders5(Main_expfolder, expfolder, xlCounter)
% ls_analyseSpeckleFolders5 Perform analysis on speckle folders
%
%  Counter_return = ls_analyseSpeckleFolders5(outputfolder_name, inputfolder_name, 0)
%
% (This version is same as ls_analysisSpeckleFolders4 except that Warren
% Shenkenfelder found a bug in the beam splitting ratio (should be 0.47 instead of 0.43).
%
% This is the corresponding normal skin analysis for ls_analysisSpeckleFolder5_normalSkin.m.
% This version skip folders with the strings "nor" or "Normal".
%
% Compute co- and cross-contrast for each the blue and red speckle images. 
% Also compute reduced contrast, DOLPavg and the moments (first_abs, 1st to
% 7th) of the DOLPmap from a set of 6 speckle images.
%
% This function recursively goes through all subfolders of the 2nd input
% parameters inputfolder_name and finds the one containing the 6 speckle 
% images (blackAligned, blackPerp, blueAligned, bluePerp, redAligned, and 
% redPerp); then this function computes the above specified variables for
% each speckle image and the set of 6 speckle images, after checking the
% quality of the images, adjusting for the black noise and the 53/47 
% beam splitter distrbituion. Finally, the results are saved in an Excel 
% file SpeckleAnalysisMaster.xls under the folder of the first input 
% parameter. For the blue or red laser speckle images cannot pass the 
% quality check, a set of INV will be outputed in the Excel file.
%
% The first two input parameters are character strings specifing the 
% full absolute path.
%
% The ouptput Excel file, speckleAnalysisMaster.xls, consists of 25 columns:
% - subfolder name,
% - blue values (contrast (c) for co- and cross-channels, reduced contrast 
%   (rc_blue), DOLPavg, 1st abs moment for DOLPmap, 1st to 7th moments for
%   DOLPmap)
% - red values (contrast (c) for co- and cross-channels, reduced contrast 
%   (rc_red), DOLPavg, 1st abs moment for DOLPmap, 1st to 7th moments for
%   DOLPmap)
% - For the sheet 'Random', the fields NBlue and NRed denote the random entry
%   selected.  2012 July 23
% - Sheet 'Median': this sheet may not be meaningful as median values are
%   selected independent from each field. So the values may not be related.
%   2012 July 23
%
% Tim Lee
% BC Cancer Agency
% Oct. 3, 2011
%
% 2011 Oct. 6: Add a new exclusion criteron.
% 2011 Nov. 5 - version 4: Replace imadd, imsubstract and isnan with -, +,
% and isfinite. See also ls_analyseMomentWorksheet.m.

% initialization the name of the speckle images
Black_Aligned = '';
Black_Perp = '';
Blue_Aligned = '';
Blue_Perp = '';
Red_Aligned = '';
Red_Perp = '';

speckleImagesAnalysed = 0;
% Main_expfolder = 'C:\Documents and Settings\Serena\Desktop\Luda';

if (xlCounter ==0)
    rslt = {'SubFolder', ...
            'blue_co_c','blue_x_c', 'blue_rc', 'blue_DOLPvag', ...
            'blue_DOLPm1stAbs', 'blue_DOLPm1', 'blue_DOLPm2', 'blue_DOLPm3', 'blue_DOLPm4', 'blue_DOLPm5', 'blue_DOLPm6', 'blue_DOLPm7', 'NaN_Counter' ...
            'red_co_c','red_x_c', 'red_rc', 'red_DOLPvag', ...
            'red_DOLPm1stAbs', 'red_DOLPm1', 'red_DOLPm2', 'red_DOLPm3', 'red_DOLPm4', 'red_DOLPm5', 'red_DOLPm6', 'red_DOLPm7', 'NaN_Counter'};
    xlswrite(fullfile(Main_expfolder, 'speckleAnalysisMaster.xls'), rslt, 'Combined', 'A1');
    xlCounter = xlCounter + 1;
end

d = dir(expfolder);
for i = 1: length(d)
    % disp(d(i));
    fname = d(i).name;
    if (strcmp(fname, '.') == 0 && strcmp(fname, '..') == 0 && strcmpi(fname, 'normal') == 0 && d(i).isdir == 1) % ignore the folder for normal skin
        % found a subfolder
        subfolder = fullfile(expfolder, fname);
        disp(['*** ' subfolder]);
        xlCounter = ls_analyseSpeckleFolders5(Main_expfolder, subfolder,xlCounter);
    else
        % found a plain file
        % determine whether it is a speckle image
        if ~isempty(strfind(fname, 'Black_Aligned.bmp'))
            Black_Aligned = fullfile(expfolder, fname);
        elseif ~isempty(strfind(fname, 'Black_Perp.bmp'))
            Black_Perp = fullfile(expfolder, fname);
        elseif ~isempty(strfind(fname, 'Blue_Aligned.bmp'))
            Blue_Aligned = fullfile(expfolder, fname);
        elseif ~isempty(strfind(fname, 'Blue_Perp.bmp'))
            Blue_Perp = fullfile(expfolder, fname);
        elseif ~isempty(strfind(fname, 'Red_Aligned.bmp'))
            Red_Aligned = fullfile(expfolder, fname);
        elseif ~isempty(strfind(fname, 'Red_Perp.bmp'))
            Red_Perp = fullfile(expfolder, fname);
        end

        % Removing the common part of the file's path name
        % expfolder2 = strrep(expfolder, 'C:\Documents and Settings\Serena\Desktop\Luda\', '');
        expfolder2 = strrep(expfolder, Main_expfolder, '');
        expfolder2 = strtrim(expfolder2);
        
        % Discard the .text and other non-bmp files
        if (speckleImagesAnalysed == 0 && (~isempty(Black_Aligned) && ~isempty(Black_Perp) && ~isempty(Blue_Aligned) && ...
            ~isempty(Blue_Perp) && ~isempty(Red_Aligned) && ~isempty(Red_Perp) && ...
            isempty(strfind(expfolder, 'nor')) && isempty(strfind(expfolder, 'Normal'))) && strfind(fname, '.bmp'))
   
            blue_co = double(imread (Blue_Aligned));
            blue_x = double(imread (Blue_Perp));
            red_co = double(imread (Red_Aligned));
            red_x = double(imread (Red_Perp));  
            black_co = double(imread (Black_Aligned));
            black_x = double(imread (Black_Perp));
                  
            % First, work on the blue laser speckle images
            % Checking the images intensity to see if they are within valid 
            % range or not
            % A new condition has been added - 2011 Oct. 6
            if ((20 <= mean2(blue_co) && mean2(blue_co) <=100) && ...
                (5  <= mean2(blue_x)&& mean2(blue_x)<=100)     && ...
                (mean2(black_co)<=2)                           && ...
                (mean2(black_x) <=2))                          && ...
                ((mean2(blue_co) - mean2(black_co))/0.53 - (mean2(blue_x) - mean2(black_x))/0.47) > 0   % 2011 Oct. 6
             
                blue_rslt = globalAnalysis(blue_co, blue_x, black_co, black_x);
            else
                blue_rslt = {'INV' 'INV' 'INV' 'INV' 'INV' 'INV' 'INV' 'INV' 'INV' 'INV' 'INV' 'INV' 'INV'};
            end
            
            %Now, we work on the images for the red laser
            %Checking the images intensity to see if they are within valid
            %range or not
            if ((20 <= mean2(red_co) && mean2(red_co) <=100) && ...
                (5  <= mean2(red_x)&& mean2(red_x)<=100)     && ...
                (mean2(black_co)<=2)                         && ...
                (mean2(black_x) <=2))                        && ...
                ((mean2(red_co) - mean2(black_co))/0.53 - (mean2(red_x) - mean2(black_x))/0.47) > 0   % 2011 Oct. 6

                red_rslt = globalAnalysis(red_co, red_x, black_co, black_x);
            else
                red_rslt = {'INV' 'INV' 'INV' 'INV' 'INV' 'INV' 'INV' 'INV' 'INV' 'INV' 'INV' 'INV' 'INV'};
            end
            
            rslt = [expfolder2 blue_rslt red_rslt];
            
            % write results to the Excel output file
            xlCounter = xlCounter + 1;
            Cell_number = num2str (xlCounter);
            Starting_cell = sprintf('A%s',Cell_number);  
            xlswrite(fullfile(Main_expfolder, 'speckleAnalysisMaster.xls'), rslt, 'Combined', Starting_cell);
            
            speckleImagesAnalysed = 1;
              
        end   
    end
    Counter_return = xlCounter;
end

% Ignoring the NaN elements that have been assigned to zero value
function[new_mean] = modified_mean(matrix, counter)
[m,n]= size(matrix);
new_mean = (mean2(matrix)* m * n)/((m * n)- counter);

% Analysis the speckle image globally
function rslt = globalAnalysis(co, x, black_co, black_x) 

co_mean = mean2(co);                
co_std = std2(co); 
x_mean = mean2(x);
x_std = std2(x);
black_co_mean = mean2(black_co);                
black_co_std = std2(black_co);               
black_x_mean = mean2(black_x);                
black_x_std = std2(black_x);                

% Compute contrast (c), reduced contrast (rc), DOLPavg, and DOLPmap
% after adjusting for the black noise and 53/47 distribution of the beam
% splitter. 
co_c = sqrt(co_std^2 - black_co_std^2)/(co_mean - black_co_mean);
x_c  = sqrt(x_std^2  - black_x_std^2) /(x_mean  - black_x_mean);
                
rc = sqrt((co_std^2 - black_co_std^2)/(0.53^2) - (x_std^2 - black_x_std^2)/(0.47^2)) / ...
         ((co_mean - black_co_mean)/0.53 - (x_mean - black_x_mean)/0.47);
                
DOLPavg = ((co_mean - black_co_mean)/0.53 - (x_mean - black_x_mean)/0.47) / ...
          ((co_mean - black_co_mean)/0.53 + (x_mean - black_x_mean)/0.47);

% base and input remain in uint8 so that we could use imtransform
% 2011 Nov. 5
base = imsubtract(uint8(co), uint8(black_co));
input = imsubtract(uint8(x), uint8(black_x));
[rows cols]=size (base);
xd = [1 cols];
yd = [1 rows];
xys = [1 1];
transformer = [1.02696 0.0808; 0.0808 -1.02696; -37.24 673.68];
tform_translate = maketform('affine',transformer);
imresult = imtransform (input, tform_translate, 'Xdata', xd, 'Ydata', yd, 'XYScale', xys);

%Taking into consideration the imperfection associated with beam splitter 
base_double = double (base)./0.53;
imresult_double = double (imresult)./0.47;			% Warren Shenkenfelder pointed out that this should be 0.47.

% 2011 Nov. 5, TKL
% Note: msubtract and imadd truncate the results to 0..255!
% Note: should do the computation in double instead.
% Subtracted_result = imsubtract (base_double, imresult_double);
% Added_result = imadd (base_double, imresult_double);
% DOLP = Subtracted_result./Added_result;
DOLP = (base_double - imresult_double) ./ (base_double + imresult_double);

%Displaying only the region of interest, it is set manually
Modified_DOLP = DOLP (1:630,40:1024,:);

%Converting the undefined matrix element due to division by 0 to a zero
%value. (2011 Nov. 5, TKL: We need to capture Inf, -Inf as well as NaN.
%Therefore, we will change isnan to ~isfinite.    
% NaN_Matrix = isnan (Modified_DOLP);
NaN_Matrix = ~isfinite(Modified_DOLP);
NaN_Counter = sum(sum(NaN_Matrix));
NaN_locations = find(NaN_Matrix == 1);
Modified_DOLP(NaN_locations) = 0;
            
%Calculating the moments
ABS_DOLP    = abs(Modified_DOLP);
DOLP_Power2 = Modified_DOLP .* Modified_DOLP;
DOLP_Power3 = DOLP_Power2   .* Modified_DOLP;
DOLP_Power4 = DOLP_Power3   .* Modified_DOLP;
DOLP_Power5 = DOLP_Power4   .* Modified_DOLP;
DOLP_Power6 = DOLP_Power5   .* Modified_DOLP;
DOLP_Power7 = DOLP_Power6   .* Modified_DOLP;
                
% Compute moments (1st_abs, 1st to 4th)
DOLP_1stMoment_ABS = modified_mean(ABS_DOLP,NaN_Counter);
DOLP_1stMoment     = modified_mean(Modified_DOLP,NaN_Counter);
DOLP_2ndMoment     = modified_mean(DOLP_Power2,NaN_Counter);
DOLP_3rdMoment     = modified_mean(DOLP_Power3,NaN_Counter)/(DOLP_2ndMoment^(3/2));
DOLP_4thMoment     = modified_mean(DOLP_Power4,NaN_Counter)/(DOLP_2ndMoment^(4/2)); 
DOLP_5thMoment     = modified_mean(DOLP_Power5,NaN_Counter)/(DOLP_2ndMoment^(5/2));
DOLP_6thMoment     = modified_mean(DOLP_Power6,NaN_Counter)/(DOLP_2ndMoment^(6/2)); 
DOLP_7thMoment     = modified_mean(DOLP_Power7,NaN_Counter)/(DOLP_2ndMoment^(7/2));

rslt = {co_c x_c rc DOLPavg DOLP_1stMoment_ABS DOLP_1stMoment DOLP_2ndMoment DOLP_3rdMoment DOLP_4thMoment DOLP_5thMoment DOLP_6thMoment DOLP_7thMoment NaN_Counter};
            